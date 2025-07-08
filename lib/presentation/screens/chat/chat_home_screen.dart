import 'package:flutter/material.dart';
import 'package:goreto/features/chat/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: chatProvider.updateLocationAndFetchUsers,
              child: const Text("Update Location"),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("People around Me", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            chatProvider.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: chatProvider.nearbyUsers.length,
                      itemBuilder: (context, index) {
                        final user = chatProvider.nearbyUsers[index];
                        return Column(
                          children: [
                            CircleAvatar(radius: 30, child: Text(user.name[0])),
                            const SizedBox(height: 4),
                            Text(
                              user.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
