// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../data/models/post/social_post_model.dart';
// import '../../../data/providers/social_post_provider.dart';
// import '../../../features/bookmarks/book_mark_screen.dart';
// // ✅ Step 5: Import BookmarksScreen
//
// class NewsfeedScreen extends StatelessWidget {
//   const NewsfeedScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => SocialPostApiProvider()..fetchPosts(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Goreto Feed'),
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.bookmark),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const BookmarksScreen()),
//                 );
//               },
//               tooltip: 'Bookmarks',
//             ),
//           ],
//         ),
//         body: Consumer<SocialPostApiProvider>(
//           builder: (context, provider, _) {
//             if (provider.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (provider.posts.isEmpty) {
//               return const Center(child: Text("No posts available."));
//             }
//
//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               itemCount: provider.posts.length,
//               itemBuilder: (context, index) {
//                 final post = provider.posts[index];
//                 return PostCard(post: post);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class PostCard extends StatefulWidget {
//   final PostModel post;
//
//   const PostCard({super.key, required this.post});
//
//   @override
//   State<PostCard> createState() => _PostCardState();
// }
//
// class _PostCardState extends State<PostCard> {
//   bool isBookmarked = false;
//   bool showFullText = false;
//
//   void _toggleBookmark(BuildContext context) async {
//     final provider = Provider.of<SocialPostApiProvider>(context, listen: false);
//     final message = await provider.toggleBookmark(widget.post.id);
//     setState(() => isBookmarked = !isBookmarked);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final description = widget.post.description;
//     final displayText = showFullText || description.length < 120
//         ? description
//         : '${description.substring(0, 120)}...';
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Post Image with Bookmark
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(16),
//                 ),
//                 child: Image.network(
//                   widget.post.imageUrl,
//                   height: 220,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     height: 220,
//                     color: Colors.grey[200],
//                     child: const Center(child: Icon(Icons.image_not_supported)),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 12,
//                 right: 12,
//                 child: GestureDetector(
//                   onTap: () => _toggleBookmark(context),
//                   child: Icon(
//                     isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
//                     color: isBookmarked ? Colors.amber : Colors.white,
//                     size: 28,
//                     shadows: const [
//                       Shadow(
//                         blurRadius: 4,
//                         color: Colors.black45,
//                         offset: Offset(1, 1),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           // Post Description & Metadata
//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   displayText,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 if (description.length > 120)
//                   TextButton(
//                     onPressed: () =>
//                         setState(() => showFullText = !showFullText),
//                     child: Text(showFullText ? "Show less" : "Show more"),
//                   ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     const Icon(Icons.place, size: 16, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text(
//                       widget.post.location,
//                       style: const TextStyle(fontSize: 13, color: Colors.grey),
//                     ),
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.blue.shade50,
//                       ),
//                       child: Text(
//                         widget.post.category,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontStyle: FontStyle.italic,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/social_post_provider.dart';
import '../../../features/blog/widgets/post_card.dart';

class NewsfeedScreen extends StatelessWidget {
  const NewsfeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SocialPostApiProvider()..fetchPosts(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: _buildAppBar(context),
        body: Consumer<SocialPostApiProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return _buildLoadingState();
            }

            if (provider.posts.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchPosts(),
              color: const Color(0xFF6366F1),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: provider.posts.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final post = provider.posts[index];
                  return PostCard(post: post);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/logos/goreto.png',
              width: 55,
              height: 55,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Goreto Feed',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Loading amazing posts...',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.post_add_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to share something amazing!',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
