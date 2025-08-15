// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:goreto/core/utils/snackbar_helper.dart';
// import 'package:goreto/data/models/places/place_model.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
//
// import '../../../data/providers/my_post_provider.dart';
// import '../../../data/providers/post_providers.dart';
//
// // Will create in Step 3
//
// class PostUploadDialog extends StatefulWidget {
//   final PlaceModel place;
//   const PostUploadDialog({super.key, required this.place});
//
//   @override
//   State<PostUploadDialog> createState() => _PostUploadDialogState();
// }
//
// class _PostUploadDialogState extends State<PostUploadDialog> {
//   final TextEditingController _descriptionController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   List<XFile> _selectedImages = [];
//   bool _isEmojiVisible = false;
//   bool _isLoading = false;
//
//   Future<void> _pickImages() async {
//     final images = await _picker.pickMultiImage(
//       imageQuality: 80,
//     ); // ensures JPEG
//     if (images.isNotEmpty) {
//       final filtered = images.where((image) {
//         final extension = image.name.split('.').last.toLowerCase();
//         return ['jpg', 'jpeg', 'png'].contains(extension);
//       }).toList();
//
//       if (filtered.length != images.length) {
//         SnackbarHelper.show(
//           context,
//           "Some unsupported images were skipped (.heic/.webp).",
//           backgroundColor: Colors.orange,
//         );
//       }
//
//       setState(() {
//         _selectedImages = filtered;
//       });
//     }
//   }
//
//   void _toggleEmojiPicker() {
//     FocusScope.of(context).unfocus();
//     setState(() {
//       _isEmojiVisible = !_isEmojiVisible;
//     });
//   }
//
//   Future<void> _submitPost() async {
//     setState(() => _isLoading = true);
//
//     final description = _descriptionController.text.trim();
//     final locationIds = [widget.place.id.toString()];
//     final categoryIds = [widget.place.categoryId.toString()];
//
//     final provider = Provider.of<PostProvider>(context, listen: false);
//
//     final success = await provider.createPost(
//       description: description,
//       locationIds: locationIds,
//       categoryIds: categoryIds,
//       images: _selectedImages,
//     );
//
//     setState(() => _isLoading = false);
//
//     if (success) {
//       // Notify the MyPostProvider to refresh posts
//       Provider.of<MyPostProvider>(context, listen: false).fetchMyPosts();
//
//       Navigator.pop(context);
//       SnackbarHelper.show(context, "Post created successfully.");
//     } else {
//       SnackbarHelper.show(
//         context,
//         "Failed to create post",
//         backgroundColor: Colors.red,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       contentPadding: const EdgeInsets.all(20),
//       scrollable: true,
//       content: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Create Post",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//
//           // Description
//           TextField(
//             controller: _descriptionController,
//             maxLines: 4,
//             decoration: InputDecoration(
//               hintText: "What's on your mind?",
//               suffixIcon: IconButton(
//                 icon: const Icon(Icons.emoji_emotions_outlined),
//                 onPressed: _toggleEmojiPicker,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               contentPadding: const EdgeInsets.all(12),
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           // Image Picker
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: [
//               ..._selectedImages.map(
//                 (img) => ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.file(
//                     File(img.path),
//                     width: 70,
//                     height: 70,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: _pickImages,
//                 child: Container(
//                   width: 70,
//                   height: 70,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: Colors.grey[200],
//                     border: Border.all(color: Colors.grey),
//                   ),
//                   child: const Icon(Icons.add_a_photo, color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//
//           if (_isEmojiVisible)
//             const Padding(
//               padding: EdgeInsets.only(top: 12),
//               child: Text(
//                 "(Emoji picker will be added here)",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//
//           const SizedBox(height: 20),
//
//           // Submit Button
//           Align(
//             alignment: Alignment.centerRight,
//             child: ElevatedButton.icon(
//               onPressed: _isLoading ? null : _submitPost,
//               icon: _isLoading
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Icon(Icons.send),
//               label: const Text("Post"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).primaryColor,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goreto/core/utils/snackbar_helper.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../data/providers/my_post_provider.dart';
import '../../../data/providers/post_providers.dart';

class PostUploadDialog extends StatefulWidget {
  final PlaceModel place;
  const PostUploadDialog({super.key, required this.place});

  @override
  State<PostUploadDialog> createState() => _PostUploadDialogState();
}

class _PostUploadDialogState extends State<PostUploadDialog>
    with TickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isEmojiVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      final filtered = images.where((image) {
        final extension = image.name.split('.').last.toLowerCase();
        return ['jpg', 'jpeg', 'png'].contains(extension);
      }).toList();

      if (filtered.length != images.length) {
        SnackbarHelper.show(
          context,
          "Some unsupported images were skipped (.heic/.webp).",
          backgroundColor: Colors.orange.shade400,
        );
      }

      setState(() {
        _selectedImages = filtered;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  Future<void> _submitPost() async {
    if (_descriptionController.text.trim().isEmpty && _selectedImages.isEmpty) {
      SnackbarHelper.show(
        context,
        "Please add a description or select images to post.",
        backgroundColor: Colors.orange.shade400,
      );
      return;
    }

    setState(() => _isLoading = true);

    final description = _descriptionController.text.trim();
    final locationIds = [widget.place.id.toString()];
    final categoryIds = [widget.place.categoryId.toString()];

    final provider = Provider.of<PostProvider>(context, listen: false);

    final success = await provider.createPost(
      description: description,
      locationIds: locationIds,
      categoryIds: categoryIds,
      images: _selectedImages,
    );

    setState(() => _isLoading = false);

    if (success) {
      Provider.of<MyPostProvider>(context, listen: false).fetchMyPosts();
      Navigator.pop(context);
      SnackbarHelper.show(
        context,
        "Post created successfully! 🎉",
        backgroundColor: Colors.green.shade400,
      );
    } else {
      SnackbarHelper.show(
        context,
        "Failed to create post. Please try again.",
        backgroundColor: Colors.red.shade400,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.post_add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Create Post",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Share your experience at ${widget.place.name}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText:
                                "What's on your mind? Share your thoughts...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              child: IconButton(
                                icon: Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: _isEmojiVisible
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                                ),
                                onPressed: _toggleEmojiPicker,
                                style: IconButton.styleFrom(
                                  backgroundColor: _isEmojiVisible
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Images Section
                      if (_selectedImages.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Selected Images (${_selectedImages.length})",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Image Grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            // Selected Images
                            ..._selectedImages.asMap().entries.map(
                              (entry) =>
                                  _buildImageThumbnail(entry.key, entry.value),
                            ),
                            // Add Image Button
                            _buildAddImageButton(),
                          ],
                        ),
                      ),

                      // Emoji Picker Placeholder
                      if (_isEmojiVisible) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.construction_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Emoji picker will be integrated here",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text("Cancel"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submitPost,
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                _isLoading ? "Posting..." : "Share Post",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 2,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index, XFile image) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(image.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              "Add",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
