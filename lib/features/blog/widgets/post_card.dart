import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
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

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool isBookmarked = false;
  bool showFullText = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final TextEditingController _commentController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializePostData();
  }

  void _initializePostData() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<LikeCommentProvider>();
          provider.initializePost(widget.post.id, 0);
          provider.fetchPostLikers(widget.post.id);
          setState(() => _isInitialized = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _animateButton() {
    _animationController.forward().then((_) {
      if (mounted) _animationController.reverse();
    });
  }

  void _toggleBookmark() async {
    if (!mounted) return;

    setState(() => isBookmarked = !isBookmarked);
    _animateButton();

    _showSnackBar(
      icon: isBookmarked
          ? Icons.bookmark_added_rounded
          : Icons.bookmark_remove_rounded,
      message: isBookmarked ? '✨ Post bookmarked!' : '📝 Bookmark removed!',
      color: isBookmarked ? AppColors.primary : AppColors.secondary,
    );

    try {
      if (mounted) {
        await context.read<SocialPostApiProvider>().toggleBookmark(
          widget.post.id,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isBookmarked = !isBookmarked);
        _showSnackBar(
          icon: Icons.error_outline_rounded,
          message: 'Failed to update bookmark',
          color: Colors.red,
        );
      }
    }
  }

  void _handleLike() async {
    if (!mounted) return;

    final provider = context.read<LikeCommentProvider>();
    _animateButton();

    final currentLikeCount = provider.getLikeCount(widget.post.id);
    final wasLiked = currentLikeCount > 0;

    provider.setOptimisticLike(widget.post.id, !wasLiked);

    _showSnackBar(
      icon: !wasLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      message: !wasLiked ? '❤️ Post liked!' : '💔 Like removed!',
      color: !wasLiked ? Colors.red : Colors.grey,
    );

    try {
      await provider.toggleLike(widget.post.id);
    } catch (e) {
      if (mounted) {
        provider.setOptimisticLike(widget.post.id, wasLiked);
        _showSnackBar(
          icon: Icons.error_outline_rounded,
          message: 'Failed to update like',
          color: Colors.red,
        );
      }
    }
  }

  void _addComment() async {
    if (!mounted || _commentController.text.trim().isEmpty) return;

    final commentText = _commentController.text.trim();
    final provider = context.read<LikeCommentProvider>();

    _commentController.clear();
    FocusScope.of(context).unfocus();

    provider.addOptimisticComment(widget.post.id, commentText);

    _showSnackBar(
      icon: Icons.chat_bubble_rounded,
      message: '💬 Comment added!',
      color: Colors.green,
    );

    try {
      final success = await provider.addComment(widget.post.id, commentText);
      if (!success) throw Exception('Failed to add comment');
    } catch (e) {
      if (mounted) {
        provider.removeOptimisticComment(widget.post.id);
        _showSnackBar(
          icon: Icons.error_outline_rounded,
          message: 'Failed to add comment',
          color: Colors.red,
        );
      }
    }
  }

  void _showSnackBar({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cardMargin = screenWidth * 0.04;
    final cardPadding = screenWidth * 0.04;

    if (!_isInitialized) {
      return Container(
        margin: EdgeInsets.all(cardMargin),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final description = widget.post.description;
    final maxLength = isTablet ? 200 : 120;
    final displayText = showFullText || description.length <= maxLength
        ? description
        : '${description.substring(0, maxLength)}...';

    return Consumer<LikeCommentProvider>(
      builder: (context, provider, _) {
        final likeCount = provider.getLikeCount(widget.post.id);
        final commentCount = provider.getCommentCount(widget.post.id);
        final isShowingComments = provider.isShowingComments(widget.post.id);
        final comments = provider.getComments(widget.post.id);
        final isCommentLoading = provider.isCommentLoading(widget.post.id);

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : double.infinity,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: cardMargin,
            vertical: cardMargin * 0.5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(cardPadding, isTablet),
              _buildImage(),
              _buildContent(cardPadding, displayText, description, maxLength),
              _buildActions(
                cardPadding,
                likeCount,
                commentCount,
                isShowingComments,
                provider,
              ),
              if (isShowingComments) ...[
                const Divider(height: 1),
                _buildCommentInput(cardPadding),
                if (isCommentLoading)
                  Container(
                    height: 60,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else
                  _buildCommentsList(comments, cardPadding),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(double padding, bool isTablet) {
    final avatarSize = isTablet ? 28.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarSize,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: widget.post.userProfilePicture != null
                ? NetworkImage(widget.post.userProfilePicture!)
                : null,
            child: widget.post.userProfilePicture == null
                ? Text(
                    widget.post.userName.isNotEmpty
                        ? widget.post.userName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: avatarSize * 0.6,
                    ),
                  )
                : null,
          ),
          SizedBox(width: padding * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.post.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat(
                    'MMM dd, yyyy • hh:mm a',
                  ).format(widget.post.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300, minHeight: 200),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              widget.post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, _) => Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onTap: _toggleBookmark,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked
                          ? AppColors.primary
                          : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    double padding,
    String displayText,
    String fullDescription,
    int maxLength,
  ) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(displayText, style: const TextStyle(fontSize: 14, height: 1.4)),
          if (fullDescription.length > maxLength)
            GestureDetector(
              onTap: () => setState(() => showFullText = !showFullText),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  showFullText ? 'Show less' : 'Read more',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(
    double padding,
    int likeCount,
    int commentCount,
    bool isShowingComments,
    LikeCommentProvider provider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.5,
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, _) => Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildActionButton(
                icon: likeCount > 0 ? Icons.favorite : Icons.favorite_border,
                count: '$likeCount',
                isActive: likeCount > 0,
                onTap: _handleLike,
                onLongPress: likeCount > 0 ? () => _showLikers(provider) : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: isShowingComments
                ? Icons.chat_bubble
                : Icons.chat_bubble_outline,
            count: '$commentCount',
            isActive: isShowingComments,
            onTap: () => provider.toggleCommentsVisibility(widget.post.id),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String count,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLikers(LikeCommentProvider provider) {
    final likers = provider.getLikers(widget.post.id);
    if (likers.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Liked by',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: likers.length,
                itemBuilder: (context, index) {
                  final liker = likers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: liker.profilePictureUrl != null
                          ? NetworkImage(liker.profilePictureUrl!)
                          : null,
                      child: liker.profilePictureUrl == null
                          ? Text(
                              liker.name.isNotEmpty
                                  ? liker.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(color: AppColors.primary),
                            )
                          : null,
                    ),
                    title: Text(liker.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _addComment(),
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _addComment,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<CommentModel> comments, double padding) {
    if (comments.isEmpty) {
      return Container(
        height: 100,
        child: const Center(
          child: Text(
            'No comments yet\nBe the first to share your thoughts!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: padding),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: comment.user.profilePictureUrl != null
                      ? NetworkImage(comment.user.profilePictureUrl!)
                      : null,
                  child: comment.user.profilePictureUrl == null
                      ? Text(
                          comment.user.name.isNotEmpty
                              ? comment.user.name[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              comment.user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd').format(comment.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.review,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../../../core/constants/appColors.dart';
// import '../../../data/models/post/comment_model.dart';
// import '../../../data/models/post/social_post_model.dart';
// import '../../../data/providers/like_and_comment_provider.dart';
// import '../../../data/providers/social_post_provider.dart';

// class PostCard extends StatefulWidget {
//   final PostModel post;

//   const PostCard({super.key, required this.post});

//   @override
//   State<PostCard> createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard>
//     with SingleTickerProviderStateMixin {
//   bool isBookmarked = false;
//   bool showFullText = false;
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;

//   final TextEditingController _commentController = TextEditingController();
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _initializePostData();
//   }

//   void _initializePostData() {
//     if (!_isInitialized) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           final provider = context.read<LikeCommentProvider>();
//           provider.initializePost(widget.post.id, 0);
//           provider.fetchPostLikers(widget.post.id);
//           setState(() => _isInitialized = true);
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _commentController.dispose();
//     super.dispose();
//   }

//   void _animateButton() {
//     _animationController.forward().then((_) {
//       if (mounted) _animationController.reverse();
//     });
//   }

//   void _toggleBookmark() async {
//     if (!mounted) return;

//     setState(() => isBookmarked = !isBookmarked);
//     _animateButton();

//     _showSnackBar(
//       icon: isBookmarked
//           ? Icons.bookmark_added_rounded
//           : Icons.bookmark_remove_rounded,
//       message: isBookmarked ? '✨ Post bookmarked!' : '📝 Bookmark removed!',
//       color: isBookmarked ? AppColors.primary : AppColors.secondary,
//     );

//     try {
//       if (mounted) {
//         await context.read<SocialPostApiProvider>().toggleBookmark(
//           widget.post.id,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => isBookmarked = !isBookmarked);
//         _showSnackBar(
//           icon: Icons.error_outline_rounded,
//           message: 'Failed to update bookmark',
//           color: Colors.red,
//         );
//       }
//     }
//   }

//   void _handleLike() async {
//     if (!mounted) return;

//     final provider = context.read<LikeCommentProvider>();
//     _animateButton();

//     final currentLikeCount = provider.getLikeCount(widget.post.id);
//     final wasLiked = currentLikeCount > 0;

//     provider.setOptimisticLike(widget.post.id, !wasLiked);

//     _showSnackBar(
//       icon: !wasLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
//       message: !wasLiked ? '❤️ Post liked!' : '💔 Like removed!',
//       color: !wasLiked ? Colors.red : Colors.grey,
//     );

//     try {
//       await provider.toggleLike(widget.post.id);
//     } catch (e) {
//       if (mounted) {
//         provider.setOptimisticLike(widget.post.id, wasLiked);
//         _showSnackBar(
//           icon: Icons.error_outline_rounded,
//           message: 'Failed to update like',
//           color: Colors.red,
//         );
//       }
//     }
//   }

//   void _addComment() async {
//     if (!mounted || _commentController.text.trim().isEmpty) return;

//     final commentText = _commentController.text.trim();
//     final provider = context.read<LikeCommentProvider>();

//     _commentController.clear();
//     FocusScope.of(context).unfocus();

//     provider.addOptimisticComment(widget.post.id, commentText);

//     _showSnackBar(
//       icon: Icons.chat_bubble_rounded,
//       message: '💬 Comment added!',
//       color: Colors.green,
//     );

//     try {
//       final success = await provider.addComment(widget.post.id, commentText);
//       if (!success) throw Exception('Failed to add comment');
//     } catch (e) {
//       if (mounted) {
//         provider.removeOptimisticComment(widget.post.id);
//         _showSnackBar(
//           icon: Icons.error_outline_rounded,
//           message: 'Failed to add comment',
//           color: Colors.red,
//         );
//       }
//     }
//   }

//   void _showSnackBar({
//     required IconData icon,
//     required String message,
//     required Color color,
//   }) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Flexible(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;
//     final cardMargin = screenWidth * 0.04;
//     final cardPadding = screenWidth * 0.04;

//     if (!_isInitialized) {
//       return Container(
//         margin: EdgeInsets.all(cardMargin),
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     final description = widget.post.description;
//     final maxLength = isTablet ? 200 : 120;
//     final displayText = showFullText || description.length <= maxLength
//         ? description
//         : '${description.substring(0, maxLength)}...';

//     return Consumer<LikeCommentProvider>(
//       builder: (context, provider, _) {
//         final likeCount = provider.getLikeCount(widget.post.id);
//         final commentCount = provider.getCommentCount(widget.post.id);
//         final isShowingComments = provider.isShowingComments(widget.post.id);
//         final comments = provider.getComments(widget.post.id);
//         final isCommentLoading = provider.isCommentLoading(widget.post.id);

//         return Container(
//           width: double.infinity,
//           constraints: BoxConstraints(
//             maxWidth: isTablet ? 600 : double.infinity,
//           ),
//           margin: EdgeInsets.symmetric(
//             horizontal: cardMargin,
//             vertical: cardMargin * 0.5,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(cardPadding, isTablet),
//               _buildImage(),
//               _buildContent(cardPadding, displayText, description, maxLength),
//               _buildActions(
//                 cardPadding,
//                 likeCount,
//                 commentCount,
//                 isShowingComments,
//                 provider,
//               ),
//               if (isShowingComments) ...[
//                 const Divider(height: 1),
//                 _buildCommentInput(cardPadding),
//                 if (isCommentLoading)
//                   Container(
//                     height: 60,
//                     child: const Center(child: CircularProgressIndicator()),
//                   )
//                 else
//                   _buildCommentsList(comments, cardPadding),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader(double padding, bool isTablet) {
//     final avatarSize = isTablet ? 28.0 : 24.0;

//     return Padding(
//       padding: EdgeInsets.all(padding),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: avatarSize,
//             backgroundColor: AppColors.primary.withOpacity(0.1),
//             backgroundImage: widget.post.userProfilePicture != null
//                 ? NetworkImage(widget.post.userProfilePicture!)
//                 : null,
//             child: widget.post.userProfilePicture == null
//                 ? Text(
//                     widget.post.userName.isNotEmpty
//                         ? widget.post.userName[0].toUpperCase()
//                         : 'U',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                       fontSize: avatarSize * 0.6,
//                     ),
//                   )
//                 : null,
//           ),
//           SizedBox(width: padding * 0.75),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   widget.post.userName,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: isTablet ? 18 : 16,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   DateFormat(
//                     'MMM dd, yyyy • hh:mm a',
//                   ).format(widget.post.createdAt),
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: isTablet ? 14 : 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           AnimatedBuilder(
//             animation: _scaleAnimation,
//             builder: (context, _) => Transform.scale(
//               scale: _scaleAnimation.value,
//               child: GestureDetector(
//                 onTap: _toggleBookmark,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//                     color: isBookmarked ? AppColors.primary : Colors.grey[600],
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImage() {
//     return Container(
//       width: double.infinity,
//       constraints: const BoxConstraints(maxHeight: 300, minHeight: 200),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//             child: Image.network(
//               widget.post.imageUrl,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 color: Colors.grey[300],
//                 child: const Center(
//                   child: Icon(Icons.image_not_supported, size: 50),
//                 ),
//               ),
//               loadingBuilder: (context, child, progress) {
//                 if (progress == null) return child;
//                 return Container(
//                   color: Colors.grey[200],
//                   child: const Center(child: CircularProgressIndicator()),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent(
//     double padding,
//     String displayText,
//     String fullDescription,
//     int maxLength,
//   ) {
//     return Padding(
//       padding: EdgeInsets.all(padding),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(displayText, style: const TextStyle(fontSize: 14, height: 1.4)),
//           if (fullDescription.length > maxLength)
//             GestureDetector(
//               onTap: () => setState(() => showFullText = !showFullText),
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   showFullText ? 'Show less' : 'Read more',
//                   style: TextStyle(
//                     color: AppColors.primary,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActions(
//     double padding,
//     int likeCount,
//     int commentCount,
//     bool isShowingComments,
//     LikeCommentProvider provider,
//   ) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: padding,
//         vertical: padding * 0.5,
//       ),
//       child: Row(
//         children: [
//           AnimatedBuilder(
//             animation: _scaleAnimation,
//             builder: (context, _) => Transform.scale(
//               scale: _scaleAnimation.value,
//               child: _buildActionButton(
//                 icon: likeCount > 0 ? Icons.favorite : Icons.favorite_border,
//                 count: '$likeCount',
//                 isActive: likeCount > 0,
//                 onTap: _handleLike,
//                 onLongPress: likeCount > 0 ? () => _showLikers(provider) : null,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           _buildActionButton(
//             icon: isShowingComments
//                 ? Icons.chat_bubble
//                 : Icons.chat_bubble_outline,
//             count: '$commentCount',
//             isActive: isShowingComments,
//             onTap: () => provider.toggleCommentsVisibility(widget.post.id),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String count,
//     required bool isActive,
//     required VoidCallback onTap,
//     VoidCallback? onLongPress,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       onLongPress: onLongPress,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isActive ? AppColors.primary : Colors.grey[100],
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isActive ? AppColors.primary : Colors.grey[300]!,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isActive ? Colors.white : Colors.grey[600],
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               count,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isActive ? Colors.white : Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLikers(LikeCommentProvider provider) {
//     final likers = provider.getLikers(widget.post.id);
//     if (likers.isEmpty) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.6,
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Liked by',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Flexible(
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: likers.length,
//                 itemBuilder: (context, index) {
//                   final liker = likers[index];
//                   return ListTile(
//                     leading: CircleAvatar(
//                       radius: 20,
//                       backgroundColor: AppColors.primary.withOpacity(0.1),
//                       backgroundImage: liker.profilePictureUrl != null
//                           ? NetworkImage(liker.profilePictureUrl!)
//                           : null,
//                       child: liker.profilePictureUrl == null
//                           ? Text(
//                               liker.name.isNotEmpty
//                                   ? liker.name[0].toUpperCase()
//                                   : 'U',
//                               style: TextStyle(color: AppColors.primary),
//                             )
//                           : null,
//                     ),
//                     title: Text(liker.name),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCommentInput(double padding) {
//     return Padding(
//       padding: EdgeInsets.all(padding),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _commentController,
//               decoration: InputDecoration(
//                 hintText: 'Add a comment...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 isDense: true,
//               ),
//               onSubmitted: (_) => _addComment(),
//               maxLines: null,
//               textInputAction: TextInputAction.send,
//             ),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: _addComment,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.primary,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.send, color: Colors.white, size: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentsList(List<CommentModel> comments, double padding) {
//     if (comments.isEmpty) {
//       return Container(
//         height: 100,
//         child: const Center(
//           child: Text(
//             'No comments yet\nBe the first to share your thoughts!',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.grey),
//           ),
//         ),
//       );
//     }

//     return Container(
//       constraints: const BoxConstraints(maxHeight: 300),
//       child: ListView.builder(
//         shrinkWrap: true,
//         padding: EdgeInsets.symmetric(horizontal: padding),
//         itemCount: comments.length,
//         itemBuilder: (context, index) {
//           final comment = comments[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: AppColors.primary.withOpacity(0.1),
//                   backgroundImage: comment.user.profilePictureUrl != null
//                       ? NetworkImage(comment.user.profilePictureUrl!)
//                       : null,
//                   child: comment.user.profilePictureUrl == null
//                       ? Text(
//                           comment.user.name.isNotEmpty
//                               ? comment.user.name[0].toUpperCase()
//                               : 'U',
//                           style: TextStyle(
//                             color: AppColors.primary,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         children: [
//                           Flexible(
//                             child: Text(
//                               comment.user.name,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             DateFormat('MMM dd').format(comment.createdAt),
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         comment.review,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
