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

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  bool isBookmarked = false;
  bool showFullText = false;
  late AnimationController _bookmarkController;
  late AnimationController _imageController;
  late AnimationController _likeController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late Animation<double> _bookmarkAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _likeAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _pulseAnimation;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _bookmarkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bookmarkAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _bookmarkController, curve: Curves.elasticOut),
    );

    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeOutBack),
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cardController.forward();
    _imageController.forward();

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
    _bookmarkController.dispose();
    _imageController.dispose();
    _likeController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _toggleBookmark(BuildContext context) async {
    setState(() => isBookmarked = !isBookmarked);

    // Enhanced bookmark animation with pulse effect
    _bookmarkController.forward().then((_) {
      _bookmarkController.reverse();
    });

    if (isBookmarked) {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
    }

    final tempMessage = isBookmarked
        ? '✨ Post bookmarked!'
        : '📝 Bookmark removed!';
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isBookmarked ? Icons.bookmark_added : Icons.bookmark_remove,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tempMessage,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isBookmarked
              ? const Color(0xFF059669)
              : const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          elevation: 8,
        ),
      );
    }

    try {
      final provider = Provider.of<SocialPostApiProvider>(
        context,
        listen: false,
      );
      await provider.toggleBookmark(widget.post.id);
    } catch (e) {
      if (mounted) {
        setState(() => isBookmarked = !isBookmarked);

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Failed to update bookmark',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  void _handleLike() async {
    final likeProvider = Provider.of<LikeCommentProvider>(
      context,
      listen: false,
    );

    _likeController.forward().then((_) {
      _likeController.reverse();
    });

    final currentLikeCount = likeProvider.getLikeCount(widget.post.id);
    final wasLiked = currentLikeCount > 0;

    likeProvider.setOptimisticLike(widget.post.id, !wasLiked);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  !wasLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                !wasLiked ? '❤️ Post liked!' : '💔 Like removed!',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          backgroundColor: !wasLiked
              ? const Color(0xFFDC2626)
              : const Color(0xFF6B7280),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          elevation: 8,
        ),
      );
    }

    try {
      await likeProvider.toggleLike(widget.post.id);
    } catch (e) {
      likeProvider.setOptimisticLike(widget.post.id, wasLiked);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Failed to update like',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Liked by',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...likers.map(
              (liker) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: liker.profilePictureUrl != null
                            ? NetworkImage(liker.profilePictureUrl!)
                            : null,
                        child: liker.profilePictureUrl == null
                            ? Text(
                                liker.name.isNotEmpty
                                    ? liker.name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      liker.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '💬 Comment added!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          elevation: 8,
        ),
      );
    }

    try {
      final success = await likeProvider.addComment(
        widget.post.id,
        commentText,
      );

      if (!success) {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      likeProvider.removeOptimisticComment(widget.post.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Failed to add comment',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
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

        return AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimation.value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Header with enhanced styling
                    _buildUserHeader(),

                    // Post Image with enhanced effects
                    _buildImageSection(),

                    // Post Content with better typography
                    _buildContentSection(displayText, description),

                    // Enhanced Action Buttons
                    _buildActionButtons(likeCount, commentCount),

                    // Comments Section with improved design
                    if (isShowingComments) ...[
                      _buildCommentInput(),
                      if (isCommentLoading)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Loading comments...',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        _buildCommentsList(comments),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 24,
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
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(widget.post.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isBookmarked ? _pulseAnimation.value : 1.0,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(0),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.network(
                      widget.post.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFF3F4F6),
                                const Color(0xFFE5E7EB),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: AppColors.primary.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading image...',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: AnimatedBuilder(
                  animation: _bookmarkAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bookmarkAnimation.value,
                      child: GestureDetector(
                        onTap: () => _toggleBookmark(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? AppColors.primary
                                : const Color(0xFF6B7280),
                            size: 22,
                          ),
                        ),
                      ),
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

  Widget _buildContentSection(String displayText, String fullDescription) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          if (fullDescription.length > 120)
            GestureDetector(
              onTap: () => setState(() => showFullText = !showFullText),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  showFullText ? '← Show less' : 'Read more →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(int likeCount, int commentCount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Enhanced Like Button
          GestureDetector(
            onTap: _handleLike,
            onLongPress: likeCount > 0 ? _showLikers : null,
            child: AnimatedBuilder(
              animation: _likeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: likeCount > 0
                          ? Colors.red.withOpacity(0.1)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: likeCount > 0
                            ? Colors.red.withOpacity(0.2)
                            : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          likeCount > 0
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: likeCount > 0
                              ? Colors.red
                              : const Color(0xFF6B7280),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$likeCount',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: likeCount > 0
                                ? Colors.red
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        if (likeCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            likeCount == 1 ? 'like' : 'likes',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.red.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // Enhanced Comment Button
          Consumer<LikeCommentProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: () => provider.toggleCommentsVisibility(widget.post.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: commentCount > 0
                        ? AppColors.primary.withOpacity(0.1)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: commentCount > 0
                          ? AppColors.primary.withOpacity(0.2)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.isShowingComments(widget.post.id)
                            ? Icons.chat_bubble
                            : Icons.chat_bubble_outline,
                        color: commentCount > 0
                            ? AppColors.primary
                            : const Color(0xFF6B7280),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$commentCount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: commentCount > 0
                              ? AppColors.primary
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: provider.isShowingComments(widget.post.id)
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          provider.isShowingComments(widget.post.id)
                              ? 'Hide'
                              : 'View',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB).withOpacity(0.8),
            width: 1,
          ),
        ),
        color: const Color(0xFFFAFAFA),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: 'Write a thoughtful comment...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _addComment,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<CommentModel> comments) {
    if (comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 32,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No comments yet',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Be the first to share your thoughts!',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
      child: Column(
        children: comments
            .map((comment) => _buildCommentItem(comment))
            .toList(),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 18,
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
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('MMM dd, hh:mm a').format(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.review,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.5,
                    letterSpacing: 0.1,
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
