import 'package:flutter/material.dart';
import 'package:goreto/screens/chat/chat_message_page.dart';

class ChatListPage extends StatelessWidget {
  final List<Map<String, dynamic>> chatData = [
    {
      'name': 'Raj Singh',
      'message': 'Hi, David. Hope you’re doing....',
      'date': '29 Mar',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Shreya',
      'message': 'Are you ready for today’s part..',
      'date': '12 Mar',
      'unread': true,
      'image': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Nolan',
      'message': 'I’m sending you a parcel rece..',
      'date': '08 Feb',
      'image': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Dikshya',
      'message': 'Hope you’re doing well today..',
      'date': '02 Feb',
      'image': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'Pradeep',
      'message': 'Let’s get back to the work, You..',
      'date': '25 Jan',
      'image': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
    {
      'name': 'Raj Singh',
      'message': 'Hi, David. Hope you’re doing....',
      'date': '29 Mar',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Raj Singh',
      'message': 'Hi, David. Hope you’re doing....',
      'date': '29 Mar',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Raj Singh',
      'message': 'Hi, David. Hope you’re doing....',
      'date': '29 Mar',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Raj Singh',
      'message': 'Hi, David. Hope you’re doing....',
      'date': '29 Mar',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Chat'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search here..',
                prefixIcon: Icon(Icons.search, color: Colors.orange),
                suffixIcon: Icon(Icons.mic),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chatData.length,
              itemBuilder: (context, index) {
                final chat = chatData[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatMessagePage(
                          userName: chat['name'],
                          userImage: chat['image'],
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chat['image']),
                    radius: 28,
                  ),
                  title: Text(
                    chat['name'],
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(chat['message'],
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat['date'],
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      if (chat['unread'] == true)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, size: 28),
            Icon(Icons.qr_code_scanner, size: 28),
            SizedBox(width: 48), // center notch space
            Icon(Icons.chat_bubble_outline, size: 28),
            Icon(Icons.person_outline, size: 28),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {},
        child: Icon(Icons.location_pin),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
