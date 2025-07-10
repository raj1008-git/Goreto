import 'package:flutter/material.dart';
// We'll create this next
import 'package:goreto/core/utils/snackbar_helper.dart'; // For showing messages
import 'package:goreto/features/chat/providers/chat_provider.dart';
import 'package:provider/provider.dart';

import '../../../features/chat/widgets/nearby_user_card.dart';
import '../../../routes/app_routes.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/chat-home';

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Optionally fetch nearby users on init, or only on button press
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<ChatProvider>(context, listen: false).sendAndFetchNearbyUsers();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () async {
              final chatProvider = Provider.of<ChatProvider>(
                context,
                listen: false,
              );
              if (chatProvider.isSendingLocation) {
                SnackbarHelper.show(
                  context,
                  'Fetching location...',
                  backgroundColor: Colors.orange,
                );
                return;
              }
              SnackbarHelper.show(
                context,
                'Fetching nearby users...',
                backgroundColor: Colors.blue,
              );
              await chatProvider.sendAndFetchNearbyUsers();
              if (chatProvider.nearbyUsers.isNotEmpty) {
                SnackbarHelper.show(
                  context,
                  '${chatProvider.nearbyUsers.length} nearby users found!',
                );
              } else {
                SnackbarHelper.show(
                  context,
                  'No nearby users found.',
                  backgroundColor: Colors.red,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoadingNearbyUsers) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatProvider.nearbyUsers.isEmpty) {
            return const Center(
              child: Text(
                'Press the location icon to find nearby users.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Nearby Users (${chatProvider.nearbyUsers.length})',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(
                height: 100, // Fixed height for horizontal scroll
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chatProvider.nearbyUsers.length,
                  itemBuilder: (context, index) {
                    final user = chatProvider.nearbyUsers[index];
                    return NearbyUserCard(
                      user: user,
                      // Inside your ChatHomeScreen's NearbyUserCard onTap:
                      onTap: () async {
                        try {
                          await chatProvider.createAndNavigateToChat(user.id);
                          if (chatProvider.currentChat != null) {
                            Navigator.of(context).pushNamed(
                              AppRoutes
                                  .personalChat, // Use your new route constant
                              // No need to pass arguments directly if ChatProvider holds currentChat
                              // arguments: chatProvider.currentChat!.id,
                            );
                          } else {
                            SnackbarHelper.show(
                              context,
                              'Failed to create/get chat.',
                              backgroundColor: Colors.red,
                            );
                          }
                        } catch (e) {
                          SnackbarHelper.show(
                            context,
                            'Error initiating chat: $e',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              // TODO: Implement Recent Chat Tiles here later (similar to Messenger)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Recent Chats',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Recent chat list will appear here.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
