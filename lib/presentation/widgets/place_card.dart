import 'package:flutter/material.dart';
import 'package:goreto/features/maps/screens/maps_screen_two.dart';

import '../../core/constants/api_endpoints.dart';
import '../../data/models/places/place_model.dart';

class PlaceCard extends StatefulWidget {
  final PlaceModel place;
  final bool showDistance;

  const PlaceCard({super.key, required this.place, this.showDistance = false});

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  bool isFavorited = false;

  void _toggleFavorite() async {
    setState(() {
      isFavorited = !isFavorited;
    });
    // TODO: Call favorite/unfavorite API here using widget.place.id
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MapsScreenTwo(place: widget.place)),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: widget.place.imagePath.isNotEmpty
                      ? Image.network(
                          ApiEndpoints.imageUrl(widget.place.imagePath),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 160,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                        )
                      : Container(
                          height: 160,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${widget.place.latitude}, ${widget.place.longitude}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.showDistance && widget.place.distance != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${(widget.place.distance! / 1000).toStringAsFixed(1)} km',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
