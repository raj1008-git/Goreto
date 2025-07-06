import 'package:flutter/material.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:goreto/features/reviews/review_list.dart';
import 'package:provider/provider.dart';
import 'package:goreto/data/providers/review_provider.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final imageUrl = ApiEndpoints.imageUrl(place.imagePath);

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Category: ${place.category}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        "Lat: ${place.latitude.toStringAsFixed(5)}, "
                        "Lng: ${place.longitude.toStringAsFixed(5)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Place ID: ${place.id}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // ⬇️ Reviews Section
                  const Text(
                    "User Reviews",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ReviewList(placeId: place.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
