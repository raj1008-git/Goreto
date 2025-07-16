import 'package:flutter/material.dart';
import 'package:goreto/data/providers/my_post_provider.dart';
// Import your post detail screen here
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
    return Consumer<MyPostProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.posts.isEmpty) {
          return const Center(child: Text("No posts yet."));
        }

        // We want to show images but also keep track of the post they belong to.
        // So create a list of tuples: (post, imageUrl)
        final postImagePairs = <MapEntry<int, String>>[];

        for (var post in provider.posts) {
          for (var imageUrl in post.imageUrls) {
            postImagePairs.add(MapEntry(post.id, imageUrl));
          }
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: postImagePairs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    // Refresh posts after deletion
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
        );
      },
    );
  }
}
