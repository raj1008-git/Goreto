import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../../../data/models/chat/chat_model.dart';
import '../../../data/models/chat/message_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final Chat chat;
  const ChatRoomScreen({super.key, required this.chat});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  final Set<int> _seenMessageIds = {}; // For preventing duplicates

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    chatProvider.fetchMessages(widget.chat.id).then((_) {
      for (final msg in chatProvider.messages) {
        _seenMessageIds.add(msg.id);
      }
      _scrollToBottom();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final newMessages = await chatProvider.fetchMessages(widget.chat.id);
      final added = chatProvider.messages
          .where((m) => !_seenMessageIds.contains(m.id))
          .toList();

      if (added.isNotEmpty) {
        for (final msg in added) {
          _seenMessageIds.add(msg.id);
        }
        setState(() {});
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
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

  Future<void> _sendMessage(ChatProvider chatProvider) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final currentUserId = chatProvider.activeChat?.createdBy;
    if (currentUserId == null) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      message: text,
      sentBy: currentUserId,
      sentAt: DateTime.now(),
    );

    chatProvider.messages.add(newMessage);
    _seenMessageIds.add(newMessage.id);
    chatProvider.notifyListeners();
    _scrollToBottom();

    try {
      final sentMessage = await chatProvider.sendMessageAndGetNew(
        widget.chat.id,
        text,
      );

      final index = chatProvider.messages.indexWhere(
        (m) => m.id == newMessage.id,
      );
      if (index != -1) {
        chatProvider.messages[index] = sentMessage;
        _seenMessageIds.add(sentMessage.id);
        chatProvider.notifyListeners();
      }
    } catch (e) {
      print('Send message error: \$e');
    }
  }

  String _getUserName(int userId) {
    final user = widget.chat.users.firstWhere(
      (u) => u.id == userId,
      orElse: () =>
          ChatUser(id: 0, name: 'Unknown', email: 'unknown@example.com'),
    );
    return user.name;
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = chatProvider.activeChat?.createdBy;

    final messages = chatProvider.messages;
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                widget.chat.users
                    .firstWhere((u) => u.id != currentUserId)
                    .name[0]
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.chat.users.firstWhere((u) => u.id != currentUserId).name,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.black54),
            onPressed: () {
              // TODO: Add call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black54),
            onPressed: () {
              // TODO: Add video call functionality
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.sentBy == currentUserId;
                  final userName = _getUserName(msg.sentBy);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: isMe ? 0 : 8,
                            right: isMe ? 8 : 0,
                            bottom: 4,
                          ),
                          child: Text(
                            userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.orange : Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.message,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(chatProvider),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.grey[200],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(chatProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
