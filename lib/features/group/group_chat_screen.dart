// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:goreto/features/group/widgets/group_avatar.dart';
//
// import '../../../data/models/Group/group_model.dart';
//
// class GroupChatScreen extends StatefulWidget {
//   final GroupModel group;
//
//   const GroupChatScreen({super.key, required this.group});
//
//   @override
//   State<GroupChatScreen> createState() => _GroupChatScreenState();
// }
//
// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   // Mock messages for UI demonstration
//   final List<Map<String, dynamic>> _mockMessages = [
//     {
//       'id': '1',
//       'sender': 'John Doe',
//       'message': 'Hey everyone! Ready for the trek tomorrow?',
//       'time': '10:30 AM',
//       'isMe': false,
//       'initials': 'JD',
//     },
//     {
//       'id': '2',
//       'sender': 'You',
//       'message': 'Yes! Can\'t wait. What time are we meeting?',
//       'time': '10:35 AM',
//       'isMe': true,
//       'initials': 'ME',
//     },
//     {
//       'id': '3',
//       'sender': 'Sarah Wilson',
//       'message': 'I think we decided on 7 AM at the base camp',
//       'time': '10:37 AM',
//       'isMe': false,
//       'initials': 'SW',
//     },
//     {
//       'id': '4',
//       'sender': 'Mike Chen',
//       'message': 'Perfect! I\'ll bring extra water bottles for everyone',
//       'time': '10:40 AM',
//       'isMe': false,
//       'initials': 'MC',
//     },
//   ];
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           Expanded(child: _buildMessagesArea()),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 2,
//       shadowColor: Colors.black.withOpacity(0.1),
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//       title: Row(
//         children: [
//           // Group Avatar
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: GroupAvatar(group: widget.group, radius: 22),
//           ),
//
//           const SizedBox(width: 14),
//
//           // Group info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.group.name,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF2D3748),
//                     letterSpacing: -0.3,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${widget.group.userGroups.length} members',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         // Voice call button
//         Container(
//           margin: const EdgeInsets.only(right: 8),
//           child: IconButton(
//             icon: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.call_outlined,
//                 color: Colors.green,
//                 size: 20,
//               ),
//             ),
//             onPressed: _onVoiceCall,
//           ),
//         ),
//
//         // Video call button
//         Container(
//           margin: const EdgeInsets.only(right: 12),
//           child: IconButton(
//             icon: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.videocam_outlined,
//                 color: Colors.blue,
//                 size: 20,
//               ),
//             ),
//             onPressed: _onVideoCall,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMessagesArea() {
//     if (_mockMessages.isEmpty) {
//       return _buildEmptyState();
//     }
//
//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       itemCount: _mockMessages.length,
//       itemBuilder: (context, index) {
//         final message = _mockMessages[index];
//         return _buildMessageBubble(message);
//       },
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.shade100, Colors.purple.shade100],
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.group_outlined,
//               size: 48,
//               color: Colors.blue.shade400,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Welcome to ${widget.group.name}!',
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF2D3748),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Start the conversation by sending your first message',
//             style: TextStyle(
//               fontSize: 15,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(Map<String, dynamic> message) {
//     final bool isMe = message['isMe'] as bool;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         mainAxisAlignment: isMe
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isMe) ...[
//             // Other user avatar
//             _buildUserAvatar(message['initials'], isMe),
//             const SizedBox(width: 10),
//           ],
//
//           // Message content
//           Flexible(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               child: Column(
//                 crossAxisAlignment: isMe
//                     ? CrossAxisAlignment.end
//                     : CrossAxisAlignment.start,
//                 children: [
//                   if (!isMe)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16, bottom: 4),
//                       child: Text(
//                         message['sender'],
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ),
//
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: isMe
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.blue.shade500,
//                                 Colors.blue.shade600,
//                               ],
//                             )
//                           : null,
//                       color: isMe ? null : Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: const Radius.circular(18),
//                         topRight: const Radius.circular(18),
//                         bottomLeft: Radius.circular(isMe ? 18 : 6),
//                         bottomRight: Radius.circular(isMe ? 6 : 18),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           message['message'],
//                           style: TextStyle(
//                             color: isMe ? Colors.white : Colors.grey.shade800,
//                             fontSize: 15,
//                             height: 1.4,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           message['time'],
//                           style: TextStyle(
//                             color: isMe
//                                 ? Colors.white.withOpacity(0.8)
//                                 : Colors.grey.shade500,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           if (isMe) ...[
//             const SizedBox(width: 10),
//             _buildUserAvatar('ME', isMe),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUserAvatar(String initials, bool isMe) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: isMe
//             ? LinearGradient(
//                 colors: [Colors.blue.shade400, Colors.purple.shade400],
//               )
//             : LinearGradient(
//                 colors: [Colors.grey.shade400, Colors.grey.shade500],
//               ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: CircleAvatar(
//         radius: 18,
//         backgroundColor: Colors.transparent,
//         child: Text(
//           initials,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             // Message input field
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(25),
//                   border: Border.all(color: Colors.grey.shade200, width: 1),
//                 ),
//                 child: Row(
//                   children: [
//                     // Emoji button
//                     IconButton(
//                       icon: Icon(
//                         Icons.emoji_emotions_outlined,
//                         color: Colors.grey.shade600,
//                         size: 22,
//                       ),
//                       onPressed: _onEmojiTap,
//                     ),
//
//                     // Text field
//                     Expanded(
//                       child: TextField(
//                         controller: _messageController,
//                         decoration: InputDecoration(
//                           hintText: 'Type a message...',
//                           hintStyle: TextStyle(
//                             color: Colors.grey.shade500,
//                             fontSize: 16,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 14,
//                           ),
//                         ),
//                         maxLines: null,
//                         textCapitalization: TextCapitalization.sentences,
//                         onChanged: (value) {
//                           setState(() {}); // Update send button state
//                         },
//                         onSubmitted: (value) {
//                           if (value.trim().isNotEmpty) {
//                             _sendMessage();
//                           }
//                         },
//                       ),
//                     ),
//
//                     // Attachment button
//                     IconButton(
//                       icon: Icon(
//                         Icons.attach_file_rounded,
//                         color: Colors.grey.shade600,
//                         size: 22,
//                       ),
//                       onPressed: _onAttachmentTap,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(width: 12),
//
//             // Send button
//             GestureDetector(
//               onTap: _messageController.text.trim().isNotEmpty
//                   ? _sendMessage
//                   : null,
//               child: Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   gradient: _messageController.text.trim().isNotEmpty
//                       ? LinearGradient(
//                           colors: [Colors.blue.shade500, Colors.blue.shade600],
//                         )
//                       : null,
//                   color: _messageController.text.trim().isEmpty
//                       ? Colors.grey.shade300
//                       : null,
//                   shape: BoxShape.circle,
//                   boxShadow: _messageController.text.trim().isNotEmpty
//                       ? [
//                           BoxShadow(
//                             color: Colors.blue.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ]
//                       : null,
//                 ),
//                 child: Icon(
//                   Icons.send_rounded,
//                   color: _messageController.text.trim().isNotEmpty
//                       ? Colors.white
//                       : Colors.grey.shade500,
//                   size: 20,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _sendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isEmpty) return;
//
//     // Add message to mock list for UI demonstration
//     setState(() {
//       _mockMessages.add({
//         'id': DateTime.now().millisecondsSinceEpoch.toString(),
//         'sender': 'You',
//         'message': message,
//         'time': _getCurrentTime(),
//         'isMe': true,
//         'initials': 'ME',
//       });
//     });
//
//     _messageController.clear();
//
//     // Scroll to bottom
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//
//     // Show success feedback
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Message sent!'),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }
//
//   String _getCurrentTime() {
//     final now = DateTime.now();
//     final hour = now.hour > 12 ? now.hour - 12 : now.hour;
//     final minute = now.minute.toString().padLeft(2, '0');
//     final period = now.hour >= 12 ? 'PM' : 'AM';
//     return '$hour:$minute $period';
//   }
//
//   void _onVoiceCall() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Starting voice call with ${widget.group.name}...'),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   void _onVideoCall() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Starting video call with ${widget.group.name}...'),
//         backgroundColor: Colors.blue,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   void _onEmojiTap() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Emoji picker coming soon!'),
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }
//
//   void _onAttachmentTap() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         margin: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.all(24),
//               child: Text(
//                 'Choose attachment type',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF2D3748),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildAttachmentOption(
//                     Icons.photo_outlined,
//                     'Photo',
//                     Colors.purple,
//                   ),
//                   _buildAttachmentOption(
//                     Icons.videocam_outlined,
//                     'Video',
//                     Colors.red,
//                   ),
//                   _buildAttachmentOption(
//                     Icons.insert_drive_file_outlined,
//                     'Document',
//                     Colors.blue,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAttachmentOption(IconData icon, String label, Color color) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('$label attachment selected'),
//             backgroundColor: color,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       },
//       child: Column(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 28, color: color),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goreto/features/group/widgets/group_avatar.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/pusher_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../data/datasources/remote/chat_api_service.dart';
import '../../../data/models/Group/group_model.dart';
import '../../../data/models/chat/message_model.dart';
import '../../../data/providers/auth_provider.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatApiService _chatApiService;
  late PusherService _pusherService;
  bool _isPusherInitialized = false;
  List<MessageModel> messages = [];
  bool _isLoading = false;
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
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

      print(
        '🚀 Initializing Pusher for group chat ${widget.group.groupChatId}',
      );

      _pusherService = PusherService(
        apiUrl: ApiEndpoints.baseUrl,
        pusherKey: 'b788ecec8a643e0034b6', // Your actual Pusher key
        cluster: 'ap2',
        authToken: authToken,
      );

      // Set up message handler BEFORE initializing
      _pusherService.onNewMessage = _handleNewMessage;

      // Initialize Pusher with group chat ID
      await _pusherService.init(widget.group.groupChatId.toString());

      if (mounted) {
        setState(() {
          _isPusherInitialized = true;
        });
      }

      print('✅ Pusher initialized successfully for group chat');
    } catch (e) {
      print('❌ Failed to initialize Pusher: $e');
      _showErrorSnackBar('Real-time messaging unavailable');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      print('📨 Raw group message data received: $data');
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

      print('📨 Processing group messageData: $messageData');

      // Try to create MessageModel from the data
      final newMessage = MessageModel.fromJson(messageData);
      print(
        '📨 Created group message model: ${newMessage.id} - ${newMessage.messages}',
      );

      // Get current user ID to avoid showing our own messages from Pusher
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id;

      if (mounted) {
        setState(() {
          // Check if message already exists to avoid duplicates
          final exists = messages.any((msg) => msg.id == newMessage.id);
          if (!exists) {
            // Only add if it's not from the current user (to avoid double showing)
            // or if it's from another user
            if (newMessage.sentBy != currentUserId) {
              messages.add(newMessage);
              print(
                '📨 Added new group message to UI. Total messages: ${messages.length}',
              );
            } else {
              print('📨 Skipping own message from Pusher to avoid duplicate');
            }
          } else {
            print('📨 Group message already exists, skipping duplicate');
          }
        });

        // Scroll to bottom when new message arrives
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error handling new group message: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ Raw data: $data');

      // Try to handle the error gracefully
      _showErrorSnackBar('Failed to process new message');
    }
  }

  void _loadMessages() async {
    try {
      setState(() {
        _isLoadingMessages = true;
      });

      // Use group chat ID to fetch messages
      final chatMessages = await _chatApiService.fetchMessages(
        widget.group.groupChatId,
      );

      if (mounted) {
        setState(() {
          messages = chatMessages;
          _isLoadingMessages = false;
        });

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('❌ Error loading group messages: $e');
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
        _showErrorSnackBar('Failed to load messages');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_isPusherInitialized) {
      _pusherService.disconnect(widget.group.groupChatId.toString());
    }
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
          Expanded(child: _buildMessagesArea()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Group Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GroupAvatar(group: widget.group, radius: 22),
          ),

          const SizedBox(width: 14),

          // Group info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.group.userGroups.length} members',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Voice call button
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_outlined,
                color: Colors.green,
                size: 20,
              ),
            ),
            onPressed: _onVoiceCall,
          ),
        ),

        // Video call button
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
            onPressed: _onVideoCall,
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesArea() {
    if (_isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.purple.shade100],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_outlined,
              size: 48,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to ${widget.group.name}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation by sending your first message',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    final isMe = message.sentBy == currentUserId;

    // Find the sender's user info from group members
    UserGroupModel? senderInfo;
    try {
      senderInfo = widget.group.userGroups.firstWhere(
        (userGroup) => userGroup.userId == message.sentBy,
      );
    } catch (e) {
      print('Sender not found in group members: ${message.sentBy}');
    }

    final senderName = senderInfo?.user.name ?? 'Unknown User';
    final senderInitials = _getInitials(senderName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Other user avatar
            _buildUserAvatar(senderInitials, isMe),
            const SizedBox(width: 10),
          ],

          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                              colors: [
                                Colors.blue.shade500,
                                Colors.blue.shade600,
                              ],
                            )
                          : null,
                      color: isMe ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 6),
                        bottomRight: Radius.circular(isMe ? 6 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.sentAt),
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey.shade500,
                                fontSize: 12,
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
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 10),
            _buildUserAvatar('ME', isMe),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Widget _buildUserAvatar(String initials, bool isMe) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isMe
            ? LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              )
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.transparent,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
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
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    // Emoji button
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey.shade600,
                        size: 22,
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
                            vertical: 14,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (value) {
                          setState(() {}); // Update send button state
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
                        Icons.attach_file_rounded,
                        color: Colors.grey.shade600,
                        size: 22,
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
                  gradient:
                      _messageController.text.trim().isNotEmpty && !_isLoading
                      ? LinearGradient(
                          colors: [Colors.blue.shade500, Colors.blue.shade600],
                        )
                      : null,
                  color: _messageController.text.trim().isEmpty || _isLoading
                      ? Colors.grey.shade300
                      : null,
                  shape: BoxShape.circle,
                  boxShadow:
                      _messageController.text.trim().isNotEmpty && !_isLoading
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
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
                        Icons.send_rounded,
                        color:
                            _messageController.text.trim().isNotEmpty &&
                                !_isLoading
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
      chatId: widget.group.groupChatId,
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
      // Send message to API using group chat ID
      final request = SendMessageRequest(
        chatId: widget.group.groupChatId,
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

      print('✅ Group message sent successfully: ${response.data.id}');
    } catch (e) {
      print('❌ Failed to send group message: $e');

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

  void _onVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting voice call with ${widget.group.name}...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting video call with ${widget.group.name}...'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onEmojiTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emoji picker coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onAttachmentTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Choose attachment type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    Icons.photo_outlined,
                    'Photo',
                    Colors.purple,
                  ),
                  _buildAttachmentOption(
                    Icons.videocam_outlined,
                    'Video',
                    Colors.red,
                  ),
                  _buildAttachmentOption(
                    Icons.insert_drive_file_outlined,
                    'Document',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label attachment selected'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
