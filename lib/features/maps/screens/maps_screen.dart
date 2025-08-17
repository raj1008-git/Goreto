// // import 'dart:async';
// // import 'dart:math' as math;
// //
// // import 'package:dio/dio.dart';
// // import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../../../core/constants/api_endpoints.dart';
// // import '../../../core/services/secure_storage_service.dart';
// // import '../../../data/models/places/popular_places_model.dart';
// // import '../popular_place_details_screen.dart';
// //
// // class PopularPlacesMapScreen extends StatefulWidget {
// //   const PopularPlacesMapScreen({super.key});
// //
// //   @override
// //   State<PopularPlacesMapScreen> createState() => _PopularPlacesMapScreenState();
// // }
// //
// // class _PopularPlacesMapScreenState extends State<PopularPlacesMapScreen>
// //     with TickerProviderStateMixin {
// //   final Completer<GoogleMapController> _controller = Completer();
// //   final Dio _dio = Dio();
// //   final TextEditingController _promptController = TextEditingController();
// //
// //   // Animation controllers
// //   late AnimationController _fabAnimationController;
// //   late AnimationController _promptAnimationController;
// //   late Animation<double> _fabAnimation;
// //   late Animation<Offset> _promptSlideAnimation;
// //
// //   // State variables
// //   List<String> _categories = [];
// //   String? _selectedCategory;
// //   Set<Marker> _markers = {};
// //   List<PopularPlaceModel> _places = [];
// //   List<AIRecommendationModel> _aiRecommendations = [];
// //   Position? _currentPosition;
// //   LatLng _center = const LatLng(27.6748, 85.4274); // Default Kathmandu location
// //
// //   // Loading states
// //   bool _isLoadingLocation = true;
// //   bool _isLoadingPlaces = false;
// //   bool _isLoadingCategories = true;
// //   bool _isLoadingAI = false;
// //
// //   // UI states
// //   bool _isPromptVisible = false;
// //   bool _isAIMode = false;
// //
// //   // Error states
// //   String? _errorMessage;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _setupAnimations();
// //     _initializeScreen();
// //   }
// //
// //   void _setupAnimations() {
// //     _fabAnimationController = AnimationController(
// //       duration: const Duration(milliseconds: 300),
// //       vsync: this,
// //     );
// //
// //     _promptAnimationController = AnimationController(
// //       duration: const Duration(milliseconds: 500),
// //       vsync: this,
// //     );
// //
// //     _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(
// //         parent: _fabAnimationController,
// //         curve: Curves.elasticOut,
// //       ),
// //     );
// //
// //     _promptSlideAnimation =
// //         Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
// //           CurvedAnimation(
// //             parent: _promptAnimationController,
// //             curve: Curves.easeOutBack,
// //           ),
// //         );
// //
// //     _fabAnimationController.forward();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _fabAnimationController.dispose();
// //     _promptAnimationController.dispose();
// //     _promptController.dispose();
// //     _dio.close();
// //     super.dispose();
// //   }
// //
// //   Future<void> _initializeScreen() async {
// //     print('🚀 Initializing screen...');
// //     await _setupDio();
// //     await Future.wait([_loadCategories(), _getCurrentLocation()]);
// //     print('✅ Screen initialization completed');
// //   }
// //
// //   Future<void> _setupDio() async {
// //     final storage = SecureStorageService();
// //     final token = await storage.read('access_token');
// //
// //     _dio.options = BaseOptions(
// //       baseUrl: ApiEndpoints.baseUrl,
// //       headers: {
// //         'Accept': 'application/json',
// //         if (token != null) 'Authorization': 'Bearer $token',
// //       },
// //       connectTimeout: const Duration(seconds: 10),
// //       receiveTimeout: const Duration(seconds: 10),
// //     );
// //   }
// //
// //   Future<void> _loadCategories() async {
// //     print('🔄 Loading categories from SharedPreferences...');
// //
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final savedCategories = prefs.getStringList('selected_categories') ?? [];
// //
// //       print('📦 Raw categories from SharedPrefs: $savedCategories');
// //
// //       if (mounted) {
// //         setState(() {
// //           _categories = savedCategories;
// //           _isLoadingCategories = false;
// //         });
// //         print('✅ Categories loaded successfully: $_categories');
// //       }
// //     } catch (e) {
// //       print('❌ Failed to load categories: $e');
// //
// //       if (mounted) {
// //         setState(() {
// //           _categories = [];
// //           _errorMessage = 'Failed to load categories: ${e.toString()}';
// //           _isLoadingCategories = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     print('📍 Getting current location...');
// //
// //     try {
// //       LocationPermission permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         permission = await Geolocator.requestPermission();
// //         if (permission == LocationPermission.denied) {
// //           _showLocationError('Location permissions are denied');
// //           return;
// //         }
// //       }
// //
// //       if (permission == LocationPermission.deniedForever) {
// //         _showLocationError('Location permissions are permanently denied');
// //         return;
// //       }
// //
// //       final position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //         timeLimit: const Duration(seconds: 10),
// //       );
// //
// //       if (mounted) {
// //         setState(() {
// //           _currentPosition = position;
// //           _center = LatLng(position.latitude, position.longitude);
// //           _isLoadingLocation = false;
// //         });
// //
// //         print(
// //           '✅ Location obtained: ${position.latitude}, ${position.longitude}',
// //         );
// //         _addCurrentLocationMarker();
// //         _moveCameraToLocation(_center);
// //       }
// //     } catch (e) {
// //       print('❌ Location error: $e');
// //       _showLocationError('Failed to get current location: ${e.toString()}');
// //     }
// //   }
// //
// //   void _showLocationError(String message) {
// //     if (mounted) {
// //       setState(() {
// //         _errorMessage = message;
// //         _isLoadingLocation = false;
// //       });
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.orange,
// //           action: SnackBarAction(
// //             label: 'Retry',
// //             onPressed: _getCurrentLocation,
// //           ),
// //         ),
// //       );
// //     }
// //   }
// //
// //   void _addCurrentLocationMarker() {
// //     if (_currentPosition == null) return;
// //
// //     final currentLocationMarker = Marker(
// //       markerId: const MarkerId('current_location'),
// //       position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
// //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
// //       infoWindow: const InfoWindow(
// //         title: 'Your Location',
// //         snippet: 'Current Position',
// //       ),
// //     );
// //
// //     setState(() {
// //       _markers.add(currentLocationMarker);
// //     });
// //   }
// //
// //   Future<void> _moveCameraToLocation(LatLng location) async {
// //     try {
// //       final controller = await _controller.future;
// //       await controller.animateCamera(
// //         CameraUpdate.newCameraPosition(
// //           CameraPosition(target: location, zoom: 14),
// //         ),
// //       );
// //     } catch (e) {
// //       print('❌ Camera movement error: $e');
// //     }
// //   }
// //
// //   Future<void> _fetchPopularPlaces(String category) async {
// //     if (_isLoadingPlaces) {
// //       print('⏳ Already loading places, skipping...');
// //       return;
// //     }
// //
// //     print('🔍 Fetching places for category: $category');
// //
// //     setState(() {
// //       _isLoadingPlaces = true;
// //       _errorMessage = null;
// //       _isAIMode = false;
// //     });
// //
// //     try {
// //       final response = await _dio.get(
// //         '/places/popular',
// //         queryParameters: {
// //           'latitude': _center.latitude,
// //           'longitude': _center.longitude,
// //           'radius': 50000,
// //           'limit': 5,
// //           'category': category,
// //         },
// //       );
// //
// //       print('📡 API Response status: ${response.statusCode}');
// //
// //       if (response.statusCode == 200) {
// //         final List data = response.data['data'] ?? [];
// //         final List<PopularPlaceModel> places = data
// //             .map((place) => PopularPlaceModel.fromJson(place))
// //             .toList();
// //
// //         print('✅ Found ${places.length} places');
// //         _updatePlacesAndMarkers(places);
// //       } else {
// //         throw DioException(
// //           requestOptions: response.requestOptions,
// //           response: response,
// //           message: 'Failed to fetch places',
// //         );
// //       }
// //     } on DioException catch (e) {
// //       print('❌ Dio error: ${e.message}');
// //       _handleApiError(e);
// //     } catch (e) {
// //       print('❌ Generic error: $e');
// //       _handleGenericError(e);
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isLoadingPlaces = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   Future<void> _fetchAIRecommendations(String prompt) async {
// //     if (_isLoadingAI) return;
// //
// //     setState(() {
// //       _isLoadingAI = true;
// //       _errorMessage = null;
// //     });
// //
// //     try {
// //       final response = await _dio.post(
// //         '/recommendations',
// //         data: {'prompt': prompt},
// //       );
// //
// //       if (response.statusCode == 200) {
// //         final data = response.data;
// //         final List locationData = data['locations'] ?? [];
// //
// //         final recommendations = locationData
// //             .map((location) => AIRecommendationModel.fromJson(location))
// //             .toList();
// //
// //         setState(() {
// //           _aiRecommendations = recommendations;
// //           _isAIMode = true;
// //         });
// //
// //         _updateAIMarkersAndCamera(recommendations);
// //         _hidePrompt();
// //
// //         // Show success message with recommendation summary
// //         _showSuccessMessage(
// //           'Found ${recommendations.length} AI recommendations!',
// //         );
// //       } else {
// //         throw DioException(
// //           requestOptions: response.requestOptions,
// //           response: response,
// //           message: 'Failed to fetch AI recommendations',
// //         );
// //       }
// //     } on DioException catch (e) {
// //       print('❌ AI API error: ${e.message}');
// //       _handleApiError(e);
// //     } catch (e) {
// //       print('❌ AI Generic error: $e');
// //       _handleGenericError(e);
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isLoadingAI = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   void _updateAIMarkersAndCamera(List<AIRecommendationModel> recommendations) {
// //     if (!mounted) return;
// //
// //     setState(() {
// //       // Clear existing place markers but keep current location
// //       _markers.removeWhere(
// //         (marker) => marker.markerId.value != 'current_location',
// //       );
// //
// //       // Add AI recommendation markers
// //       final aiMarkers = recommendations.map((recommendation) {
// //         return Marker(
// //           markerId: MarkerId('ai_${recommendation.id}'),
// //           position: LatLng(recommendation.latitude, recommendation.longitude),
// //           icon: BitmapDescriptor.defaultMarkerWithHue(
// //             BitmapDescriptor.hueViolet,
// //           ),
// //           infoWindow: InfoWindow(
// //             title: recommendation.name,
// //             snippet: '${recommendation.category} • ${recommendation.city}',
// //             onTap: () => _navigateToAIRecommendationDetails(recommendation),
// //           ),
// //         );
// //       }).toSet();
// //
// //       _markers.addAll(aiMarkers);
// //     });
// //
// //     // Fit camera to show all markers
// //     if (recommendations.isNotEmpty) {
// //       _fitCameraToMarkers();
// //     }
// //   }
// //
// //   void _updatePlacesAndMarkers(List<PopularPlaceModel> places) {
// //     if (!mounted) return;
// //
// //     setState(() {
// //       _places = places;
// //
// //       // Clear existing place markers but keep current location
// //       _markers.removeWhere(
// //         (marker) => marker.markerId.value != 'current_location',
// //       );
// //
// //       // Add new place markers
// //       final placeMarkers = places.map((place) {
// //         return Marker(
// //           markerId: MarkerId(place.id.toString()),
// //           position: LatLng(place.latitude, place.longitude),
// //           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
// //           infoWindow: InfoWindow(
// //             title: place.name,
// //             snippet: '${place.category} • ${_formatDistance(place.distance)}',
// //             onTap: () => _navigateToPlaceDetails(place),
// //           ),
// //         );
// //       }).toSet();
// //
// //       _markers.addAll(placeMarkers);
// //     });
// //
// //     // Fit camera to show all markers
// //     if (places.isNotEmpty) {
// //       _fitCameraToMarkers();
// //     }
// //   }
// //
// //   String _formatDistance(double distance) {
// //     if (distance < 1000) {
// //       return '${distance.toStringAsFixed(0)}m';
// //     } else {
// //       return '${(distance / 1000).toStringAsFixed(1)}km';
// //     }
// //   }
// //
// //   Future<void> _fitCameraToMarkers() async {
// //     if (_markers.isEmpty) return;
// //
// //     try {
// //       final controller = await _controller.future;
// //
// //       double minLat = double.infinity;
// //       double maxLat = -double.infinity;
// //       double minLng = double.infinity;
// //       double maxLng = -double.infinity;
// //
// //       for (final marker in _markers) {
// //         final position = marker.position;
// //         minLat = math.min(minLat, position.latitude);
// //         maxLat = math.max(maxLat, position.latitude);
// //         minLng = math.min(minLng, position.longitude);
// //         maxLng = math.max(maxLng, position.longitude);
// //       }
// //
// //       await controller.animateCamera(
// //         CameraUpdate.newLatLngBounds(
// //           LatLngBounds(
// //             southwest: LatLng(minLat, minLng),
// //             northeast: LatLng(maxLat, maxLng),
// //           ),
// //           100.0,
// //         ),
// //       );
// //     } catch (e) {
// //       print('❌ Camera fit error: $e');
// //     }
// //   }
// //
// //   void _handleApiError(DioException e) {
// //     String message = 'Network error occurred';
// //
// //     if (e.response?.statusCode == 401) {
// //       message = 'Authentication failed. Please login again.';
// //     } else if (e.response?.statusCode == 404) {
// //       message = 'No places found for this request';
// //     } else if (e.response?.statusCode == 500) {
// //       message = 'Server error. Please try again later.';
// //     } else if (e.type == DioExceptionType.connectionTimeout) {
// //       message = 'Connection timeout. Check your internet connection.';
// //     }
// //
// //     _showError(message);
// //   }
// //
// //   void _handleGenericError(dynamic e) {
// //     _showError('An unexpected error occurred: ${e.toString()}');
// //   }
// //
// //   void _showError(String message) {
// //     if (mounted) {
// //       setState(() => _errorMessage = message);
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //           action: SnackBarAction(
// //             label: 'Dismiss',
// //             onPressed: () => setState(() => _errorMessage = null),
// //           ),
// //         ),
// //       );
// //     }
// //   }
// //
// //   void _showSuccessMessage(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.green,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //       ),
// //     );
// //   }
// //
// //   void _navigateToPlaceDetails(PopularPlaceModel place) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (_) => PopularPlaceDetailScreen(place: place)),
// //     );
// //   }
// //
// //   void _navigateToAIRecommendationDetails(
// //     AIRecommendationModel recommendation,
// //   ) {
// //     // Convert AI recommendation to PopularPlaceModel for existing detail screen
// //     final place = PopularPlaceModel(
// //       id: recommendation.id,
// //       placeId: recommendation.placeId,
// //       name: recommendation.name,
// //       latitude: recommendation.latitude,
// //       longitude: recommendation.longitude,
// //       cityId: 0, // Not provided in AI response
// //       description: recommendation.description,
// //       averageRating: recommendation.averageRating,
// //       distance: 0.0, // Calculate if needed
// //       locationImages: recommendation.images.map((img) => img.imageUrl).toList(),
// //       categoryId: 0, // Not provided
// //       category: recommendation.category,
// //       createdAt: DateTime.now(),
// //       updatedAt: DateTime.now(),
// //     );
// //
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (_) => PopularPlaceDetailScreen(place: place)),
// //     );
// //   }
// //
// //   void _showPrompt() {
// //     setState(() {
// //       _isPromptVisible = true;
// //     });
// //     _promptAnimationController.forward();
// //   }
// //
// //   void _hidePrompt() {
// //     _promptAnimationController.reverse().then((_) {
// //       if (mounted) {
// //         setState(() {
// //           _isPromptVisible = false;
// //         });
// //       }
// //     });
// //   }
// //
// //   void _submitPrompt() {
// //     final prompt = _promptController.text.trim();
// //     if (prompt.isNotEmpty) {
// //       _fetchAIRecommendations(prompt);
// //       _promptController.clear();
// //     }
// //   }
// //
// //   void _clearAIResults() {
// //     setState(() {
// //       _isAIMode = false;
// //       _aiRecommendations.clear();
// //       // Clear AI markers but keep current location and regular place markers
// //       _markers.removeWhere((marker) => marker.markerId.value.startsWith('ai_'));
// //     });
// //   }
// //
// //   // ✅ Add refresh method for debugging
// //   void _refreshCategories() async {
// //     setState(() {
// //       _isLoadingCategories = true;
// //     });
// //     await _loadCategories();
// //   }
// //
// //   Widget _buildCategoryDropdown() {
// //     if (_categories.isEmpty && !_isLoadingCategories) {
// //       return Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.orange.shade300),
// //           borderRadius: BorderRadius.circular(8),
// //           color: Colors.orange.shade50,
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(
// //               Icons.warning_amber_rounded,
// //               color: Colors.orange.shade600,
// //               size: 16,
// //             ),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: Text(
// //                 'No categories selected. Use AI search instead!',
// //                 style: TextStyle(
// //                   color: Colors.orange.shade700,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12),
// //       decoration: BoxDecoration(
// //         border: Border.all(color: Colors.grey.shade300),
// //         borderRadius: BorderRadius.circular(8),
// //         color: _isLoadingPlaces ? Colors.grey.shade100 : Colors.white,
// //       ),
// //       child: DropdownButtonHideUnderline(
// //         child: DropdownButton<String>(
// //           value: _selectedCategory,
// //           hint: Text(
// //             _isLoadingPlaces ? 'Loading...' : 'Select Category',
// //             style: TextStyle(
// //               color: _isLoadingPlaces
// //                   ? Colors.grey.shade500
// //                   : Colors.grey.shade700,
// //             ),
// //           ),
// //           isExpanded: true,
// //           items: _categories.map((category) {
// //             return DropdownMenuItem(
// //               value: category,
// //               child: Text(category, overflow: TextOverflow.ellipsis),
// //             );
// //           }).toList(),
// //           onChanged: _isLoadingPlaces
// //               ? null
// //               : (value) {
// //                   setState(() => _selectedCategory = value);
// //                   if (value != null) {
// //                     _fetchPopularPlaces(value);
// //                   }
// //                 },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLoadingOverlay() {
// //     if (!_isLoadingPlaces && !_isLoadingAI) return const SizedBox.shrink();
// //
// //     return Positioned(
// //       top: 0,
// //       left: 0,
// //       right: 0,
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [Colors.black54, Colors.transparent],
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             SizedBox(
// //               width: 20,
// //               height: 20,
// //               child: CircularProgressIndicator(
// //                 strokeWidth: 2,
// //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             Text(
// //               _isLoadingAI ? 'AI is thinking...' : 'Loading places...',
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPromptDialog() {
// //     if (!_isPromptVisible) return const SizedBox.shrink();
// //
// //     return Positioned(
// //       bottom: 120, // ✅ Moved up from bottom: 0
// //       left: 0,
// //       right: 0,
// //       child: SlideTransition(
// //         position: _promptSlideAnimation,
// //         child: Container(
// //           margin: const EdgeInsets.all(16),
// //           padding: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(20),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.2),
// //                 blurRadius: 20,
// //                 offset: const Offset(0, -5),
// //               ),
// //             ],
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Row(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [Colors.purple.shade400, Colors.blue.shade400],
// //                       ),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: const Icon(
// //                       Icons.auto_awesome,
// //                       color: Colors.white,
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Expanded(
// //                     child: Text(
// //                       'Ask AI for Recommendations',
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.black87,
// //                       ),
// //                     ),
// //                   ),
// //                   IconButton(
// //                     onPressed: _hidePrompt,
// //                     icon: const Icon(Icons.close, color: Colors.grey),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               Container(
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade50,
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(color: Colors.grey.shade200),
// //                 ),
// //                 child: TextField(
// //                   controller: _promptController,
// //                   maxLines: 3,
// //                   decoration: const InputDecoration(
// //                     hintText:
// //                         'e.g., "Find the best restaurants near me" or "Recommend schools for my kid"',
// //                     border: InputBorder.none,
// //                     contentPadding: EdgeInsets.all(16),
// //                   ),
// //                   onSubmitted: (_) => _submitPrompt(),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: OutlinedButton(
// //                       onPressed: _hidePrompt,
// //                       style: OutlinedButton.styleFrom(
// //                         padding: const EdgeInsets.symmetric(vertical: 12),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                       child: const Text('Cancel'),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     flex: 2,
// //                     child: ElevatedButton(
// //                       onPressed: _isLoadingAI ? null : _submitPrompt,
// //                       style: ElevatedButton.styleFrom(
// //                         padding: const EdgeInsets.symmetric(vertical: 12),
// //                         backgroundColor: Colors.purple.shade500,
// //                         foregroundColor: Colors.white,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                       child: _isLoadingAI
// //                           ? const SizedBox(
// //                               width: 20,
// //                               height: 20,
// //                               child: CircularProgressIndicator(
// //                                 strokeWidth: 2,
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(Icons.send, size: 18),
// //                                 SizedBox(width: 8),
// //                                 Text('Ask AI'),
// //                               ],
// //                             ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFloatingButtons() {
// //     return Column(
// //       mainAxisAlignment: MainAxisAlignment.end,
// //       children: [
// //         if (_isAIMode) ...[
// //           ScaleTransition(
// //             scale: _fabAnimation,
// //             child: FloatingActionButton(
// //               heroTag: "clear_ai",
// //               onPressed: _clearAIResults,
// //               backgroundColor: Colors.orange.shade500,
// //               child: const Icon(Icons.clear),
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //         ],
// //         if (_aiRecommendations.isNotEmpty || _places.isNotEmpty) ...[
// //           ScaleTransition(
// //             scale: _fabAnimation,
// //             child: FloatingActionButton(
// //               heroTag: "show_all",
// //               onPressed: _fitCameraToMarkers,
// //               backgroundColor: Colors.blue.shade500,
// //               child: const Icon(Icons.zoom_out_map),
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //         ],
// //         ScaleTransition(
// //           scale: _fabAnimation,
// //           child: FloatingActionButton.extended(
// //             heroTag: "ai_search",
// //             onPressed: _showPrompt,
// //             backgroundColor: Colors.white,
// //             icon: const Icon(Icons.auto_awesome),
// //             label: const Text('AI Search'),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Row(
// //           children: [
// //             Image.asset('assets/logos/goreto.png', height: 32),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: _isLoadingCategories
// //                   ? const Center(
// //                       child: SizedBox(
// //                         height: 20,
// //                         width: 20,
// //                         child: CircularProgressIndicator(strokeWidth: 2),
// //                       ),
// //                     )
// //                   : _buildCategoryDropdown(),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           // ✅ Add refresh button for debugging
// //           IconButton(
// //             icon: const Icon(Icons.refresh),
// //             onPressed: _refreshCategories,
// //             tooltip: 'Refresh categories',
// //           ),
// //           if (_currentPosition != null)
// //             IconButton(
// //               icon: const Icon(Icons.my_location),
// //               onPressed: () => _moveCameraToLocation(_center),
// //               tooltip: 'Go to my location',
// //             ),
// //         ],
// //       ),
// //       body: Stack(
// //         children: [
// //           if (_isLoadingLocation)
// //             const Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   CircularProgressIndicator(),
// //                   SizedBox(height: 16),
// //                   Text('Getting your location...'),
// //                 ],
// //               ),
// //             )
// //           else
// //             GoogleMap(
// //               initialCameraPosition: CameraPosition(target: _center, zoom: 12),
// //               onMapCreated: (controller) => _controller.complete(controller),
// //               markers: _markers,
// //               myLocationEnabled: true,
// //               myLocationButtonEnabled: false,
// //               zoomControlsEnabled: false,
// //               mapToolbarEnabled: false,
// //             ),
// //           _buildLoadingOverlay(),
// //           _buildPromptDialog(),
// //         ],
// //       ),
// //       floatingActionButton: _aiRecommendations.isNotEmpty || _places.isNotEmpty
// //           ? _buildFloatingButtons()
// //           : ScaleTransition(
// //               scale: _fabAnimation,
// //               child: FloatingActionButton.extended(
// //                 heroTag: "ai_search",
// //                 onPressed: _showPrompt,
// //                 backgroundColor: Colors.white,
// //                 icon: const Icon(Icons.auto_awesome),
// //                 label: const Text('AI Search'),
// //               ),
// //             ),
// //     );
// //   }
// // }
// //
// // // AI Recommendation Model
// // class AIRecommendationModel {
// //   final int id;
// //   final String name;
// //   final double latitude;
// //   final double longitude;
// //   final String city;
// //   final String category;
// //   final String description;
// //   final String dbDescription;
// //   final double? averageRating;
// //   final String placeId;
// //   final List<AIImageModel> images;
// //
// //   AIRecommendationModel({
// //     required this.id,
// //     required this.name,
// //     required this.latitude,
// //     required this.longitude,
// //     required this.city,
// //     required this.category,
// //     required this.description,
// //     required this.dbDescription,
// //     this.averageRating,
// //     required this.placeId,
// //     required this.images,
// //   });
// //
// //   factory AIRecommendationModel.fromJson(Map<String, dynamic> json) {
// //     return AIRecommendationModel(
// //       id: json['id'] ?? 0,
// //       name: json['name'] ?? 'Unknown Place',
// //       latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
// //       longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
// //       city: json['city'] ?? '',
// //       category: json['category'] ?? '',
// //       description: json['description'] ?? '',
// //       dbDescription: json['db_description'] ?? 'No description available',
// //       averageRating: json['average_rating']?.toDouble(),
// //       placeId: json['place_id'] ?? '',
// //       images: (json['images'] as List? ?? [])
// //           .map((img) => AIImageModel.fromJson(img))
// //           .toList(),
// //     );
// //   }
// // }
// //
// // class AIImageModel {
// //   final int id;
// //   final String imageUrl;
// //   final String status;
// //
// //   AIImageModel({
// //     required this.id,
// //     required this.imageUrl,
// //     required this.status,
// //   });
// //
// //   factory AIImageModel.fromJson(Map<String, dynamic> json) {
// //     return AIImageModel(
// //       id: json['id'] ?? 0,
// //       imageUrl: json['image_url'] ?? '',
// //       status: json['status'] ?? '',
// //     );
// //   }
// // }
// import 'dart:async';
// import 'dart:math' as math;
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../core/constants/api_endpoints.dart';
// import '../../../core/services/secure_storage_service.dart';
// import '../../../data/models/places/popular_places_model.dart';
// import '../popular_place_details_screen.dart';
//
// class PopularPlacesMapScreen extends StatefulWidget {
//   const PopularPlacesMapScreen({super.key});
//
//   @override
//   State<PopularPlacesMapScreen> createState() => _PopularPlacesMapScreenState();
// }
//
// class _PopularPlacesMapScreenState extends State<PopularPlacesMapScreen>
//     with TickerProviderStateMixin {
//   final Completer<GoogleMapController> _controller = Completer();
//   final Dio _dio = Dio();
//   final TextEditingController _promptController = TextEditingController();
//
//   // Animation controllers
//   late AnimationController _fabAnimationController;
//   late AnimationController _promptAnimationController;
//   late Animation<double> _fabAnimation;
//   late Animation<Offset> _promptSlideAnimation;
//
//   // State variables
//   List<String> _categories = [];
//   String? _selectedCategory;
//   Set<Marker> _markers = {};
//   List<PopularPlaceModel> _places = [];
//   List<PopularPlaceModel> _defaultPlaces = []; // NEW: For default places
//   List<AIRecommendationModel> _aiRecommendations = [];
//   Position? _currentPosition;
//   LatLng _center = const LatLng(27.6748, 85.4274); // Default Kathmandu location
//
//   // Loading states
//   bool _isLoadingLocation = true;
//   bool _isLoadingPlaces = false;
//   bool _isLoadingCategories = true;
//   bool _isLoadingAI = false;
//   bool _isLoadingDefaultPlaces = false; // NEW: Loading state for default places
//
//   // UI states
//   bool _isPromptVisible = false;
//   bool _isAIMode = false;
//   bool _isDefaultMode = true; // NEW: Track if showing default places
//
//   // Error states
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _initializeScreen();
//   }
//
//   void _setupAnimations() {
//     _fabAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     _promptAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//
//     _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _fabAnimationController,
//         curve: Curves.elasticOut,
//       ),
//     );
//
//     _promptSlideAnimation =
//         Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _promptAnimationController,
//             curve: Curves.easeOutBack,
//           ),
//         );
//
//     _fabAnimationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _fabAnimationController.dispose();
//     _promptAnimationController.dispose();
//     _promptController.dispose();
//     _dio.close();
//     super.dispose();
//   }
//
//   Future<void> _initializeScreen() async {
//     print('🚀 Initializing screen...');
//     await _setupDio();
//     await Future.wait([_loadCategories(), _getCurrentLocation()]);
//     print('✅ Screen initialization completed');
//   }
//
//   Future<void> _setupDio() async {
//     final storage = SecureStorageService();
//     final token = await storage.read('access_token');
//
//     _dio.options = BaseOptions(
//       baseUrl: ApiEndpoints.baseUrl,
//       headers: {
//         'Accept': 'application/json',
//         if (token != null) 'Authorization': 'Bearer $token',
//       },
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//     );
//   }
//
//   Future<void> _loadCategories() async {
//     print('🔄 Loading categories from SharedPreferences...');
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedCategories = prefs.getStringList('selected_categories') ?? [];
//
//       print('📦 Raw categories from SharedPrefs: $savedCategories');
//
//       if (mounted) {
//         setState(() {
//           _categories = savedCategories;
//           _isLoadingCategories = false;
//         });
//         print('✅ Categories loaded successfully: $_categories');
//       }
//     } catch (e) {
//       print('❌ Failed to load categories: $e');
//
//       if (mounted) {
//         setState(() {
//           _categories = [];
//           _errorMessage = 'Failed to load categories: ${e.toString()}';
//           _isLoadingCategories = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     print('📍 Getting current location...');
//
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showLocationError('Location permissions are denied');
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         _showLocationError('Location permissions are permanently denied');
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//
//       if (mounted) {
//         setState(() {
//           _currentPosition = position;
//           _center = LatLng(position.latitude, position.longitude);
//           _isLoadingLocation = false;
//         });
//
//         print(
//           '✅ Location obtained: ${position.latitude}, ${position.longitude}',
//         );
//         _addCurrentLocationMarker();
//         _moveCameraToLocation(_center);
//
//         // NEW: Fetch default places after getting location
//         await _fetchDefaultPlaces();
//       }
//     } catch (e) {
//       print('❌ Location error: $e');
//       _showLocationError('Failed to get current location: ${e.toString()}');
//     }
//   }
//
//   // NEW: Fetch default popular places based on user location
//   Future<void> _fetchDefaultPlaces() async {
//     if (_currentPosition == null || _isLoadingDefaultPlaces) return;
//
//     print('🌟 Fetching default popular places...');
//
//     setState(() {
//       _isLoadingDefaultPlaces = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final response = await _dio.get(
//         '/places/popular',
//         queryParameters: {
//           'latitude': _currentPosition!.latitude,
//           'longitude': _currentPosition!.longitude,
//         },
//       );
//
//       print('📡 Default Places API Response status: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final List data = response.data['data'] ?? [];
//         final List<PopularPlaceModel> places = data
//             .map((place) => PopularPlaceModel.fromJson(place))
//             .toList();
//
//         print('✅ Found ${places.length} default places');
//
//         if (mounted) {
//           setState(() {
//             _defaultPlaces = places;
//             _isDefaultMode = true;
//           });
//           _updateDefaultPlacesAndMarkers(places);
//         }
//       } else {
//         throw DioException(
//           requestOptions: response.requestOptions,
//           response: response,
//           message: 'Failed to fetch default places',
//         );
//       }
//     } on DioException catch (e) {
//       print('❌ Default places Dio error: ${e.message}');
//       _handleApiError(e);
//     } catch (e) {
//       print('❌ Default places generic error: $e');
//       _handleGenericError(e);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingDefaultPlaces = false;
//         });
//       }
//     }
//   }
//
//   // NEW: Update markers for default places
//   void _updateDefaultPlacesAndMarkers(List<PopularPlaceModel> places) {
//     if (!mounted) return;
//
//     setState(() {
//       // Clear existing place markers but keep current location
//       _markers.removeWhere(
//         (marker) => marker.markerId.value != 'current_location',
//       );
//
//       // Add default place markers with orange color to differentiate
//       final placeMarkers = places.map((place) {
//         return Marker(
//           markerId: MarkerId('default_${place.id}'),
//           position: LatLng(place.latitude, place.longitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueOrange,
//           ),
//           infoWindow: InfoWindow(
//             title: place.name,
//             snippet: '${place.category} • ${_formatDistance(place.distance)}',
//             onTap: () => _navigateToPlaceDetails(place),
//           ),
//         );
//       }).toSet();
//
//       _markers.addAll(placeMarkers);
//     });
//
//     // Fit camera to show all markers
//     if (places.isNotEmpty) {
//       _fitCameraToMarkers();
//     }
//   }
//
//   void _showLocationError(String message) {
//     if (mounted) {
//       setState(() {
//         _errorMessage = message;
//         _isLoadingLocation = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.orange,
//           action: SnackBarAction(
//             label: 'Retry',
//             onPressed: _getCurrentLocation,
//           ),
//         ),
//       );
//     }
//   }
//
//   void _addCurrentLocationMarker() {
//     if (_currentPosition == null) return;
//
//     final currentLocationMarker = Marker(
//       markerId: const MarkerId('current_location'),
//       position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       infoWindow: const InfoWindow(
//         title: 'Your Location',
//         snippet: 'Current Position',
//       ),
//     );
//
//     setState(() {
//       _markers.add(currentLocationMarker);
//     });
//   }
//
//   Future<void> _moveCameraToLocation(LatLng location) async {
//     try {
//       final controller = await _controller.future;
//       await controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(target: location, zoom: 14),
//         ),
//       );
//     } catch (e) {
//       print('❌ Camera movement error: $e');
//     }
//   }
//
//   Future<void> _fetchPopularPlaces(String category) async {
//     if (_isLoadingPlaces) {
//       print('⏳ Already loading places, skipping...');
//       return;
//     }
//
//     print('🔍 Fetching places for category: $category');
//
//     setState(() {
//       _isLoadingPlaces = true;
//       _errorMessage = null;
//       _isAIMode = false;
//       _isDefaultMode =
//           false; // NEW: Disable default mode when category is selected
//     });
//
//     try {
//       final response = await _dio.get(
//         '/places/popular',
//         queryParameters: {
//           'latitude': _center.latitude,
//           'longitude': _center.longitude,
//           'radius': 50000,
//           'limit': 5,
//           'category': category,
//         },
//       );
//
//       print('📡 API Response status: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final List data = response.data['data'] ?? [];
//         final List<PopularPlaceModel> places = data
//             .map((place) => PopularPlaceModel.fromJson(place))
//             .toList();
//
//         print('✅ Found ${places.length} places');
//         _updatePlacesAndMarkers(places);
//       } else {
//         throw DioException(
//           requestOptions: response.requestOptions,
//           response: response,
//           message: 'Failed to fetch places',
//         );
//       }
//     } on DioException catch (e) {
//       print('❌ Dio error: ${e.message}');
//       _handleApiError(e);
//     } catch (e) {
//       print('❌ Generic error: $e');
//       _handleGenericError(e);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingPlaces = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _fetchAIRecommendations(String prompt) async {
//     if (_isLoadingAI) return;
//
//     setState(() {
//       _isLoadingAI = true;
//       _errorMessage = null;
//       _isDefaultMode = false; // NEW: Disable default mode when AI is used
//     });
//
//     try {
//       final response = await _dio.post(
//         '/recommendations',
//         data: {'prompt': prompt},
//       );
//
//       if (response.statusCode == 200) {
//         final data = response.data;
//         final List locationData = data['locations'] ?? [];
//
//         final recommendations = locationData
//             .map((location) => AIRecommendationModel.fromJson(location))
//             .toList();
//
//         setState(() {
//           _aiRecommendations = recommendations;
//           _isAIMode = true;
//         });
//
//         _updateAIMarkersAndCamera(recommendations);
//         _hidePrompt();
//
//         // Show success message with recommendation summary
//         _showSuccessMessage(
//           'Found ${recommendations.length} AI recommendations!',
//         );
//       } else {
//         throw DioException(
//           requestOptions: response.requestOptions,
//           response: response,
//           message: 'Failed to fetch AI recommendations',
//         );
//       }
//     } on DioException catch (e) {
//       print('❌ AI API error: ${e.message}');
//       _handleApiError(e);
//     } catch (e) {
//       print('❌ AI Generic error: $e');
//       _handleGenericError(e);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingAI = false;
//         });
//       }
//     }
//   }
//
//   void _updateAIMarkersAndCamera(List<AIRecommendationModel> recommendations) {
//     if (!mounted) return;
//
//     setState(() {
//       // Clear existing place markers but keep current location
//       _markers.removeWhere(
//         (marker) => marker.markerId.value != 'current_location',
//       );
//
//       // Add AI recommendation markers
//       final aiMarkers = recommendations.map((recommendation) {
//         return Marker(
//           markerId: MarkerId('ai_${recommendation.id}'),
//           position: LatLng(recommendation.latitude, recommendation.longitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueViolet,
//           ),
//           infoWindow: InfoWindow(
//             title: recommendation.name,
//             snippet: '${recommendation.category} • ${recommendation.city}',
//             onTap: () => _navigateToAIRecommendationDetails(recommendation),
//           ),
//         );
//       }).toSet();
//
//       _markers.addAll(aiMarkers);
//     });
//
//     // Fit camera to show all markers
//     if (recommendations.isNotEmpty) {
//       _fitCameraToMarkers();
//     }
//   }
//
//   void _updatePlacesAndMarkers(List<PopularPlaceModel> places) {
//     if (!mounted) return;
//
//     setState(() {
//       _places = places;
//
//       // Clear existing place markers but keep current location
//       _markers.removeWhere(
//         (marker) => marker.markerId.value != 'current_location',
//       );
//
//       // Add new place markers
//       final placeMarkers = places.map((place) {
//         return Marker(
//           markerId: MarkerId(place.id.toString()),
//           position: LatLng(place.latitude, place.longitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           infoWindow: InfoWindow(
//             title: place.name,
//             snippet: '${place.category} • ${_formatDistance(place.distance)}',
//             onTap: () => _navigateToPlaceDetails(place),
//           ),
//         );
//       }).toSet();
//
//       _markers.addAll(placeMarkers);
//     });
//
//     // Fit camera to show all markers
//     if (places.isNotEmpty) {
//       _fitCameraToMarkers();
//     }
//   }
//
//   String _formatDistance(double distance) {
//     if (distance < 1000) {
//       return '${distance.toStringAsFixed(0)}m';
//     } else {
//       return '${(distance / 1000).toStringAsFixed(1)}km';
//     }
//   }
//
//   Future<void> _fitCameraToMarkers() async {
//     if (_markers.isEmpty) return;
//
//     try {
//       final controller = await _controller.future;
//
//       double minLat = double.infinity;
//       double maxLat = -double.infinity;
//       double minLng = double.infinity;
//       double maxLng = -double.infinity;
//
//       for (final marker in _markers) {
//         final position = marker.position;
//         minLat = math.min(minLat, position.latitude);
//         maxLat = math.max(maxLat, position.latitude);
//         minLng = math.min(minLng, position.longitude);
//         maxLng = math.max(maxLng, position.longitude);
//       }
//
//       await controller.animateCamera(
//         CameraUpdate.newLatLngBounds(
//           LatLngBounds(
//             southwest: LatLng(minLat, minLng),
//             northeast: LatLng(maxLat, maxLng),
//           ),
//           100.0,
//         ),
//       );
//     } catch (e) {
//       print('❌ Camera fit error: $e');
//     }
//   }
//
//   void _handleApiError(DioException e) {
//     String message = 'Network error occurred';
//
//     if (e.response?.statusCode == 401) {
//       message = 'Authentication failed. Please login again.';
//     } else if (e.response?.statusCode == 404) {
//       message = 'No places found for this request';
//     } else if (e.response?.statusCode == 500) {
//       message = 'Server error. Please try again later.';
//     } else if (e.type == DioExceptionType.connectionTimeout) {
//       message = 'Connection timeout. Check your internet connection.';
//     }
//
//     _showError(message);
//   }
//
//   void _handleGenericError(dynamic e) {
//     _showError('An unexpected error occurred: ${e.toString()}');
//   }
//
//   void _showError(String message) {
//     if (mounted) {
//       setState(() => _errorMessage = message);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           action: SnackBarAction(
//             label: 'Dismiss',
//             onPressed: () => setState(() => _errorMessage = null),
//           ),
//         ),
//       );
//     }
//   }
//
//   void _showSuccessMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   void _navigateToPlaceDetails(PopularPlaceModel place) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => PopularPlaceDetailScreen(place: place)),
//     );
//   }
//
//   void _navigateToAIRecommendationDetails(
//     AIRecommendationModel recommendation,
//   ) {
//     // Convert AI recommendation to PopularPlaceModel for existing detail screen
//     final place = PopularPlaceModel(
//       id: recommendation.id,
//       placeId: recommendation.placeId,
//       name: recommendation.name,
//       latitude: recommendation.latitude,
//       longitude: recommendation.longitude,
//       cityId: 0, // Not provided in AI response
//       description: recommendation.description,
//       averageRating: recommendation.averageRating,
//       distance: 0.0, // Calculate if needed
//       locationImages: recommendation.images.map((img) => img.imageUrl).toList(),
//       categoryId: 0, // Not provided
//       category: recommendation.category,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => PopularPlaceDetailScreen(place: place)),
//     );
//   }
//
//   void _showPrompt() {
//     setState(() {
//       _isPromptVisible = true;
//     });
//     _promptAnimationController.forward();
//   }
//
//   void _hidePrompt() {
//     _promptAnimationController.reverse().then((_) {
//       if (mounted) {
//         setState(() {
//           _isPromptVisible = false;
//         });
//       }
//     });
//   }
//
//   void _submitPrompt() {
//     final prompt = _promptController.text.trim();
//     if (prompt.isNotEmpty) {
//       _fetchAIRecommendations(prompt);
//       _promptController.clear();
//     }
//   }
//
//   void _clearAIResults() {
//     setState(() {
//       _isAIMode = false;
//       _aiRecommendations.clear();
//       // Clear AI markers but keep current location and regular place markers
//       _markers.removeWhere((marker) => marker.markerId.value.startsWith('ai_'));
//     });
//   }
//
//   // NEW: Clear category selection and show default places
//   void _clearCategorySelection() {
//     setState(() {
//       _selectedCategory = null;
//       _places.clear();
//       _isDefaultMode = true;
//     });
//     _updateDefaultPlacesAndMarkers(_defaultPlaces);
//   }
//
//   // ✅ Add refresh method for debugging
//   void _refreshCategories() async {
//     setState(() {
//       _isLoadingCategories = true;
//     });
//     await _loadCategories();
//   }
//
//   Widget _buildCategoryDropdown() {
//     if (_categories.isEmpty && !_isLoadingCategories) {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.orange.shade300),
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.orange.shade50,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.warning_amber_rounded,
//               color: Colors.orange.shade600,
//               size: 16,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'No categories selected. Showing popular places nearby!',
//                 style: TextStyle(
//                   color: Colors.orange.shade700,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//         color: _isLoadingPlaces ? Colors.grey.shade100 : Colors.white,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: _selectedCategory,
//                 hint: Text(
//                   _isLoadingPlaces
//                       ? 'Loading...'
//                       : _isDefaultMode
//                       ? 'Popular Places'
//                       : 'Select Category',
//                   style: TextStyle(
//                     color: _isLoadingPlaces
//                         ? Colors.grey.shade500
//                         : _isDefaultMode
//                         ? Colors.blue.shade700
//                         : Colors.grey.shade700,
//                     fontWeight: _isDefaultMode
//                         ? FontWeight.w500
//                         : FontWeight.normal,
//                   ),
//                 ),
//                 isExpanded: true,
//                 items: _categories.map((category) {
//                   return DropdownMenuItem(
//                     value: category,
//                     child: Text(category, overflow: TextOverflow.ellipsis),
//                   );
//                 }).toList(),
//                 onChanged: _isLoadingPlaces
//                     ? null
//                     : (value) {
//                         setState(() => _selectedCategory = value);
//                         if (value != null) {
//                           _fetchPopularPlaces(value);
//                         }
//                       },
//               ),
//             ),
//           ),
//           // NEW: Add clear button when category is selected
//           if (_selectedCategory != null && !_isLoadingPlaces) ...[
//             const SizedBox(width: 8),
//             GestureDetector(
//               onTap: _clearCategorySelection,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(Icons.clear, size: 16, color: Colors.grey.shade600),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingOverlay() {
//     if (!_isLoadingPlaces && !_isLoadingAI && !_isLoadingDefaultPlaces) {
//       return const SizedBox.shrink();
//     }
//
//     String loadingText = 'Loading...';
//     if (_isLoadingAI) {
//       loadingText = 'AI is thinking...';
//     } else if (_isLoadingPlaces) {
//       loadingText = 'Loading places...';
//     } else if (_isLoadingDefaultPlaces) {
//       loadingText = 'Loading popular places...';
//     }
//
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black54, Colors.transparent],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               loadingText,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPromptDialog() {
//     if (!_isPromptVisible) return const SizedBox.shrink();
//
//     return Positioned(
//       bottom: 120, // ✅ Moved up from bottom: 0
//       left: 0,
//       right: 0,
//       child: SlideTransition(
//         position: _promptSlideAnimation,
//         child: Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 20,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.purple.shade400, Colors.blue.shade400],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.auto_awesome,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Ask AI for Recommendations',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: _hidePrompt,
//                     icon: const Icon(Icons.close, color: Colors.grey),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: TextField(
//                   controller: _promptController,
//                   maxLines: 3,
//                   decoration: const InputDecoration(
//                     hintText:
//                         'e.g., "Find the best restaurants near me" or "Recommend schools for my kid"',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(16),
//                   ),
//                   onSubmitted: (_) => _submitPrompt(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: _hidePrompt,
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     flex: 2,
//                     child: ElevatedButton(
//                       onPressed: _isLoadingAI ? null : _submitPrompt,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         backgroundColor: Colors.purple.shade500,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: _isLoadingAI
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.send, size: 18),
//                                 SizedBox(width: 8),
//                                 Text('Ask AI'),
//                               ],
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFloatingButtons() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         if (_isAIMode) ...[
//           ScaleTransition(
//             scale: _fabAnimation,
//             child: FloatingActionButton(
//               heroTag: "clear_ai",
//               onPressed: _clearAIResults,
//               backgroundColor: Colors.orange.shade500,
//               child: const Icon(Icons.clear),
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//         if (_aiRecommendations.isNotEmpty ||
//             _places.isNotEmpty ||
//             _defaultPlaces.isNotEmpty) ...[
//           ScaleTransition(
//             scale: _fabAnimation,
//             child: FloatingActionButton(
//               heroTag: "show_all",
//               onPressed: _fitCameraToMarkers,
//               backgroundColor: Colors.blue.shade500,
//               child: const Icon(Icons.zoom_out_map),
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//         ScaleTransition(
//           scale: _fabAnimation,
//           child: FloatingActionButton.extended(
//             heroTag: "ai_search",
//             onPressed: _showPrompt,
//             backgroundColor: Colors.white,
//             icon: const Icon(Icons.auto_awesome),
//             label: const Text('AI Search'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Image.asset('assets/logos/goreto.png', height: 32),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _isLoadingCategories
//                   ? const Center(
//                       child: SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                     )
//                   : _buildCategoryDropdown(),
//             ),
//           ],
//         ),
//         actions: [
//           // ✅ Add refresh button for debugging
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshCategories,
//             tooltip: 'Refresh categories',
//           ),
//           if (_currentPosition != null)
//             IconButton(
//               icon: const Icon(Icons.my_location),
//               onPressed: () => _moveCameraToLocation(_center),
//               tooltip: 'Go to my location',
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           if (_isLoadingLocation)
//             const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Getting your location...'),
//                 ],
//               ),
//             )
//           else
//             GoogleMap(
//               initialCameraPosition: CameraPosition(target: _center, zoom: 12),
//               onMapCreated: (controller) => _controller.complete(controller),
//               markers: _markers,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//               zoomControlsEnabled: false,
//               mapToolbarEnabled: false,
//             ),
//           _buildLoadingOverlay(),
//           _buildPromptDialog(),
//         ],
//       ),
//       floatingActionButton:
//           _aiRecommendations.isNotEmpty ||
//               _places.isNotEmpty ||
//               _defaultPlaces.isNotEmpty
//           ? _buildFloatingButtons()
//           : ScaleTransition(
//               scale: _fabAnimation,
//               child: FloatingActionButton.extended(
//                 heroTag: "ai_search",
//                 onPressed: _showPrompt,
//                 backgroundColor: Colors.white,
//                 icon: const Icon(Icons.auto_awesome),
//                 label: const Text('AI Search'),
//               ),
//             ),
//     );
//   }
// }
//
// // AI Recommendation Model
// class AIRecommendationModel {
//   final int id;
//   final String name;
//   final double latitude;
//   final double longitude;
//   final String city;
//   final String category;
//   final String description;
//   final String dbDescription;
//   final double? averageRating;
//   final String placeId;
//   final List<AIImageModel> images;
//
//   AIRecommendationModel({
//     required this.id,
//     required this.name,
//     required this.latitude,
//     required this.longitude,
//     required this.city,
//     required this.category,
//     required this.description,
//     required this.dbDescription,
//     this.averageRating,
//     required this.placeId,
//     required this.images,
//   });
//
//   factory AIRecommendationModel.fromJson(Map<String, dynamic> json) {
//     return AIRecommendationModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? 'Unknown Place',
//       latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
//       longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
//       city: json['city'] ?? '',
//       category: json['category'] ?? '',
//       description: json['description'] ?? '',
//       dbDescription: json['db_description'] ?? 'No description available',
//       averageRating: json['average_rating']?.toDouble(),
//       placeId: json['place_id'] ?? '',
//       images: (json['images'] as List? ?? [])
//           .map((img) => AIImageModel.fromJson(img))
//           .toList(),
//     );
//   }
// }
//
// class AIImageModel {
//   final int id;
//   final String imageUrl;
//   final String status;
//
//   AIImageModel({
//     required this.id,
//     required this.imageUrl,
//     required this.status,
//   });
//
//   factory AIImageModel.fromJson(Map<String, dynamic> json) {
//     return AIImageModel(
//       id: json['id'] ?? 0,
//       imageUrl: json['image_url'] ?? '',
//       status: json['status'] ?? '',
//     );
//   }
// }
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

class _PopularPlacesMapScreenState extends State<PopularPlacesMapScreen>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final Dio _dio = Dio();
  final TextEditingController _promptController = TextEditingController();

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _promptAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _promptSlideAnimation;

  // State variables
  List<String> _categories = [];
  String? _selectedCategory;
  Set<Marker> _markers = {};
  List<PopularPlaceModel> _places = [];
  List<PopularPlaceModel> _defaultPlaces = []; // NEW: For default places
  List<AIRecommendationModel> _aiRecommendations = [];
  Position? _currentPosition;
  LatLng _center = const LatLng(27.6748, 85.4274); // Default Kathmandu location

  // Loading states
  bool _isLoadingLocation = true;
  bool _isLoadingPlaces = false;
  bool _isLoadingCategories = true;
  bool _isLoadingAI = false;
  bool _isLoadingDefaultPlaces = false; // NEW: Loading state for default places

  // UI states
  bool _isPromptVisible = false;
  bool _isAIMode = false;
  bool _isDefaultMode = true; // NEW: Track if showing default places

  // Error states
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeScreen();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _promptAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _promptSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _promptAnimationController,
            curve: Curves.easeOutBack,
          ),
        );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _promptAnimationController.dispose();
    _promptController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    print('🚀 Initializing screen...');
    await _setupDio();
    await Future.wait([_loadCategories(), _getCurrentLocation()]);
    print('✅ Screen initialization completed');
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
    print('🔄 Loading categories from SharedPreferences...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategories = prefs.getStringList('selected_categories') ?? [];

      print('📦 Raw categories from SharedPrefs: $savedCategories');

      if (mounted) {
        setState(() {
          _categories = savedCategories;
          _isLoadingCategories = false;
        });
        print('✅ Categories loaded successfully: $_categories');
      }
    } catch (e) {
      print('❌ Failed to load categories: $e');

      if (mounted) {
        setState(() {
          _categories = [];
          _errorMessage = 'Failed to load categories: ${e.toString()}';
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    print('📍 Getting current location...');

    try {
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

        print(
          '✅ Location obtained: ${position.latitude}, ${position.longitude}',
        );
        _addCurrentLocationMarker();
        _moveCameraToLocation(_center);

        // NEW: Fetch default places after getting location
        await _fetchDefaultPlaces();
      }
    } catch (e) {
      print('❌ Location error: $e');
      _showLocationError('Failed to get current location: ${e.toString()}');
    }
  }

  // NEW: Fetch default popular places based on user location
  Future<void> _fetchDefaultPlaces() async {
    if (_currentPosition == null || _isLoadingDefaultPlaces) return;

    print('🌟 Fetching default popular places...');

    setState(() {
      _isLoadingDefaultPlaces = true;
      _errorMessage = null;
    });

    try {
      // Fetch more places by increasing limit and getting all pages
      final response = await _dio.get(
        '/places/popular',
        queryParameters: {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'limit': 50, // Increase limit to get more places
          'radius': 25000, // Add radius parameter (25km)
        },
      );

      print('📡 Default Places API Response status: ${response.statusCode}');
      print('📡 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        final List data = responseData['data'] ?? [];
        final int total = responseData['total'] ?? 0;

        print(
          '📊 API returned ${data.length} places out of $total total places',
        );

        if (data.isEmpty) {
          print('⚠️ No places found in API response');
          if (mounted) {
            setState(() {
              _defaultPlaces = [];
              _isDefaultMode = true;
            });
            _showError('No popular places found nearby');
          }
          return;
        }

        final List<PopularPlaceModel> places = data
            .map((place) {
              try {
                return PopularPlaceModel.fromJson(place);
              } catch (e) {
                print('❌ Error parsing place: $e');
                print('🔍 Place data: $place');
                return null;
              }
            })
            .where((place) => place != null)
            .cast<PopularPlaceModel>()
            .toList();

        print('✅ Successfully parsed ${places.length} places');

        // Debug: Print first few places
        for (int i = 0; i < math.min(3, places.length); i++) {
          final place = places[i];
          print(
            '🏢 Place ${i + 1}: ${place.name} at (${place.latitude}, ${place.longitude})',
          );
        }

        if (mounted) {
          setState(() {
            _defaultPlaces = places;
            _isDefaultMode = true;
          });
          _updateDefaultPlacesAndMarkers(places);
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch default places',
        );
      }
    } on DioException catch (e) {
      print('❌ Default places Dio error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      _handleApiError(e);
    } catch (e) {
      print('❌ Default places generic error: $e');
      _handleGenericError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDefaultPlaces = false;
        });
      }
    }
  }

  // NEW: Update markers for default places
  void _updateDefaultPlacesAndMarkers(List<PopularPlaceModel> places) {
    if (!mounted) return;

    print('🗺️ Updating markers for ${places.length} default places');

    setState(() {
      // Clear existing place markers but keep current location
      _markers.removeWhere(
        (marker) => marker.markerId.value != 'current_location',
      );

      print('🧹 Cleared existing markers, keeping current_location');

      // Add default place markers with orange color to differentiate
      final placeMarkers = places.asMap().entries.map((entry) {
        final index = entry.key;
        final place = entry.value;

        print(
          '📍 Creating marker ${index + 1}: ${place.name} at (${place.latitude}, ${place.longitude})',
        );

        return Marker(
          markerId: MarkerId('default_${place.id}'),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.category} • ${_formatDistance(place.distance)}',
            onTap: () {
              print('🎯 Tapped on place: ${place.name}');
              _navigateToPlaceDetails(place);
            },
          ),
        );
      }).toSet();

      print('✅ Created ${placeMarkers.length} markers');
      _markers.addAll(placeMarkers);

      print('📊 Total markers now: ${_markers.length}');

      // Debug: Print all marker IDs
      final markerIds = _markers.map((m) => m.markerId.value).toList();
      print('🏷️ All marker IDs: $markerIds');
    });

    // Fit camera to show all markers
    if (places.isNotEmpty) {
      print('📷 Fitting camera to show all markers');
      _fitCameraToMarkers();
    } else {
      print('⚠️ No places to fit camera to');
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
    try {
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 14),
        ),
      );
    } catch (e) {
      print('❌ Camera movement error: $e');
    }
  }

  Future<void> _fetchPopularPlaces(String category) async {
    if (_isLoadingPlaces) {
      print('⏳ Already loading places, skipping...');
      return;
    }

    print('🔍 Fetching places for category: $category');

    setState(() {
      _isLoadingPlaces = true;
      _errorMessage = null;
      _isAIMode = false;
      _isDefaultMode =
          false; // NEW: Disable default mode when category is selected
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

      print('📡 API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final List<PopularPlaceModel> places = data
            .map((place) => PopularPlaceModel.fromJson(place))
            .toList();

        print('✅ Found ${places.length} places');
        _updatePlacesAndMarkers(places);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch places',
        );
      }
    } on DioException catch (e) {
      print('❌ Dio error: ${e.message}');
      _handleApiError(e);
    } catch (e) {
      print('❌ Generic error: $e');
      _handleGenericError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPlaces = false;
        });
      }
    }
  }

  Future<void> _fetchAllDefaultPlaces() async {
    if (_currentPosition == null || _isLoadingDefaultPlaces) return;

    print('🌟 Fetching ALL default popular places...');

    setState(() {
      _isLoadingDefaultPlaces = true;
      _errorMessage = null;
    });

    try {
      List<PopularPlaceModel> allPlaces = [];
      int currentPage = 1;
      int totalPages = 1;

      do {
        final response = await _dio.get(
          '/places/popular',
          queryParameters: {
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
            'page': currentPage,
            'per_page': 20, // Get 20 places per page
            'radius': 25000, // 25km radius
          },
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          final List data = responseData['data'] ?? [];
          totalPages = responseData['last_page'] ?? 1;

          print('📄 Page $currentPage/$totalPages: ${data.length} places');

          final List<PopularPlaceModel> pageePlaces = data
              .map((place) {
                try {
                  return PopularPlaceModel.fromJson(place);
                } catch (e) {
                  print('❌ Error parsing place: $e');
                  return null;
                }
              })
              .where((place) => place != null)
              .cast<PopularPlaceModel>()
              .toList();

          allPlaces.addAll(pageePlaces);
          currentPage++;
        } else {
          break;
        }
      } while (currentPage <= totalPages &&
          currentPage <= 5); // Limit to 5 pages max

      print('✅ Fetched total ${allPlaces.length} places from all pages');

      if (mounted) {
        setState(() {
          _defaultPlaces = allPlaces;
          _isDefaultMode = true;
        });
        _updateDefaultPlacesAndMarkers(allPlaces);
      }
    } on DioException catch (e) {
      print('❌ Fetch all places Dio error: ${e.message}');
      _handleApiError(e);
    } catch (e) {
      print('❌ Fetch all places generic error: $e');
      _handleGenericError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDefaultPlaces = false;
        });
      }
    }
  }

  Future<void> _fetchAIRecommendations(String prompt) async {
    if (_isLoadingAI) return;

    setState(() {
      _isLoadingAI = true;
      _errorMessage = null;
      _isDefaultMode = false; // NEW: Disable default mode when AI is used
    });

    try {
      final response = await _dio.post(
        '/recommendations',
        data: {'prompt': prompt},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List locationData = data['locations'] ?? [];

        final recommendations = locationData
            .map((location) => AIRecommendationModel.fromJson(location))
            .toList();

        setState(() {
          _aiRecommendations = recommendations;
          _isAIMode = true;
        });

        _updateAIMarkersAndCamera(recommendations);
        _hidePrompt();

        // Show success message with recommendation summary
        _showSuccessMessage(
          'Found ${recommendations.length} AI recommendations!',
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch AI recommendations',
        );
      }
    } on DioException catch (e) {
      print('❌ AI API error: ${e.message}');
      _handleApiError(e);
    } catch (e) {
      print('❌ AI Generic error: $e');
      _handleGenericError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAI = false;
        });
      }
    }
  }

  void _updateAIMarkersAndCamera(List<AIRecommendationModel> recommendations) {
    if (!mounted) return;

    setState(() {
      // Clear existing place markers but keep current location
      _markers.removeWhere(
        (marker) => marker.markerId.value != 'current_location',
      );

      // Add AI recommendation markers
      final aiMarkers = recommendations.map((recommendation) {
        return Marker(
          markerId: MarkerId('ai_${recommendation.id}'),
          position: LatLng(recommendation.latitude, recommendation.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: InfoWindow(
            title: recommendation.name,
            snippet: '${recommendation.category} • ${recommendation.city}',
            onTap: () => _navigateToAIRecommendationDetails(recommendation),
          ),
        );
      }).toSet();

      _markers.addAll(aiMarkers);
    });

    // Fit camera to show all markers
    if (recommendations.isNotEmpty) {
      _fitCameraToMarkers();
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

    try {
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
          100.0,
        ),
      );
    } catch (e) {
      print('❌ Camera fit error: $e');
    }
  }

  void _handleApiError(DioException e) {
    String message = 'Network error occurred';

    if (e.response?.statusCode == 401) {
      message = 'Authentication failed. Please login again.';
    } else if (e.response?.statusCode == 404) {
      message = 'No places found for this request';
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToPlaceDetails(PopularPlaceModel place) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PopularPlaceDetailScreen(place: place)),
    );
  }

  void _navigateToAIRecommendationDetails(
    AIRecommendationModel recommendation,
  ) {
    // Convert AI recommendation to PopularPlaceModel for existing detail screen
    final place = PopularPlaceModel(
      id: recommendation.id,
      placeId: recommendation.placeId,
      name: recommendation.name,
      latitude: recommendation.latitude,
      longitude: recommendation.longitude,
      cityId: 0, // Not provided in AI response
      description: recommendation.description,
      averageRating: recommendation.averageRating,
      distance: 0.0, // Calculate if needed
      locationImages: recommendation.images.map((img) => img.imageUrl).toList(),
      categoryId: 0, // Not provided
      category: recommendation.category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PopularPlaceDetailScreen(place: place)),
    );
  }

  void _showPrompt() {
    setState(() {
      _isPromptVisible = true;
    });
    _promptAnimationController.forward();
  }

  void _hidePrompt() {
    _promptAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isPromptVisible = false;
        });
      }
    });
  }

  void _submitPrompt() {
    final prompt = _promptController.text.trim();
    if (prompt.isNotEmpty) {
      _fetchAIRecommendations(prompt);
      _promptController.clear();
    }
  }

  void _clearAIResults() {
    setState(() {
      _isAIMode = false;
      _aiRecommendations.clear();
      // Clear AI markers but keep current location and regular place markers
      _markers.removeWhere((marker) => marker.markerId.value.startsWith('ai_'));
    });
  }

  // NEW: Clear category selection and show default places
  void _clearCategorySelection() {
    setState(() {
      _selectedCategory = null;
      _places.clear();
      _isDefaultMode = true;
    });
    _updateDefaultPlacesAndMarkers(_defaultPlaces);
  }

  // NEW: Refresh functionality to re-fetch default popular places
  Future<void> _refreshDefaultPlaces() async {
    if (_currentPosition == null) {
      _showError('Location not available. Please enable location services.');
      return;
    }

    print('🔄 Refreshing default popular places...');

    // Reset to default mode
    setState(() {
      _selectedCategory = null;
      _places.clear();
      _aiRecommendations.clear();
      _isAIMode = false;
      _isDefaultMode = true;
    });

    // Use the enhanced method to get more places
    await _fetchAllDefaultPlaces();

    // Show success message
    _showSuccessMessage('Popular places refreshed!');
  }

  // ✅ Add refresh method for debugging
  Future<void> _refreshCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    await _loadCategories();
  }

  // NEW: Comprehensive refresh method
  Future<void> _refreshAll() async {
    await Future.wait([_refreshCategories(), _refreshDefaultPlaces()]);
  }

  Widget _buildCategoryDropdown() {
    if (_categories.isEmpty && !_isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange.shade50,
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No categories selected. Showing popular places nearby!',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: _isLoadingPlaces ? Colors.grey.shade100 : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                hint: Text(
                  _isLoadingPlaces
                      ? 'Loading...'
                      : _isDefaultMode
                      ? 'Popular Places'
                      : 'Select Category',
                  style: TextStyle(
                    color: _isLoadingPlaces
                        ? Colors.grey.shade500
                        : _isDefaultMode
                        ? Colors.blue.shade700
                        : Colors.grey.shade700,
                    fontWeight: _isDefaultMode
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
                isExpanded: true,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, overflow: TextOverflow.ellipsis),
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
          ),
          // NEW: Add clear button when category is selected
          if (_selectedCategory != null && !_isLoadingPlaces) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearCategorySelection,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.clear, size: 16, color: Colors.grey.shade600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoadingPlaces && !_isLoadingAI && !_isLoadingDefaultPlaces) {
      return const SizedBox.shrink();
    }

    String loadingText = 'Loading...';
    if (_isLoadingAI) {
      loadingText = 'AI is thinking...';
    } else if (_isLoadingPlaces) {
      loadingText = 'Loading places...';
    } else if (_isLoadingDefaultPlaces) {
      loadingText = 'Loading popular places...';
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              loadingText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptDialog() {
    if (!_isPromptVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 120, // ✅ Moved up from bottom: 0
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _promptSlideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.blue.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ask AI for Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _hidePrompt,
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g., "Find the best restaurants near me" or "Recommend schools for my kid"',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onSubmitted: (_) => _submitPrompt(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _hidePrompt,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoadingAI ? null : _submitPrompt,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.purple.shade500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoadingAI
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 18),
                                SizedBox(width: 8),
                                Text('Ask AI'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isAIMode) ...[
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              heroTag: "clear_ai",
              onPressed: _clearAIResults,
              backgroundColor: Colors.orange.shade500,
              child: const Icon(Icons.clear),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // NEW: Quick refresh button for default places
        if (_isDefaultMode && !_isLoadingDefaultPlaces) ...[
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              heroTag: "refresh_default",
              onPressed: _refreshDefaultPlaces,
              backgroundColor: Colors.green.shade500,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_aiRecommendations.isNotEmpty ||
            _places.isNotEmpty ||
            _defaultPlaces.isNotEmpty) ...[
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              heroTag: "show_all",
              onPressed: _fitCameraToMarkers,
              backgroundColor: Colors.blue.shade500,
              child: const Icon(Icons.zoom_out_map),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            heroTag: "ai_search",
            onPressed: _showPrompt,
            backgroundColor: Colors.white,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AI Search'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logos/goreto.png', height: 32),
            const SizedBox(width: 12),
            Expanded(
              child: _isLoadingCategories
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _buildCategoryDropdown(),
            ),
          ],
        ),
        actions: [
          // NEW: Enhanced refresh button with multiple options
          PopupMenuButton<String>(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh options',
            onSelected: (value) {
              switch (value) {
                case 'refresh_places':
                  _refreshDefaultPlaces();
                  break;
                case 'refresh_categories':
                  _refreshCategories();
                  break;
                case 'refresh_all':
                  _refreshAll();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh_places',
                child: Row(
                  children: [
                    Icon(Icons.place, size: 16),
                    SizedBox(width: 8),
                    Text('Refresh Places'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh_categories',
                child: Row(
                  children: [
                    Icon(Icons.category, size: 16),
                    SizedBox(width: 8),
                    Text('Refresh Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh_all',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 8),
                    Text('Refresh All'),
                  ],
                ),
              ),
            ],
          ),
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () => _moveCameraToLocation(_center),
              tooltip: 'Go to my location',
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoadingLocation)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
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
          _buildPromptDialog(),
        ],
      ),
      floatingActionButton:
          _aiRecommendations.isNotEmpty ||
              _places.isNotEmpty ||
              _defaultPlaces.isNotEmpty
          ? _buildFloatingButtons()
          : ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                heroTag: "ai_search",
                onPressed: _showPrompt,
                backgroundColor: Colors.white,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI Search'),
              ),
            ),
    );
  }
}

// AI Recommendation Model
class AIRecommendationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String city;
  final String category;
  final String description;
  final String dbDescription;
  final double? averageRating;
  final String placeId;
  final List<AIImageModel> images;

  AIRecommendationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.category,
    required this.description,
    required this.dbDescription,
    this.averageRating,
    required this.placeId,
    required this.images,
  });

  factory AIRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AIRecommendationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Place',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      city: json['city'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      dbDescription: json['db_description'] ?? 'No description available',
      averageRating: json['average_rating']?.toDouble(),
      placeId: json['place_id'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((img) => AIImageModel.fromJson(img))
          .toList(),
    );
  }
}

class AIImageModel {
  final int id;
  final String imageUrl;
  final String status;

  AIImageModel({
    required this.id,
    required this.imageUrl,
    required this.status,
  });

  factory AIImageModel.fromJson(Map<String, dynamic> json) {
    return AIImageModel(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
