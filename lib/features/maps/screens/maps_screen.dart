import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../data/models/places/popular_places_model.dart';
import '../popular_place_details_screen.dart';

class PopularPlacesMapScreen extends StatefulWidget {
  const PopularPlacesMapScreen({super.key});

  @override
  State<PopularPlacesMapScreen> createState() => _PopularPlacesMapScreenState();
}

class _PopularPlacesMapScreenState extends State<PopularPlacesMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Dio _dio = Dio();

  // State variables
  List<String> _categories = [];
  String? _selectedCategory;
  Set<Marker> _markers = {};
  List<PopularPlaceModel> _places = [];
  Position? _currentPosition;
  LatLng _center = const LatLng(27.6748, 85.4274); // Default Kathmandu location

  // Loading states
  bool _isLoadingLocation = true;
  bool _isLoadingPlaces = false;
  bool _isLoadingCategories = true;

  // Error states
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _setupDio();
    await Future.wait([_loadCategories(), _getCurrentLocation()]);
  }

  Future<void> _setupDio() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategories = prefs.getStringList('selected_categories') ?? [];

      if (mounted) {
        setState(() {
          _categories = savedCategories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load categories: ${e.toString()}';
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _center = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });

        // Add current location marker
        _addCurrentLocationMarker();

        // Move camera to current location
        _moveCameraToLocation(_center);
      }
    } catch (e) {
      _showLocationError('Failed to get current location: ${e.toString()}');
    }
  }

  void _showLocationError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _getCurrentLocation,
          ),
        ),
      );
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition == null) return;

    final currentLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'Current Position',
      ),
    );

    setState(() {
      _markers.add(currentLocationMarker);
    });
  }

  Future<void> _moveCameraToLocation(LatLng location) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 14),
      ),
    );
  }

  Future<void> _fetchPopularPlaces(String category) async {
    if (_isLoadingPlaces) return;

    setState(() {
      _isLoadingPlaces = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(
        '/places/popular',
        queryParameters: {
          'latitude': _center.latitude,
          'longitude': _center.longitude,
          'radius': 50000,
          'limit': 5,
          'category': category,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final List<PopularPlaceModel> places = data
            .map((place) => PopularPlaceModel.fromJson(place))
            .toList();

        _updatePlacesAndMarkers(places);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch places',
        );
      }
    } on DioException catch (e) {
      _handleApiError(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlaces = false);
      }
    }
  }

  void _updatePlacesAndMarkers(List<PopularPlaceModel> places) {
    if (!mounted) return;

    setState(() {
      _places = places;

      // Clear existing place markers but keep current location
      _markers.removeWhere(
        (marker) => marker.markerId.value != 'current_location',
      );

      // Add new place markers
      final placeMarkers = places.map((place) {
        return Marker(
          markerId: MarkerId(place.id.toString()),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.category} • ${_formatDistance(place.distance)}',
            onTap: () => _navigateToPlaceDetails(place),
          ),
        );
      }).toSet();

      _markers.addAll(placeMarkers);
    });

    // Fit camera to show all markers
    if (places.isNotEmpty) {
      _fitCameraToMarkers();
    }
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  Future<void> _fitCameraToMarkers() async {
    if (_markers.isEmpty) return;

    final controller = await _controller.future;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      final position = marker.position;
      minLat = math.min(minLat, position.latitude);
      maxLat = math.max(maxLat, position.latitude);
      minLng = math.min(minLng, position.longitude);
      maxLng = math.max(maxLng, position.longitude);
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void _handleApiError(DioException e) {
    String message = 'Network error occurred';

    if (e.response?.statusCode == 401) {
      message = 'Authentication failed. Please login again.';
    } else if (e.response?.statusCode == 404) {
      message = 'No places found for this category';
    } else if (e.response?.statusCode == 500) {
      message = 'Server error. Please try again later.';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Check your internet connection.';
    }

    _showError(message);
  }

  void _handleGenericError(dynamic e) {
    _showError('An unexpected error occurred: ${e.toString()}');
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _errorMessage = message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ),
      );
    }
  }

  void _navigateToPlaceDetails(PopularPlaceModel place) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PopularPlaceDetailScreen(place: place)),
    );
  }

  Widget _buildCleanDropdown() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Icon(Icons.tune, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Text(
                  'Choose Category',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          selectedItemBuilder: (context) {
            return _categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: _isLoadingPlaces
              ? null
              : (value) {
                  setState(() => _selectedCategory = value);
                  if (value != null) {
                    _fetchPopularPlaces(value);
                  }
                },
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoadingPlaces) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Finding places...',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCleanAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Logo section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logos/goreto.png', height: 22, width: 22),
                const SizedBox(width: 8),
                Text(
                  'Places',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Dropdown
          Expanded(
            child: _isLoadingCategories
                ? Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  )
                : _buildCleanDropdown(),
          ),
        ],
      ),
      actions: [
        if (_currentPosition != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                Icons.my_location,
                color: Colors.grey.shade700,
                size: 20,
              ),
              onPressed: () => _moveCameraToLocation(_center),
              tooltip: 'Go to my location',
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCleanAppBar(),
      body: Stack(
        children: [
          if (_isLoadingLocation)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a moment',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 12),
              onMapCreated: (controller) => _controller.complete(controller),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: _places.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _fitCameraToMarkers,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.zoom_out_map, size: 20),
              label: Text(
                'Show All (${_places.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            )
          : null,
    );
  }
}
