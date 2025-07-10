import 'package:flutter/material.dart';
import 'package:goreto/data/models/chat/nearby_users_response_model.dart';

class NearbyUserCard extends StatelessWidget {
  final NearbyUser user;
  final VoidCallback onTap;

  const NearbyUserCard({Key? key, required this.user, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 30,
                  // TODO: Add actual user profile image if available
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150/0000FF/808080?text=${user.name[0]}',
                  ),
                  backgroundColor: Colors.blueGrey.shade100,
                ),
                // Example: Online status indicator
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.green, // Example: green for online
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              user.name.split(' ').first, // Show first name
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${user.distance.toStringAsFixed(2)} km', // Display distance
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
