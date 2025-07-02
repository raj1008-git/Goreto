import 'package:flutter/material.dart';

class ChatMessagePage extends StatelessWidget {
  final String userName;
  final String userImage;

  const ChatMessagePage({
    super.key,
    this.userName = "Raj Singh",
    this.userImage = "https://randomuser.me/api/portraits/men/1.jpg",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(userImage)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                Text("Active Now",
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          Icon(Icons.call, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.videocam, color: Colors.black),
          SizedBox(width: 10),
        ],
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildReceiverBubble(userImage, "Are you still travelling?"),
                _buildSenderBubble("Yes, I’m at Nepal.."),
                _buildReceiverBubble(userImage, "OoOo, That's so Cool!"),
                _buildReceiverBubble(userImage, "Raining??"),
                _buildVoiceMessageBubble(isSender: true),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text("Thursday 24, 2022",
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                _buildReceiverBubble(userImage, "Kata hora?"),
                _buildVoiceMessageBubble(isSender: true),
                _buildReceiverBubble(userImage, "Ok!"),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildReceiverBubble(String image, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundImage: NetworkImage(image), radius: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(text),
          ),
        ),
      ],
    );
  }

  Widget _buildSenderBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFFFFE0B2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildVoiceMessageBubble({bool isSender = false, String? nameLabel}) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSender ? Color(0xFFFFE0B2) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.play_arrow),
          SizedBox(width: 8),
          Icon(Icons.graphic_eq),
        ],
      ),
    );

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        children: [
          bubble,
          if (nameLabel != null)
            Positioned(
              top: -10,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  nameLabel,
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type message",
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.send, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
