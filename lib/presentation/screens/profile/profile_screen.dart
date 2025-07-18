// import 'package:flutter/material.dart';
// import 'package:goreto/data/providers/my_post_provider.dart';
// // Import your post detail screen here
// import 'package:provider/provider.dart';
//
// import '../../../features/blog/screens/post_details_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       Provider.of<MyPostProvider>(context, listen: false).fetchMyPosts();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MyPostProvider>(
//       builder: (context, provider, _) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (provider.posts.isEmpty) {
//           return const Center(child: Text("No posts yet."));
//         }
//
//         // We want to show images but also keep track of the post they belong to.
//         // So create a list of tuples: (post, imageUrl)
//         final postImagePairs = <MapEntry<int, String>>[];
//
//         for (var post in provider.posts) {
//           for (var imageUrl in post.imageUrls) {
//             postImagePairs.add(MapEntry(post.id, imageUrl));
//           }
//         }
//
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GridView.builder(
//             itemCount: postImagePairs.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//               childAspectRatio: 1,
//             ),
//             itemBuilder: (context, index) {
//               final postId = postImagePairs[index].key;
//               final imageUrl = postImagePairs[index].value;
//
//               return GestureDetector(
//                 onTap: () async {
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => PostDetailScreen(postId: postId),
//                     ),
//                   );
//
//                   if (result == true && mounted) {
//                     // Refresh posts after deletion
//                     Provider.of<MyPostProvider>(
//                       context,
//                       listen: false,
//                     ).fetchMyPosts();
//                   }
//                 },
//
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.broken_image),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:goreto/data/providers/my_post_provider.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../features/blog/screens/post_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MyPostProvider>(context, listen: false).fetchMyPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/logos/goreto.png', height: 32),
            const SizedBox(width: 10),
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<MyPostProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.posts.isEmpty) {
            return const Center(child: Text("No posts yet."));
          }

          final postImagePairs = <MapEntry<int, String>>[];

          for (var post in provider.posts) {
            for (var imageUrl in post.imageUrls) {
              postImagePairs.add(MapEntry(post.id, imageUrl));
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // User Info Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Raj Singh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '+9779761644169',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Bagbazar, Kathmandu',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 1, color: Colors.grey),
                      IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.groupCreate),
                        icon: Icon(Icons.group),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // My Posts Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'My Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              // Posts Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    itemCount: postImagePairs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final postId = postImagePairs[index].key;
                      final imageUrl = postImagePairs[index].value;

                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(postId: postId),
                            ),
                          );

                          if (result == true && mounted) {
                            Provider.of<MyPostProvider>(
                              context,
                              listen: false,
                            ).fetchMyPosts();
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
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
