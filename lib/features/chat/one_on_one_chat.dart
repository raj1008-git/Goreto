import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/services/pusher_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../data/datasources/remote/chat_api_service.dart';
import '../../data/models/chat/chat_models.dart';
import '../../data/models/chat/message_model.dart';
import '../../data/models/chat/nearby_user_model.dart';
import '../../data/providers/auth_provider.dart';

class OneOnOneChatScreen extends StatefulWidget {
  final NearbyUserModel nearbyUser;
  final ChatModel chat;

  const OneOnOneChatScreen({
    Key? key,
    required this.nearbyUser,
    required this.chat,
  }) : super(key: key);

  @override
  State<OneOnOneChatScreen> createState() => _OneOnOneChatScreenState();
}

class _OneOnOneChatScreenState extends State<OneOnOneChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatUserModel otherUser;
  late ChatApiService _chatApiService;
  late PusherService _pusherService;
  bool _isPusherInitialized = false;
  List<MessageModel> messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeOtherUser();
    _chatApiService = ChatApiService(Dio());
    _loadMessages();
    _initializePusher();
  }

  Future<void> _initializePusher() async {
    try {
      final storage = SecureStorageService();
      final authToken = await storage.read('access_token');

      if (authToken == null) {
        print('❌ No auth token found for Pusher');
        return;
      }

      print('🚀 Initializing Pusher for chat ${widget.chat.id}');

      _pusherService = PusherService(
        apiUrl: ApiEndpoints.baseUrl,
        pusherKey: 'b788ecec8a643e0034b6', // Your actual Pusher key
        cluster: 'ap2',
        authToken: authToken,
      );

      // Set up message handler BEFORE initializing
      _pusherService!.onNewMessage = _handleNewMessage;

      // Initialize Pusher
      await _pusherService!.init(widget.chat.id.toString());

      if (mounted) {
        setState(() {
          _isPusherInitialized = true;
        });
      }

      print('✅ Pusher initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Pusher: $e');
      _showErrorSnackBar('Real-time messaging unavailable');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      print('📨 Raw message data received: $data');
      print('📨 Data type: ${data.runtimeType}');
      print('📨 Data keys: ${data.keys.toList()}');

      // Debug: Print each key-value pair
      data.forEach((key, value) {
        print('📨 $key: $value (${value.runtimeType})');
      });

      Map<String, dynamic> messageData = data;

      // Check for different possible data structures
      if (data.containsKey('message') && data['message'] is Map) {
        print('📨 Found message wrapper, extracting...');
        messageData = Map<String, dynamic>.from(data['message']);
      } else if (data.containsKey('data') && data['data'] is Map) {
        print('📨 Found data wrapper, extracting...');
        messageData = Map<String, dynamic>.from(data['data']);
      } else if (data.containsKey('messageData')) {
        print('📨 Found messageData wrapper, extracting...');
        messageData = Map<String, dynamic>.from(data['messageData']);
      }

      print('📨 Processing messageData: $messageData');

      // Try to create MessageModel from the data
      final newMessage = MessageModel.fromJson(messageData);
      print(
        '📨 Created message model: ${newMessage.id} - ${newMessage.messages}',
      );

      if (mounted) {
        setState(() {
          // Check if message already exists to avoid duplicates
          final exists = messages.any((msg) => msg.id == newMessage.id);
          if (!exists) {
            messages.add(newMessage);
            print(
              '📨 Added new message to UI. Total messages: ${messages.length}',
            );
          } else {
            print('📨 Message already exists, skipping duplicate');
          }
        });

        // Scroll to bottom when new message arrives
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error handling new message: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ Raw data: $data');

      // Try to handle the error gracefully
      _showErrorSnackBar('Failed to process new message');
    }
  }

  void _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final chatMessages = await _chatApiService.fetchMessages(widget.chat.id);

      if (mounted) {
        setState(() {
          messages = chatMessages;
          _isLoading = false;
        });

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('❌ Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load messages');
      }
    }
  }

  void _initializeOtherUser() {
    // Find the other user in the chat (not the current user)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;

    otherUser = widget.chat.users.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => widget.chat.users.first, // Fallback
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // _pusherService.disconnect(widget.chat.id.toString());
    if (_pusherService != null) {
      _pusherService!.disconnect(widget.chat.id.toString());
    }
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_isPusherInitialized)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.orange.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Connecting to real-time messaging...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
          // Messages area
          Expanded(child: _buildMessagesArea()),
          // Message input area
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // User Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Text(
                otherUser.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  otherUser.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: otherUser.isOnline
                        ? Colors.green
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Call button
        IconButton(
          icon: Icon(
            Icons.call_outlined,
            color: Colors.grey.shade700,
            size: 24,
          ),
          onPressed: _onCallTap,
        ),
        // Video call button
        IconButton(
          icon: Icon(
            Icons.videocam_outlined,
            color: Colors.grey.shade700,
            size: 24,
          ),
          onPressed: _onVideoCallTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessagesArea() {
    if (messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.blue.shade300,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start your conversation with ${otherUser.name.split(' ').first}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Say hello and introduce yourself!',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    final isMe = message.sentBy == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            // Other user avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                ),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Text(
                  otherUser.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade500 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.messages,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.grey.shade800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.sentAt),
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        if (message.isLoading)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7),
                              ),
                            ),
                          )
                        else if (message.hasError)
                          Icon(
                            Icons.error_outline,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          )
                        else
                          Icon(
                            Icons.done,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
            // Current user avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Text(
                  (authProvider.user?.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      // Same day, show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Different day, show date
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Message input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    // Emoji button
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: _onEmojiTap,
                    ),
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (value) {
                          setState(() {}); // To update send button state
                        },
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _sendMessage();
                          }
                        },
                      ),
                    ),
                    // Attachment button
                    IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: _onAttachmentTap,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Send button
            GestureDetector(
              onTap: _messageController.text.trim().isNotEmpty && !_isLoading
                  ? _sendMessage
                  : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      _messageController.text.trim().isNotEmpty && !_isLoading
                      ? Colors.blue.shade500
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _messageController.text.trim().isNotEmpty
                            ? Colors.white
                            : Colors.grey.shade500,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    // Get current user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;

    if (currentUserId == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    // Create temporary message for immediate UI update
    final tempMessage = MessageModel.createTemporary(
      chatId: widget.chat.id,
      messages: messageText,
      sentBy: currentUserId,
    );

    // Clear input and add message to UI immediately
    _messageController.clear();
    setState(() {
      messages.add(tempMessage);
      _isLoading = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Send message to API
      final request = SendMessageRequest(
        chatId: widget.chat.id,
        messages: messageText,
      );

      final response = await _chatApiService.sendMessage(request);

      setState(() {
        // Remove the last message (temporary one)
        messages.removeLast();
        // Add the real message from server
        messages.add(response.data);
        _isLoading = false;
      });

      print('✅ Message sent successfully: ${response.data.id}');
    } catch (e) {
      print('❌ Failed to send message: $e');

      // Update temp message to show error
      setState(() {
        final tempIndex = messages.length - 1;
        messages[tempIndex] = tempMessage.copyWith(
          isLoading: false,
          hasError: true,
        );
        _isLoading = false;
      });

      _showErrorSnackBar('Failed to send message');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onEmojiTap() {
    // TODO: Implement emoji picker
    print('Emoji picker tapped');
  }

  void _onAttachmentTap() {
    // TODO: Implement attachment picker
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.photo_outlined,
                  'Photo',
                  Colors.purple,
                  () {
                    Navigator.pop(context);
                    _onPhotoAttachment();
                  },
                ),
                _buildAttachmentOption(
                  Icons.videocam_outlined,
                  'Video',
                  Colors.red,
                  () {
                    Navigator.pop(context);
                    _onVideoAttachment();
                  },
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file_outlined,
                  'Document',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    _onDocumentAttachment();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _onCallTap() {
    // TODO: Implement voice call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${otherUser.name.split(' ').first}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onVideoCallTap() {
    // TODO: Implement video call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video calling ${otherUser.name.split(' ').first}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _onPhotoAttachment() {
    // TODO: Implement photo attachment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo attachment selected'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _onVideoAttachment() {
    // TODO: Implement video attachment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video attachment selected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onDocumentAttachment() {
    // TODO: Implement document attachment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document attachment selected'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
