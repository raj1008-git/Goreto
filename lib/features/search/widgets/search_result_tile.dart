import 'package:flutter/material.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:goreto/routes/app_routes.dart';

class SearchResultTile extends StatelessWidget {
  final PlaceModel place;

  const SearchResultTile({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          place.imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 40,
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        ),
      ),
      title: Text(
        place.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // subtitle: Text('${place.category} • ${place.cityName ?? 'Unknown City'}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.placeDetail, arguments: place);
      },
    );
  }
}
