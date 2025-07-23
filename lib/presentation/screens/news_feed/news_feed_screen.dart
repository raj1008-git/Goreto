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
