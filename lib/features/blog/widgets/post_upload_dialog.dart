import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goreto/core/utils/snackbar_helper.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/my_post_provider.dart';
import '../../../data/providers/post_providers.dart';

// Will create in Step 3

class PostUploadDialog extends StatefulWidget {
  final PlaceModel place;
  const PostUploadDialog({super.key, required this.place});

  @override
  State<PostUploadDialog> createState() => _PostUploadDialogState();
}

class _PostUploadDialogState extends State<PostUploadDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isEmojiVisible = false;
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(
      imageQuality: 80,
    ); // ensures JPEG
    if (images.isNotEmpty) {
      final filtered = images.where((image) {
        final extension = image.name.split('.').last.toLowerCase();
        return ['jpg', 'jpeg', 'png'].contains(extension);
      }).toList();

      if (filtered.length != images.length) {
        SnackbarHelper.show(
          context,
          "Some unsupported images were skipped (.heic/.webp).",
          backgroundColor: Colors.orange,
        );
      }

      setState(() {
        _selectedImages = filtered;
      });
    }
  }

  void _toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  Future<void> _submitPost() async {
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
      // Notify the MyPostProvider to refresh posts
      Provider.of<MyPostProvider>(context, listen: false).fetchMyPosts();

      Navigator.pop(context);
      SnackbarHelper.show(context, "Post created successfully.");
    } else {
      SnackbarHelper.show(
        context,
        "Failed to create post",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create Post",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              suffixIcon: IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: _toggleEmojiPicker,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),

          // Image Picker
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._selectedImages.map(
                (img) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(img.path),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Colors.grey),
                ),
              ),
            ],
          ),

          if (_isEmojiVisible)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                "(Emoji picker will be added here)",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          const SizedBox(height: 20),

          // Submit Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitPost,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: const Text("Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
