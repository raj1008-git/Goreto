import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/places/popular_places_model.dart';

class PopularPlaceDetailScreen extends StatelessWidget {
  final PopularPlaceModel place;

  const PopularPlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaceHeader(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(context),
                  const SizedBox(height: 24),
                  _buildImagesSection(),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButtons(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          place.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: place.locationImages.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: place.locationImages.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Icon(Icons.place, size: 80, color: Colors.white54),
              ),
      ),
    );
  }

  Widget _buildPlaceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                place.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (place.averageRating != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRatingColor(place.averageRating!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      place.averageRating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                place.category,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 4),
            Text(
              _formatDistance(place.distance),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            place.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildLocationItem(
                icon: Icons.my_location,
                label: 'Coordinates',
                value:
                    '${place.latitude.toStringAsFixed(6)}, ${place.longitude.toStringAsFixed(6)}',
              ),
              const Divider(height: 24),
              _buildLocationItem(
                icon: Icons.straighten,
                label: 'Distance',
                value: _formatDistance(place.distance),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    if (place.locationImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${place.locationImages.length})',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: place.locationImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageViewer(context, index),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: place.locationImages[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: "directions",
          onPressed: () => _openMaps(context),
          icon: const Icon(Icons.directions),
          label: const Text('Directions'),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "share",
          onPressed: () => _sharePlace(context),
          child: const Icon(Icons.share),
        ),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  void _showImageViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          images: place.locationImages,
          initialIndex: initialIndex,
          placeName: place.name,
        ),
      ),
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePlace(BuildContext context) async {
    final text =
        '''
Check out ${place.name}!

Category: ${place.category}
${place.description}

Location: https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}
''';

    // You can use share_plus package here
    // Share.share(text);

    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would be implemented here'),
      ),
    );
  }
}

class _ImageViewerScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  final String placeName;

  const _ImageViewerScreen({
    required this.images,
    required this.initialIndex,
    required this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(placeName, style: const TextStyle(color: Colors.white)),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 50),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
