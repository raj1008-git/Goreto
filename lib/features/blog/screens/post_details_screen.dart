import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../data/datasources/remote/post_api_service.dart';
import '../../../data/providers/post_details_provider.dart';
import '../../../data/providers/post_review_provider.dart';
import 'edit_post.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailProvider>(
      create: (_) => PostDetailProvider()..loadPostDetail(postId),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text(
            "Post Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            Consumer<PostDetailProvider>(
              builder: (context, provider, _) {
                final post = provider.postDetail;
                if (post == null) return const SizedBox();

                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        final reviewProvider = Provider.of<PostReviewProvider>(
                          context,
                          listen: false,
                        );
                        reviewProvider.fetchReviews(post.id);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) {
                            return Consumer<PostReviewProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (provider.reviews.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text("No comments yet."),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: ListView.builder(
                                    itemCount: provider.reviews.length,
                                    itemBuilder: (context, index) {
                                      final comment = provider.reviews[index];
                                      return ListTile(
                                        leading: const CircleAvatar(
                                          child: Icon(Icons.person),
                                        ),
                                        title: Text(comment.userName),
                                        subtitle: Text(comment.review),
                                        trailing: Text(
                                          "${comment.createdAt.toLocal()}"
                                              .split(' ')[0],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditPostScreen(post: post),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors
                                .white, // 🤍 Set dialog background to white
                            title: const Text("Delete Post"),
                            content: const Text(
                              "Are you sure you want to delete this post?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color:
                                        Colors.black, // 🖤 Cancel text in black
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .orange, // 🟧 Delete button in orange
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final success = await PostApiService().deletePost(
                            post.id,
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Post deleted successfully"),
                              ),
                            );
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to delete post"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<PostDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final post = provider.postDetail;
            if (post == null) {
              return const Center(child: Text("Failed to load post details."));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description

                      // Image carousel
                      if (post.postContents.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.postContents.length,
                            itemBuilder: (context, index) {
                              final imageUrl =
                                  "${ApiEndpoints.storageBaseUrl}/${post.postContents[index].contentPath}";
                              return Container(
                                width: 300,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        post.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.blue),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              post.postCategory.isNotEmpty
                                  ? post.postCategory[0].category.category
                                  : "Unknown",
                            ),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              post.postLocations.isNotEmpty
                                  ? post.postLocations[0].location.name
                                  : "Unknown",
                            ),
                            backgroundColor: Colors.green.shade50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
