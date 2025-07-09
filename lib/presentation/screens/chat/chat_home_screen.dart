import 'package:flutter/material.dart';
import 'package:goreto/data/models/chat/nearby_user_model.dart';
import 'package:goreto/features/chat/providers/chat_provider.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.blueAccent),
            tooltip: "Update Location",
            onPressed: chatProvider.updateLocationAndFetchUsers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("People around Me", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            chatProvider.isLoading
                ? const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: LoadingIndicator(
                        indicatorType:
                            Indicator.ballPulse, // Stylish dotted loader
                        colors: [Colors.blueAccent, Colors.lightBlue],
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: chatProvider.nearbyUsers.length,
                      itemBuilder: (context, index) {
                        final user = chatProvider.nearbyUsers[index];
                        return GestureDetector(
                          onTap: () {
                            chatProvider.initiateChatWithUser(
                              user.toChatUser(),
                              context,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    user.name[0],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            const Text("Recent Chats", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ...chatProvider.recentChats.map((chat) {
              final otherUser = chat.users.firstWhere(
                (u) => u.id != chat.createdBy,
              );
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      otherUser.name[0],
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  title: Text(otherUser.name),
                  onTap: () {
                    chatProvider.initiateChatWithUser(otherUser, context);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
