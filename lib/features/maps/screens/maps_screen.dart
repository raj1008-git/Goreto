import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goreto/data/models/places/place_model.dart';
import 'package:goreto/routes/app_routes.dart';

class MapsScreen extends StatefulWidget {
  final PlaceModel? place;

  const MapsScreen({super.key, this.place});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    final lat = widget.place?.latitude;
    final lng = widget.place?.longitude;

    if (lat != null && lng != null) {
      _markers.add(
        Marker(
          markerId: MarkerId(widget.place!.id.toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: widget.place!.name,
            snippet: widget.place!.category,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.placeDetail,
                arguments: widget.place,
              );
            },
          ),
        ),
      );
    }
  }

  void _handleMarkerTap() {
    final now = DateTime.now();
    if (_lastTap == null ||
        now.difference(_lastTap!) > const Duration(milliseconds: 300)) {
      _lastTap = now;
    } else {
      if (widget.place != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.placeDetail,
          arguments: widget.place,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.place?.latitude ?? 27.7172;
    final lng = widget.place?.longitude ?? 85.3240;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: GoogleMap(
        key: const ValueKey("unique_map"),
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
