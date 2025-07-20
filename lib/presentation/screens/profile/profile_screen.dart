import 'package:flutter/material.dart';
import 'package:goreto/data/providers/my_post_provider.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../core/services/dio_client.dart';
import '../../../data/datasources/remote/profile_api_service.dart';
import '../../../data/models/auth/login_response_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../features/blog/screens/post_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileApiService? _profileApiService;
  String? _profileImageUrl;
  UserModel? _currentUser;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeProfile();
  }

  void _initializeServices() {
    _profileApiService = ProfileApiService(DioClient().dio);
  }

  Future<void> _initializeProfile() async {
    await Future.wait([
      _loadUserData(),
      _fetchProfilePicture(),
      _fetchMyPosts(),
    ]);
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      setState(() {
        _currentUser = authProvider.user;
      });
    }
  }

  Future<void> _fetchMyPosts() async {
    Provider.of<MyPostProvider>(context, listen: false).fetchMyPosts();
  }

  Future<void> _fetchProfilePicture() async {
    try {
      if (_profileApiService == null) return;
      final profilePictureUrl = await _profileApiService!.getProfilePicture();
      setState(() {
        _profileImageUrl = profilePictureUrl;
      });
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }

  Future<void> _updateProfilePicture() async {
    if (_profileApiService == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final success = await _profileApiService!.updateProfilePicture(image);

      if (success) {
        await _fetchProfilePicture();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating profile picture: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'change_password':
        _showChangePasswordDialog();
        break;
      case 'settings':
        // Navigate to settings screen
        // Navigator.pushNamed(context, AppRoutes.settings);
        break;
      case 'logout':
        // _showLogoutConfirmation();
        break;
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        if (_profileApiService == null) return;
                        await _profileApiService!.changePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${e.toString().replaceFirst('Exception: ', '')}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/logos/goreto.png', height: 34),
            ),
            const SizedBox(width: 12),
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(-8, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            elevation: 8,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert, color: Colors.black87),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'change_password',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Change Password',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Settings',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_outlined,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: _handleMenuSelection,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<MyPostProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && _currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final postImagePairs = <MapEntry<int, String>>[];
          for (var post in provider.posts) {
            for (var imageUrl in post.imageUrls) {
              postImagePairs.add(MapEntry(post.id, imageUrl));
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Enhanced User Info Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture Section
                        // Replace your existing Stack widget for the profile picture with this fixed version:
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                backgroundImage: _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null,
                                child: _profileImageUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.secondary,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isLoadingProfile
                                      ? null
                                      : _updateProfilePicture,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ), // Make it circular for better tap area
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      12,
                                    ), // Increased padding for larger tap area
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: _isLoadingProfile
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18, // Slightly larger icon
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // User Information
                        Text(
                          _currentUser?.name ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentUser?.email ?? 'user@example.com',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              'Posts',
                              '${provider.posts.length}',
                              Icons.article_outlined,
                            ),
                            _buildVerticalDivider(),
                            _buildStatItem(
                              'Images',
                              '${postImagePairs.length}',
                              Icons.photo_outlined,
                            ),
                            _buildVerticalDivider(),
                            _buildStatItem('Groups', '0', Icons.group_outlined),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Action Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.groupCreate,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Create Group',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // My Posts Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'My Posts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (provider.posts.isNotEmpty)
                        Text(
                          '${provider.posts.length} posts',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Posts Grid or Empty State
                if (postImagePairs.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start sharing your thoughts and experiences!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: postImagePairs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
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
                                builder: (_) =>
                                    PostDetailScreen(postId: postId),
                              ),
                            );

                            if (result == true && mounted) {
                              Provider.of<MyPostProvider>(
                                context,
                                listen: false,
                              ).fetchMyPosts();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3));
  }
}
