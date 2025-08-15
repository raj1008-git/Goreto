// import 'package:flutter/material.dart';
// import 'package:goreto/features/maps/screens/maps_screen_two.dart';
//
// import '../../core/constants/api_endpoints.dart';
// import '../../data/models/places/place_model.dart';
//
// class PlaceCard extends StatefulWidget {
//   final PlaceModel place;
//   final bool showDistance;
//
//   const PlaceCard({super.key, required this.place, this.showDistance = false});
//
//   @override
//   State<PlaceCard> createState() => _PlaceCardState();
// }
//
// class _PlaceCardState extends State<PlaceCard> {
//   bool isFavorited = false;
//
//   void _toggleFavorite() async {
//     setState(() {
//       isFavorited = !isFavorited;
//     });
//     // TODO: Call favorite/unfavorite API here using widget.place.id
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => MapsScreenTwo(place: widget.place)),
//         );
//       },
//       child: Container(
//         width: 200,
//         margin: const EdgeInsets.only(right: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(20),
//                   ),
//                   child: widget.place.imagePath.isNotEmpty
//                       ? Image.network(
//                           ApiEndpoints.imageUrl(widget.place.imagePath),
//                           height: 160,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                                 height: 160,
//                                 color: Colors.grey[300],
//                                 child: const Center(
//                                   child: Icon(Icons.broken_image, size: 40),
//                                 ),
//                               ),
//                         )
//                       : Container(
//                           height: 160,
//                           color: Colors.grey[300],
//                           child: const Center(
//                             child: Icon(Icons.image_not_supported, size: 40),
//                           ),
//                         ),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: GestureDetector(
//                     onTap: _toggleFavorite,
//                     child: Icon(
//                       isFavorited ? Icons.favorite : Icons.favorite_border,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Text(
//                 widget.place.name,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
//               child: Row(
//                 children: [
//                   const Icon(Icons.place, color: Colors.red, size: 18),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       '${widget.place.latitude}, ${widget.place.longitude}',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   if (widget.showDistance && widget.place.distance != null) ...[
//                     const SizedBox(width: 6),
//                     Text(
//                       '${(widget.place.distance! / 1000).toStringAsFixed(1)} km',
//                       style: TextStyle(color: Colors.grey[700], fontSize: 12),
//                     ),
//                   ],
//                   const SizedBox(width: 4),
//                   const Icon(Icons.star, color: Colors.amber, size: 16),
//                   const Icon(Icons.star, color: Colors.amber, size: 16),
//                   const Icon(Icons.star, color: Colors.amber, size: 16),
//                   const Icon(Icons.star, color: Colors.amber, size: 16),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:goreto/features/maps/screens/maps_screen_two.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/constants/appColors.dart';
import '../../data/models/places/place_model.dart';
import '../../data/providers/favourites_provider.dart';

class PlaceCard extends StatefulWidget {
  final PlaceModel place;
  final bool showDistance;

  const PlaceCard({super.key, required this.place, this.showDistance = false});

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _toggleFavorite(FavoritesProvider provider) async {
    // Trigger heart animation
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

    final success = await provider.toggleFavorite(widget.place);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite status'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (success && mounted) {
      final isNowFavorited = provider.isFavorite(widget.place.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: isNowFavorited
              ? AppColors.primary
              : Colors.grey[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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
        height: 250, // Fixed height to prevent overflow
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image container
                Hero(
                  tag: 'place_image_${widget.place.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: widget.place.imagePath.isNotEmpty
                        ? Image.network(
                            ApiEndpoints.imageUrl(widget.place.imagePath),
                            height:
                                140, // Reduced height to give more space for content
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.3),
                                        AppColors.primary.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.landscape_rounded,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                          )
                        : Container(
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.3),
                                  AppColors.primary.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.landscape_rounded,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                ),

                // Gradient overlay for better text visibility
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, child) {
                      final isFavorited = favoritesProvider.isFavorite(
                        widget.place.id,
                      );

                      return AnimatedBuilder(
                        animation: _heartScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _heartScaleAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () =>
                                    _toggleFavorite(favoritesProvider),
                                icon: Icon(
                                  isFavorited
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFavorited
                                      ? Colors.red
                                      : Colors.grey[600],
                                  size: 20, // Slightly smaller icon
                                ),
                                padding: const EdgeInsets.all(
                                  6,
                                ), // Reduced padding
                                constraints: const BoxConstraints(),
                                tooltip: isFavorited
                                    ? 'Remove from favorites'
                                    : 'Add to favorites',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.place.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content section with flexible layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Place name
                        Text(
                          widget.place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Slightly smaller
                            color: AppColors.secondary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Location info
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.red[400],
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${widget.place.latitude.toStringAsFixed(2)}, ${widget.place.longitude.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom row with distance and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Distance (if available and should show)
                        if (widget.showDistance &&
                            widget.place.distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_walk_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${(widget.place.distance! / 1000).toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(),

                        // Rating stars
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            4,
                            (index) => Icon(
                              Icons.star_rounded,
                              color: Colors.amber[600],
                              size: 14,
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
    );
  }
}
