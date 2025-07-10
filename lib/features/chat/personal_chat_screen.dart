import 'package:flutter/material.dart';
import 'package:goreto/core/utils/snackbar_helper.dart';
import 'package:goreto/features/chat/providers/chat_provider.dart';
import 'package:provider/provider.dart';

import '../../data/models/chat/chat_creation_response_model.dart';

class PersonalChatScreen extends StatefulWidget {
  const PersonalChatScreen({Key? key}) : super(key: key);

  static const String routeName = '/personalChat';

  @override
  State<PersonalChatScreen> createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Add the listener for message changes to scroll to bottom
      chatProvider.addListener(_messagesListener);
      debugPrint("PersonalChatScreen: Listener added for message changes.");

      if (chatProvider.currentChat == null) {
        debugPrint("PersonalChatScreen: currentChat is null in initState.");
        SnackbarHelper.show(
          context,
          'No chat selected or chat data lost. Please try again.',
          backgroundColor: Colors.red,
        );
        Navigator.of(context).pop();
      } else {
        // Fetch messages if a chat is active. This ensures messages are loaded on screen entry.
        debugPrint(
          "PersonalChatScreen: Calling fetchMessagesForCurrentChat for Chat ID: ${chatProvider.currentChat!.id}",
        );
        chatProvider.fetchMessagesForCurrentChat();
      }
    });
  }

  // Listener to scroll to the bottom when messages change
  void _messagesListener() {
    debugPrint(
      "PersonalChatScreen: Messages list changed. Attempting to scroll to bottom.",
    );
    // We delay the scroll slightly to ensure the ListView has rebuilt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.removeListener(
      _messagesListener,
    ); // Remove the listener to prevent memory leaks
    debugPrint("PersonalChatScreen: Listener removed.");
    chatProvider.clearCurrentChat(); // Clear chat data on screen dispose
    debugPrint("PersonalChatScreen: Current chat cleared on dispose.");
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      debugPrint("PersonalChatScreen: Message content is empty. Not sending.");
      return;
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messageContent = _messageController.text.trim();
    _messageController.clear(); // Clear input field immediately for good UX

    try {
      debugPrint(
        "PersonalChatScreen: Attempting to send message: $messageContent",
      );
      await chatProvider.sendMessage(messageContent);
      // The _messagesListener will handle scrolling after notifyListeners in provider
      debugPrint(
        "PersonalChatScreen: Message sent successfully (API acknowledged).",
      );
    } catch (e) {
      SnackbarHelper.show(
        context,
        'Failed to send message. Please try again.',
        backgroundColor: Colors.red,
      );
      debugPrint("PersonalChatScreen: Send message error: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Check if the scroll controller is attached to any scrollable widget
      _scrollController
          .animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) {
            debugPrint("PersonalChatScreen: Scrolled to bottom.");
          });
    } else {
      debugPrint(
        "PersonalChatScreen: ScrollController has no clients yet, cannot scroll.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using Consumer for parts of the UI that react to provider changes for better performance.
    // For `currentChat` and `currentUserId` which are typically set once per chat session,
    // Provider.of<ChatProvider>(context) without listen: false is fine here,
    // as it represents the overall state of the screen.
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentChat = chatProvider.currentChat;
    final currentUserId = chatProvider.currentUserId;

    // Initial loading state or if chat data is missing (should be caught in initState, but as a fallback)
    if (currentChat == null || currentUserId == null) {
      debugPrint(
        "PersonalChatScreen: Building with currentChat or currentUserId as null. Showing loading indicator.",
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child:
              chatProvider
                  .isLoadingMessages // Check if messages are being loaded
              ? const CircularProgressIndicator()
              : const Text(
                  'Chat data not available. Please go back and select a chat.',
                ),
        ),
      );
    }

    // Determine the recipient's name for the app bar title
    // Robustly find the recipient or provide a fallback name
    final recipient = currentChat.users.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () {
        debugPrint(
          "PersonalChatScreen: Recipient not found, falling back to first user or 'Unknown'. Users: ${currentChat.users.map((u) => u.id).toList()}",
        );
        // If the current user is the only one in the list (shouldn't happen in 1-on-1)
        // or if somehow no other user is found, provide a safe fallback.
        return currentChat.users.isNotEmpty
            ? currentChat.users.first
            : (
              // Create a dummy ChatUser if the list is completely empty as a last resort
              ChatUser(
                id: 0,
                name: 'Unknown User',
                email: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                countryId: 0,
                roleId: 0,
                activityStatus: 0,
                pivot: Pivot(
                  chatId: 0,
                  userId: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ));
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(recipient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              SnackbarHelper.show(
                context,
                'Call functionality coming soon!',
                backgroundColor: Colors.amber,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              SnackbarHelper.show(
                context,
                'Video call functionality coming soon!',
                backgroundColor: Colors.amber,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Use Selector for messages to rebuild only when the messages list changes
          Expanded(
            child: Selector<ChatProvider, List>(
              selector: (context, provider) => provider.messages,
              builder: (context, messages, child) {
                // Also listen to isLoadingMessages inside the builder, if you want
                // the loading indicator to show only for the message list area.
                final isLoading = Provider.of<ChatProvider>(
                  context,
                ).isLoadingMessages;

                if (isLoading && messages.isEmpty) {
                  // Show loading only if no messages are present yet
                  debugPrint(
                    "PersonalChatScreen: Showing initial message loading indicator.",
                  );
                  return const Center(child: CircularProgressIndicator());
                } else if (messages.isEmpty) {
                  debugPrint(
                    "PersonalChatScreen: Messages list is empty. Showing 'No messages yet'.",
                  );
                  return const Center(
                    child: Text(
                      'No messages yet. Start a conversation!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else {
                  debugPrint(
                    "PersonalChatScreen: Displaying ${messages.length} messages.",
                  );
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      // Ensure currentUserId is not null for comparison
                      final isMe = message.sentBy == currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.messages,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message.sentAt),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
