import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../data/providers/post_details_provider.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailProvider>(
      create: (_) => PostDetailProvider()..loadPostDetail(postId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Post Details"),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // TODO: Implement delete functionality
              },
            ),
          ],
        ),
        body: Consumer<PostDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.postDetail == null) {
              return const Center(child: Text("Failed to load post details."));
            }

            final post = provider.postDetail!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.description, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),

                  // Images
                  if (post.postContents.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.postContents.length,
                        itemBuilder: (context, index) {
                          final imageUrl =
                              "${ApiEndpoints.storageBaseUrl}/${post.postContents[index].contentPath}";
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Category
                  Text(
                    "Category: ${post.postCategory.isNotEmpty ? post.postCategory[0].category.category : "Unknown"}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Text(
                    "Location: ${post.postLocations.isNotEmpty ? post.postLocations[0].location.name : "Unknown"}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Add more details as needed
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
