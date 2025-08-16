// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../core/constants/appColors.dart';
// import '../../../data/models/post/comment_model.dart';
// import '../../../data/models/post/social_post_model.dart';
// import '../../../data/providers/like_and_comment_provider.dart';
// import '../../../data/providers/social_post_provider.dart';
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
// class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
//   bool isBookmarked = false;
//   bool showFullText = false;
//   late AnimationController _likeController;
//   late AnimationController _cardController;
//   late Animation<double> _likeAnimation;
//   late Animation<double> _cardAnimation;
//
//   final TextEditingController _commentController = TextEditingController();
//   final FocusNode _commentFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     _likeController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _cardController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
//     );
//     _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
//     );
//
//     _cardController.forward();
//
//     // Initialize post data in provider
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final likeProvider = Provider.of<LikeCommentProvider>(
//         context,
//         listen: false,
//       );
//       likeProvider.initializePost(widget.post.id, 0);
//       likeProvider.fetchPostLikers(widget.post.id);
//     });
//   }
//
//   @override
//   void dispose() {
//     _likeController.dispose();
//     _cardController.dispose();
//     _commentController.dispose();
//     _commentFocusNode.dispose();
//     super.dispose();
//   }
//
//   void _showSnackBar(String message, Color color, IconData icon) {
//     if (!context.mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: Colors.white, size: 20),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               message,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//             ),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         margin: const EdgeInsets.all(20),
//         duration: const Duration(seconds: 2),
//         elevation: 0,
//       ),
//     );
//   }
//
//   void _toggleBookmark(BuildContext context) async {
//     setState(() => isBookmarked = !isBookmarked);
//
//     final message = isBookmarked
//         ? '✨ Post bookmarked!'
//         : '📝 Bookmark removed!';
//     final color = isBookmarked ? AppColors.primary : AppColors.secondary;
//     final icon = isBookmarked
//         ? Icons.bookmark_added_rounded
//         : Icons.bookmark_remove_rounded;
//
//     _showSnackBar(message, color, icon);
//
//     try {
//       final provider = Provider.of<SocialPostApiProvider>(
//         context,
//         listen: false,
//       );
//       await provider.toggleBookmark(widget.post.id);
//     } catch (e) {
//       if (mounted) {
//         setState(() => isBookmarked = !isBookmarked);
//         _showSnackBar(
//           'Failed to update bookmark',
//           const Color(0xFFEF4444),
//           Icons.error_outline_rounded,
//         );
//       }
//     }
//   }
//
//   void _handleLike() async {
//     final likeProvider = Provider.of<LikeCommentProvider>(
//       context,
//       listen: false,
//     );
//
//     _likeController.forward().then((_) => _likeController.reverse());
//
//     final currentLikeCount = likeProvider.getLikeCount(widget.post.id);
//     final wasLiked = currentLikeCount > 0;
//
//     likeProvider.setOptimisticLike(widget.post.id, !wasLiked);
//
//     final message = !wasLiked ? '❤️ Post liked!' : '💔 Like removed!';
//     final color = !wasLiked ? Colors.blue : const Color(0xFF6B7280);
//     final icon = !wasLiked
//         ? Icons.favorite_rounded
//         : Icons.favorite_border_rounded;
//
//     _showSnackBar(message, color, icon);
//
//     try {
//       await likeProvider.toggleLike(widget.post.id);
//     } catch (e) {
//       likeProvider.setOptimisticLike(widget.post.id, wasLiked);
//       _showSnackBar(
//         'Failed to update like',
//         const Color(0xFFEF4444),
//         Icons.error_outline_rounded,
//       );
//     }
//   }
//
//   void _showLikers() {
//     final likeProvider = Provider.of<LikeCommentProvider>(
//       context,
//       listen: false,
//     );
//     final likers = likeProvider.getLikers(widget.post.id);
//
//     if (likers.isEmpty) return;
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 48,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE5E7EB),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFFEF4444).withOpacity(0.3),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.favorite_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 const Text(
//                   'Liked by',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF111827),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             ...likers.map((liker) => _buildLikerItem(liker)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLikerItem(dynamic liker) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFF1F5F9)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _buildAvatar(liker.profilePictureUrl, liker.name, 26),
//           const SizedBox(width: 16),
//           Text(
//             liker.name,
//             style: const TextStyle(
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF111827),
//               fontSize: 17,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _addComment() async {
//     if (_commentController.text.trim().isEmpty) return;
//
//     final commentText = _commentController.text.trim();
//     final likeProvider = Provider.of<LikeCommentProvider>(
//       context,
//       listen: false,
//     );
//
//     _commentController.clear();
//     _commentFocusNode.unfocus();
//
//     likeProvider.addOptimisticComment(widget.post.id, commentText);
//     _showSnackBar(
//       '💬 Comment added!',
//       const Color(0xFF10B981),
//       Icons.chat_bubble_rounded,
//     );
//
//     try {
//       final success = await likeProvider.addComment(
//         widget.post.id,
//         commentText,
//       );
//       if (!success) throw Exception('Failed to add comment');
//     } catch (e) {
//       likeProvider.removeOptimisticComment(widget.post.id);
//       _showSnackBar(
//         'Failed to add comment',
//         const Color(0xFFEF4444),
//         Icons.error_outline_rounded,
//       );
//     }
//   }
//
//   Widget _buildAvatar(String? imageUrl, String name, double radius) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primary.withOpacity(0.1),
//             AppColors.primary.withOpacity(0.05),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.2),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: CircleAvatar(
//         radius: radius,
//         backgroundColor: Colors.transparent,
//         backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//         child: imageUrl == null
//             ? Text(
//                 name.isNotEmpty ? name[0].toUpperCase() : 'U',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   color: AppColors.primary,
//                   fontSize: radius * 0.7,
//                 ),
//               )
//             : null,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final description = widget.post.description;
//     final displayText = showFullText || description.length < 120
//         ? description
//         : '${description.substring(0, 120)}...';
//
//     return Consumer<LikeCommentProvider>(
//       builder: (context, likeProvider, child) {
//         final likeCount = likeProvider.getLikeCount(widget.post.id);
//         final commentCount = likeProvider.getCommentCount(widget.post.id);
//         final isShowingComments = likeProvider.isShowingComments(
//           widget.post.id,
//         );
//         final comments = likeProvider.getComments(widget.post.id);
//         final isCommentLoading = likeProvider.isCommentLoading(widget.post.id);
//
//         return AnimatedBuilder(
//           animation: _cardAnimation,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _cardAnimation.value,
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 20),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(28),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       blurRadius: 30,
//                       offset: const Offset(0, 10),
//                     ),
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.02),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildUserHeader(),
//                     _buildImageSection(),
//                     _buildContentSection(displayText, description),
//                     _buildActionButtons(likeCount, commentCount),
//                     if (isShowingComments) ...[
//                       _buildCommentInput(),
//                       if (isCommentLoading)
//                         _buildLoadingIndicator()
//                       else
//                         _buildCommentsList(comments),
//                     ],
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildUserHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         children: [
//           _buildAvatar(
//             widget.post.userProfilePicture,
//             widget.post.userName,
//             28,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.post.userName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 18,
//                     color: Color(0xFF111827),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFE2E8F0)),
//                   ),
//                   child: Text(
//                     DateFormat(
//                       'MMM dd, yyyy • hh:mm a',
//                     ).format(widget.post.createdAt),
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF64748B),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImageSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: AspectRatio(
//               aspectRatio: 16 / 10,
//               child: Container(
//                 decoration: BoxDecoration(
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.12),
//                       blurRadius: 24,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Image.network(
//                   widget.post.imageUrl,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   errorBuilder: (context, error, stackTrace) =>
//                       _buildImageError(),
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return _buildImageLoading(loadingProgress);
//                   },
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 16,
//             right: 16,
//             child: GestureDetector(
//               onTap: () => _toggleBookmark(context),
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: isBookmarked
//                         ? AppColors.primary.withOpacity(0.3)
//                         : const Color(0xFFE2E8F0),
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   isBookmarked
//                       ? Icons.bookmark_rounded
//                       : Icons.bookmark_border_rounded,
//                   color: isBookmarked
//                       ? AppColors.primary
//                       : const Color(0xFF64748B),
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImageError() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.image_not_supported_rounded,
//                 size: 40,
//                 color: AppColors.primary.withOpacity(0.6),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Image not available',
//               style: TextStyle(
//                 color: AppColors.primary.withOpacity(0.8),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageLoading(ImageChunkEvent loadingProgress) {
//     return Container(
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 50,
//               height: 50,
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                           loadingProgress.expectedTotalBytes!
//                     : null,
//                 strokeWidth: 4,
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Loading image...',
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContentSection(String displayText, String fullDescription) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             displayText,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Color(0xFF334155),
//               height: 1.6,
//               letterSpacing: 0.1,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           if (fullDescription.length > 120)
//             GestureDetector(
//               onTap: () => setState(() => showFullText = !showFullText),
//               child: Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppColors.primary.withOpacity(0.1),
//                       AppColors.primary.withOpacity(0.05),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(24),
//                   border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       showFullText ? 'Show less' : 'Read more',
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       showFullText
//                           ? Icons.keyboard_arrow_up_rounded
//                           : Icons.keyboard_arrow_down_rounded,
//                       color: AppColors.primary,
//                       size: 18,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(int likeCount, int commentCount) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//       child: Column(
//         children: [
//           const Divider(),
//           Row(
//             children: [
//               // Like Button
//               GestureDetector(
//                 onTap: _handleLike,
//                 onLongPress: likeCount > 0 ? _showLikers : null,
//                 child: AnimatedBuilder(
//                   animation: _likeAnimation,
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: _likeAnimation.value,
//                       child: _buildActionButton(
//                         icon: likeCount > 0
//                             ? Icons.favorite_rounded
//                             : Icons.favorite_border_rounded,
//                         count: likeCount,
//                         label: likeCount == 1 ? 'like' : 'likes',
//                         isActive: likeCount > 0,
//                         activeColors: [
//                           const Color(0xFFEF4444),
//                           const Color(0xFFDC2626),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Comment Button
//               Consumer<LikeCommentProvider>(
//                 builder: (context, provider, child) {
//                   final isShowingComments = provider.isShowingComments(
//                     widget.post.id,
//                   );
//                   return GestureDetector(
//                     onTap: () =>
//                         provider.toggleCommentsVisibility(widget.post.id),
//                     child: _buildActionButton(
//                       icon: isShowingComments
//                           ? Icons.chat_bubble_rounded
//                           : Icons.chat_bubble_outline_rounded,
//                       count: commentCount,
//                       label: '',
//                       isActive: isShowingComments,
//                       activeColors: [
//                         AppColors.primary,
//                         AppColors.primary.withOpacity(0.8),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required int count,
//     required String label,
//     required bool isActive,
//     required List<Color> activeColors,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         gradient: isActive ? LinearGradient(colors: activeColors) : null,
//         color: isActive ? null : const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: isActive ? Colors.transparent : const Color(0xFFE2E8F0),
//           width: 2,
//         ),
//         boxShadow: isActive
//             ? [
//                 BoxShadow(
//                   color: activeColors[0].withOpacity(0.3),
//                   blurRadius: 16,
//                   offset: const Offset(0, 4),
//                 ),
//               ]
//             : null,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: isActive ? Colors.white : const Color(0xFF64748B),
//             size: 22,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '$count',
//             style: TextStyle(
//               fontWeight: FontWeight.w800,
//               fontSize: 16,
//               color: isActive ? Colors.white : const Color(0xFF64748B),
//             ),
//           ),
//           if (isActive && label.isNotEmpty) ...[
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//                 color: Colors.white.withOpacity(0.9),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCommentInput() {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.6)),
//         ),
//         color: Colors.transparent,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(28),
//                 border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 12,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _commentController,
//                 focusNode: _commentFocusNode,
//                 decoration: const InputDecoration(
//                   hintText: 'Share your thoughts...',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 16,
//                   ),
//                   hintStyle: TextStyle(
//                     color: Color(0xFF94A3B8),
//                     fontWeight: FontWeight.w500,
//                     fontSize: 15,
//                   ),
//                 ),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF334155),
//                   height: 1.4,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: null,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (_) => _addComment(),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           GestureDetector(
//             onTap: _addComment,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.primary,
//                     AppColors.primary.withOpacity(0.8),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primary.withOpacity(0.4),
//                     blurRadius: 16,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.send_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingIndicator() {
//     return Container(
//       padding: const EdgeInsets.all(32),
//       child: Center(
//         child: Column(
//           children: [
//             SizedBox(
//               width: 40,
//               height: 40,
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Loading comments...',
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCommentsList(List<CommentModel> comments) {
//     if (comments.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.primary.withOpacity(0.1),
//                     AppColors.primary.withOpacity(0.05),
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primary.withOpacity(0.2),
//                     blurRadius: 20,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.chat_bubble_outline_rounded,
//                 size: 40,
//                 color: AppColors.primary.withOpacity(0.7),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'No comments yet',
//               style: TextStyle(
//                 color: Color(0xFF64748B),
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Be the first to share your thoughts!',
//               style: TextStyle(
//                 color: Color(0xFF94A3B8),
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Container(
//       decoration: const BoxDecoration(color: Color(0xFFFAFBFC)),
//       child: Column(
//         children: comments
//             .map((comment) => _buildCommentItem(comment))
//             .toList(),
//       ),
//     );
//   }
//
//   Widget _buildCommentItem(CommentModel comment) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFE2E8F0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildAvatar(comment.user.profilePictureUrl, comment.user.name, 22),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       comment.user.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 16,
//                         color: Color(0xFF111827),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF1F5F9),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: const Color(0xFFE2E8F0)),
//                       ),
//                       child: Text(
//                         DateFormat('MMM dd, hh:mm a').format(comment.createdAt),
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: Color(0xFF64748B),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   comment.review,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFF334155),
//                     height: 1.6,
//                     letterSpacing: 0.1,
//                     fontWeight: FontWeight.w500,
//                   ),
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../core/services/dio_client.dart';
import '../../../data/models/post/comment_model.dart';
import '../../../data/models/post/social_post_model.dart';
import '../../../data/providers/like_and_comment_provider.dart';
import '../../../data/providers/social_post_provider.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  bool isBookmarked = false;
  bool showFullText = false;
  late AnimationController _likeController;
  late AnimationController _cardController;
  late Animation<double> _likeAnimation;
  late Animation<double> _cardAnimation;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _cardController.forward();

    // Initialize post data in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final likeProvider = Provider.of<LikeCommentProvider>(
        context,
        listen: false,
      );
      likeProvider.initializePost(widget.post.id, 0);
      likeProvider.fetchPostLikers(widget.post.id);
    });
  }

  @override
  void dispose() {
    _likeController.dispose();
    _cardController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        elevation: 0,
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.report_outlined,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Report Post',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Why are you reporting this post?',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            _buildReportOption('Spam', 'spam', Icons.block_outlined),
            _buildReportOption(
              'Harassment',
              'harassment',
              Icons.person_remove_outlined,
            ),
            _buildReportOption(
              'Inappropriate Content',
              'inappropriate',
              Icons.warning_outlined,
            ),
            _buildReportOption(
              'Fake Information',
              'misinformation',
              Icons.fact_check_outlined,
            ),
            _buildReportOption('Other', 'other', Icons.more_horiz_outlined),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String title, String offenseType, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          _reportPost(offenseType);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: const Color(0xFFF8FAFC),
      ),
    );
  }

  Future<void> _reportPost(String offenseType) async {
    try {
      final dio = DioClient().dio;
      await dio.post(
        '/post-report/${widget.post.id}',
        data: {'offense_type': offenseType},
      );

      _showSnackBar(
        '🚨 Post reported successfully',
        Colors.green,
        Icons.report_rounded,
      );
    } catch (e) {
      _showSnackBar(
        'Already Reported',
        const Color(0xFFEF4444),
        Icons.error_outline_rounded,
      );
    }
  }

  void _toggleBookmark(BuildContext context) async {
    setState(() => isBookmarked = !isBookmarked);

    final message = isBookmarked
        ? '✨ Post bookmarked!'
        : '📝 Bookmark removed!';
    final color = isBookmarked ? AppColors.primary : AppColors.secondary;
    final icon = isBookmarked
        ? Icons.bookmark_added_rounded
        : Icons.bookmark_remove_rounded;

    _showSnackBar(message, color, icon);

    try {
      final provider = Provider.of<SocialPostApiProvider>(
        context,
        listen: false,
      );
      await provider.toggleBookmark(widget.post.id);
    } catch (e) {
      if (mounted) {
        setState(() => isBookmarked = !isBookmarked);
        _showSnackBar(
          'Failed to update bookmark',
          const Color(0xFFEF4444),
          Icons.error_outline_rounded,
        );
      }
    }
  }

  void _handleLike() async {
    final likeProvider = Provider.of<LikeCommentProvider>(
      context,
      listen: false,
    );

    _likeController.forward().then((_) => _likeController.reverse());

    final currentLikeCount = likeProvider.getLikeCount(widget.post.id);
    final wasLiked = currentLikeCount > 0;

    likeProvider.setOptimisticLike(widget.post.id, !wasLiked);

    final message = !wasLiked ? '❤️ Post liked!' : '💔 Like removed!';
    final color = !wasLiked ? Colors.blue : const Color(0xFF6B7280);
    final icon = !wasLiked
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;

    _showSnackBar(message, color, icon);

    try {
      await likeProvider.toggleLike(widget.post.id);
    } catch (e) {
      likeProvider.setOptimisticLike(widget.post.id, wasLiked);
      _showSnackBar(
        'Failed to update like',
        const Color(0xFFEF4444),
        Icons.error_outline_rounded,
      );
    }
  }

  void _showLikers() {
    final likeProvider = Provider.of<LikeCommentProvider>(
      context,
      listen: false,
    );
    final likers = likeProvider.getLikers(widget.post.id);

    if (likers.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Liked by',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...likers.map((liker) => _buildLikerItem(liker)),
          ],
        ),
      ),
    );
  }

  Widget _buildLikerItem(dynamic liker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(liker.profilePictureUrl, liker.name, 26),
          const SizedBox(width: 16),
          Text(
            liker.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final commentText = _commentController.text.trim();
    final likeProvider = Provider.of<LikeCommentProvider>(
      context,
      listen: false,
    );

    _commentController.clear();
    _commentFocusNode.unfocus();

    likeProvider.addOptimisticComment(widget.post.id, commentText);
    _showSnackBar(
      '💬 Comment added!',
      const Color(0xFF10B981),
      Icons.chat_bubble_rounded,
    );

    try {
      final success = await likeProvider.addComment(
        widget.post.id,
        commentText,
      );
      if (!success) throw Exception('Failed to add comment');
    } catch (e) {
      likeProvider.removeOptimisticComment(widget.post.id);
      _showSnackBar(
        'Failed to add comment',
        const Color(0xFFEF4444),
        Icons.error_outline_rounded,
      );
    }
  }

  Widget _buildAvatar(String? imageUrl, String name, double radius) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: radius * 0.7,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.post.description;
    final displayText = showFullText || description.length < 120
        ? description
        : '${description.substring(0, 120)}...';

    return Consumer<LikeCommentProvider>(
      builder: (context, likeProvider, child) {
        final likeCount = likeProvider.getLikeCount(widget.post.id);
        final commentCount = likeProvider.getCommentCount(widget.post.id);
        final isShowingComments = likeProvider.isShowingComments(
          widget.post.id,
        );
        final comments = likeProvider.getComments(widget.post.id);
        final isCommentLoading = likeProvider.isCommentLoading(widget.post.id);

        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(),
                _buildImageSection(),
                _buildContentSection(displayText, description),
                _buildActionButtons(likeCount, commentCount),
                if (isShowingComments) ...[
                  _buildCommentInput(),
                  if (isCommentLoading)
                    _buildLoadingIndicator()
                  else
                    _buildCommentsList(comments),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildAvatar(
            widget.post.userProfilePicture,
            widget.post.userName,
            28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(widget.post.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Report button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog();
              }
            },
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.report_outlined,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Report Post',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImageError(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImageLoading(loadingProgress);
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _toggleBookmark(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isBookmarked
                        ? AppColors.primary.withOpacity(0.3)
                        : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isBookmarked
                      ? AppColors.primary
                      : const Color(0xFF64748B),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_not_supported_rounded,
                size: 40,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Image not available',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageLoading(ImageChunkEvent loadingProgress) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading image...',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(String displayText, String fullDescription) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF334155),
              height: 1.6,
              letterSpacing: 0.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (fullDescription.length > 120)
            GestureDetector(
              onTap: () => setState(() => showFullText = !showFullText),
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showFullText ? 'Show less' : 'Read more',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      showFullText
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(int likeCount, int commentCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          const Divider(),
          Row(
            children: [
              // Like Button
              GestureDetector(
                onTap: _handleLike,
                onLongPress: likeCount > 0 ? _showLikers : null,
                child: Transform.scale(
                  scale: _likeAnimation.value,
                  child: _buildActionButton(
                    icon: likeCount > 0
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    count: likeCount,
                    label: likeCount == 1 ? 'like' : 'likes',
                    isActive: likeCount > 0,
                    activeColors: [
                      const Color(0xFFEF4444),
                      const Color(0xFFDC2626),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Comment Button
              Consumer<LikeCommentProvider>(
                builder: (context, provider, child) {
                  final isShowingComments = provider.isShowingComments(
                    widget.post.id,
                  );
                  return GestureDetector(
                    onTap: () =>
                        provider.toggleCommentsVisibility(widget.post.id),
                    child: _buildActionButton(
                      icon: isShowingComments
                          ? Icons.chat_bubble_rounded
                          : Icons.chat_bubble_outline_rounded,
                      count: commentCount,
                      label: '',
                      isActive: isShowingComments,
                      activeColors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required String label,
    required bool isActive,
    required List<Color> activeColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: isActive ? LinearGradient(colors: activeColors) : null,
        color: isActive ? null : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? Colors.transparent : const Color(0xFFE2E8F0),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColors[0].withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFF64748B),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
          if (isActive && label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.6)),
        ),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF334155),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _addComment,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading comments...',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(List<CommentModel> comments) {
    if (comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No comments yet',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to share your thoughts!',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFAFBFC)),
      child: Column(
        children: comments
            .map((comment) => _buildCommentItem(comment))
            .toList(),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(comment.user.profilePictureUrl, comment.user.name, 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        DateFormat('MMM dd, hh:mm a').format(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  comment.review,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF334155),
                    height: 1.6,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
