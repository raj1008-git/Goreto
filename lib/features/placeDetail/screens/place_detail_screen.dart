// unchanged imports
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:goreto/data/providers/review_provider.dart';
import 'package:goreto/features/reviews/review_list.dart';
import 'package:provider/provider.dart';

import '../../blog/widgets/post_upload_dialog.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late GoogleMapController _mapController;
  final double mapHeight = 180;
  bool showFullDescription = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ReviewProvider>(
        context,
        listen: false,
      ).fetchReviews(widget.place.id);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final imageUrl = ApiEndpoints.imageUrl(place.imagePath);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 300),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + share button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 26),
                            tooltip: 'Share as post',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => PostUploadDialog(place: place),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Category
                      Text(
                        place.category,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              showFullDescription
                                  ? place.description
                                  : _truncateText(place.description, 1),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showFullDescription = !showFullDescription;
                                });
                              },
                              child: Text(
                                showFullDescription ? "Show less" : "Show more",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Map
                      Container(
                        height: mapHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(place.latitude, place.longitude),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(place.id.toString()),
                                position: LatLng(
                                  place.latitude,
                                  place.longitude,
                                ),
                              ),
                            },
                            myLocationEnabled: false,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "User Reviews",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ReviewList(placeId: place.id),
                    ],
                  ),
                ),
              ),
            ),

            // Top image with back button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 60),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // ✅ Updated smaller back button
                  const Positioned(
                    top: 40,
                    left: 20,
                    child: _SmallBackButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLines) {
    final lines = text.split('\n');
    final visibleLines = lines.take(maxLines).join('\n');
    if (lines.length <= maxLines) return text;
    return "$visibleLines...";
  }
}

class _SmallBackButton extends StatelessWidget {
  const _SmallBackButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
