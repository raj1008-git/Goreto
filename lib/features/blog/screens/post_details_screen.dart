// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../core/constants/api_endpoints.dart';
// import '../../../data/datasources/remote/post_api_service.dart';
// import '../../../data/providers/post_details_provider.dart';
// import '../../../data/providers/post_review_provider.dart';
// import 'edit_post.dart';
//
// class PostDetailScreen extends StatelessWidget {
//   final int postId;
//   const PostDetailScreen({super.key, required this.postId});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<PostDetailProvider>(
//       create: (_) => PostDetailProvider()..loadPostDetail(postId),
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           elevation: 1,
//           backgroundColor: Colors.white,
//           title: const Text(
//             "Post Details",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//           iconTheme: const IconThemeData(color: Colors.black),
//           actions: [
//             Consumer<PostDetailProvider>(
//               builder: (context, provider, _) {
//                 final post = provider.postDetail;
//                 if (post == null) return const SizedBox();
//
//                 return Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.comment),
//                       onPressed: () {
//                         final reviewProvider = Provider.of<PostReviewProvider>(
//                           context,
//                           listen: false,
//                         );
//                         reviewProvider.fetchReviews(post.id);
//
//                         showModalBottomSheet(
//                           context: context,
//                           isScrollControlled: true,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(16),
//                             ),
//                           ),
//                           builder: (_) {
//                             return Consumer<PostReviewProvider>(
//                               builder: (context, provider, _) {
//                                 if (provider.isLoading) {
//                                   return const Padding(
//                                     padding: EdgeInsets.all(20),
//                                     child: Center(
//                                       child: CircularProgressIndicator(),
//                                     ),
//                                   );
//                                 }
//
//                                 if (provider.reviews.isEmpty) {
//                                   return const Padding(
//                                     padding: EdgeInsets.all(20),
//                                     child: Text("No comments yet."),
//                                   );
//                                 }
//
//                                 return Padding(
//                                   padding: const EdgeInsets.all(20),
//                                   child: ListView.builder(
//                                     itemCount: provider.reviews.length,
//                                     itemBuilder: (context, index) {
//                                       final comment = provider.reviews[index];
//                                       return ListTile(
//                                         leading: const CircleAvatar(
//                                           child: Icon(Icons.person),
//                                         ),
//                                         title: Text(comment.userName),
//                                         subtitle: Text(comment.review),
//                                         trailing: Text(
//                                           "${comment.createdAt.toLocal()}"
//                                               .split(' ')[0],
//                                           style: const TextStyle(fontSize: 12),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.edit),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => EditPostScreen(post: post),
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete),
//                       onPressed: () async {
//                         final confirm = await showDialog<bool>(
//                           context: context,
//                           builder: (ctx) => AlertDialog(
//                             backgroundColor: Colors
//                                 .white, // 🤍 Set dialog background to white
//                             title: const Text("Delete Post"),
//                             content: const Text(
//                               "Are you sure you want to delete this post?",
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(ctx, false),
//                                 child: const Text(
//                                   "Cancel",
//                                   style: TextStyle(
//                                     color:
//                                         Colors.black, // 🖤 Cancel text in black
//                                   ),
//                                 ),
//                               ),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors
//                                       .orange, // 🟧 Delete button in orange
//                                 ),
//                                 onPressed: () => Navigator.pop(ctx, true),
//                                 child: const Text("Delete"),
//                               ),
//                             ],
//                           ),
//                         );
//
//                         if (confirm == true) {
//                           final success = await PostApiService().deletePost(
//                             post.id,
//                           );
//                           if (success && context.mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Post deleted successfully"),
//                               ),
//                             );
//                             Navigator.pop(context, true);
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Failed to delete post"),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                           }
//                         }
//                       },
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//         body: Consumer<PostDetailProvider>(
//           builder: (context, provider, _) {
//             if (provider.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             final post = provider.postDetail;
//             if (post == null) {
//               return const Center(child: Text("Failed to load post details."));
//             }
//
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Card(
//                 color: Colors.white,
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Description
//
//                       // Image carousel
//                       if (post.postContents.isNotEmpty)
//                         SizedBox(
//                           height: 200,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: post.postContents.length,
//                             itemBuilder: (context, index) {
//                               final imageUrl =
//                                   "${ApiEndpoints.storageBaseUrl}/${post.postContents[index].contentPath}";
//                               return Container(
//                                 width: 300,
//                                 margin: const EdgeInsets.only(right: 12),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   image: DecorationImage(
//                                     image: NetworkImage(imageUrl),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 20),
//                       Text(
//                         post.description,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Category
//                       Row(
//                         children: [
//                           const Icon(Icons.category, color: Colors.blue),
//                           const SizedBox(width: 8),
//                           Chip(
//                             label: Text(
//                               post.postCategory.isNotEmpty
//                                   ? post.postCategory[0].category.category
//                                   : "Unknown",
//                             ),
//                             backgroundColor: Colors.blue.shade50,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Location
//                       Row(
//                         children: [
//                           const Icon(Icons.location_on, color: Colors.green),
//                           const SizedBox(width: 8),
//                           Chip(
//                             label: Text(
//                               post.postLocations.isNotEmpty
//                                   ? post.postLocations[0].location.name
//                                   : "Unknown",
//                             ),
//                             backgroundColor: Colors.green.shade50,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/appColors.dart';
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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Post Details",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: [
            Consumer<PostDetailProvider>(
              builder: (context, provider, _) {
                final post = provider.postDetail;
                if (post == null) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        color: AppColors.primary,
                        onPressed: () =>
                            _showCommentsBottomSheet(context, post.id),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.secondary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPostScreen(post: post),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        color: Colors.red[400]!,
                        onPressed: () => _showDeleteDialog(context, post),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<PostDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading post details...",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final post = provider.postDetail;
            if (post == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to load post details",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image carousel with enhanced styling
                      if (post.postContents.isNotEmpty) ...[
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.postContents.length,
                            itemBuilder: (context, index) {
                              final imageUrl =
                                  "${ApiEndpoints.storageBaseUrl}/${post.postContents[index].contentPath}";
                              return Container(
                                width: 320,
                                margin: EdgeInsets.only(
                                  right: index == post.postContents.length - 1
                                      ? 0
                                      : 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Description with enhanced typography
                      Text(
                        post.description,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Enhanced Category and Location chips
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.category_outlined,
                              label: post.postCategory.isNotEmpty
                                  ? post.postCategory[0].category.category
                                  : "Unknown",
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.location_on_outlined,
                              label: post.postLocations.isNotEmpty
                                  ? post.postLocations[0].location.name
                                  : "Unknown",
                              color: AppColors.secondary,
                            ),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 22,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, int postId) {
    final reviewProvider = Provider.of<PostReviewProvider>(
      context,
      listen: false,
    );
    reviewProvider.fetchReviews(postId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Comments",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey[200], height: 1),

              // Comments list
              Expanded(
                child: Consumer<PostReviewProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Loading comments...",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.reviews.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No comments yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Be the first to comment!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.reviews.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = provider.reviews[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          "${comment.createdAt.toLocal()}"
                                              .split(' ')[0],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                comment.review,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, dynamic post) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Delete Post",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to delete this post? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final success = await PostApiService().deletePost(post.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Post deleted successfully"),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text("Failed to delete post"),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
