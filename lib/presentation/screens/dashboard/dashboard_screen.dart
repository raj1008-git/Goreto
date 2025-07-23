import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goreto/core/constants/appColors.dart';
import 'package:goreto/core/utils/app_loader.dart';
import 'package:goreto/core/utils/media_query_helper.dart';
import 'package:goreto/data/providers/place_provider.dart';
import 'package:goreto/presentation/widgets/place_card.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/category_class.dart';
import '../../../core/constants/dashboad_play.dart';
import '../../../core/services/dio_client.dart';
import '../../../core/services/login_count_service.dart';
import '../../../data/datasources/remote/category_api_service.dart';
import '../../../data/providers/category_filter_provider.dart';
import '../../../data/providers/category_selection_provider.dart';
import '../../../features/category/widgets/category_selection_popup.dart';
import '../../../routes/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  dynamic _currentImageIndex = 0;
  late Timer _imageTimer;
  final LoginCountService _loginCountService = LoginCountService();

  @override
  void initState() {
    super.initState();
    _checkAndShowCategoryPopup();
    // Fetch recommended and popular places after widget build
    Future.microtask(() {
      final placeProvider = Provider.of<PlaceProvider>(context, listen: false);

      placeProvider.fetchPlaces();
    });

    // Your existing carousel timer
    _imageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % dashboardImages.length;
      });
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    super.dispose();
  }

  void _showCategorySelectionPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => ChangeNotifierProvider(
        create: (_) => CategorySelectionProvider(
          CategoryApiService(
            DioClient().dio,
          ), // You'll need to import DioClient
        ),
        child: CategorySelectionPopup(
          onCompleted: () {
            // Optional: Refresh data after categories are selected
            _refreshData();
          },
        ),
      ),
    );
  }

  // Pull-to-refresh method
  Future<void> _refreshData() async {
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);

    final categoryProvider = Provider.of<CategoryFilterProvider>(
      context,
      listen: false,
    );

    // Clear any existing filters
    categoryProvider.clearFilter();

    // Fetch fresh data
    await Future.wait([placeProvider.fetchPlaces()]);
  }

  Future<void> _checkAndShowCategoryPopup() async {
    // Wait a bit for the widget to fully build
    await Future.delayed(const Duration(milliseconds: 500));

    final loginCount = await _loginCountService.getLoginCount();

    // Show popup only on first login (when count is 1)
    if (loginCount == 1 && mounted) {
      _showCategorySelectionPopup();
    }
  }

  void _showCategoryPopupManually() {
    _showCategorySelectionPopup();
  }

  void _onCategoryTapped(String categoryName) {
    final categoryProvider = Provider.of<CategoryFilterProvider>(
      context,
      listen: false,
    );
    categoryProvider.fetchPlacesByCategory(categoryName);
  }

  void _onBackToDefault() {
    final categoryProvider = Provider.of<CategoryFilterProvider>(
      context,
      listen: false,
    );
    final placeProvider = Provider.of<PlaceProvider>(context, listen: false);

    // Clear category filter
    categoryProvider.clearFilter();

    // Refetch default data
    placeProvider.fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final double topSectionHeight = screen.heightP(51);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer2<PlaceProvider, CategoryFilterProvider>(
        builder: (context, placeProvider, categoryProvider, _) {
          final places = placeProvider.places;

          final categoryPlaces = categoryProvider.categoryPlaces;

          final isLoading =
              placeProvider.isLoading || categoryProvider.isLoading;

          final isFilterMode = categoryProvider.isFilterMode;

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primary,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              slivers: [
                // Top section (non-scrollable)
                SliverToBoxAdapter(
                  child: Container(
                    height: topSectionHeight,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 800),
                            child: SizedBox.expand(
                              key: ValueKey<String>(
                                dashboardImages[_currentImageIndex],
                              ),
                              child: Image.asset(
                                dashboardImages[_currentImageIndex],
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 40,
                          left: 16,
                          child: Image.asset(
                            'assets/logos/goreto.png',
                            width: 100,
                            height: 100,
                          ),
                        ),

                        // Back button when in filter mode
                        if (isFilterMode)
                          Positioned(
                            top: 50,
                            left: 120,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _onBackToDefault,
                                tooltip: 'Back to Home',
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),

                        Positioned(
                          top: 50,
                          right: 20,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 18),
                              const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 18),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.groupScreen,
                                  );
                                },
                                child: const Icon(
                                  Icons.groups_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: 130,
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFilterMode
                                    ? "Explore ${categoryProvider.selectedCategory}"
                                    : "Explore Nepal Today",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isFilterMode
                                    ? "Places in ${categoryProvider.selectedCategory} category"
                                    : "Goreto - Take your travel experience to next level",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/search',
                                  ); // replace with your route name
                                },
                                child: SizedBox(
                                  height: 48,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: const [
                                        Expanded(
                                          child: Text(
                                            'Search destination',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.search,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              SizedBox(
                                height: 55,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    final category = categories[index];
                                    final isSelected =
                                        isFilterMode &&
                                        categoryProvider.selectedCategory ==
                                            category.name;

                                    return GestureDetector(
                                      onTap: () =>
                                          _onCategoryTapped(category.name),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              category.icon,
                                              size: 20,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              category.name,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Body scrollable area
                if (isLoading)
                  const SliverFillRemaining(child: Center(child: AppLoader()))
                else if (isFilterMode)
                  // Show category filtered places
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${categoryProvider.selectedCategory} Places",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "${categoryPlaces.length} found",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (categoryPlaces.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text(
                                  "No places found in this category",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 230,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: categoryPlaces.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  return PlaceCard(
                                    place: categoryPlaces[index],
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  // Show default recommended and popular places
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recommended Places Section
                          const Text(
                            "Recommended for You",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 230,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: places.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return PlaceCard(place: places[index]);
                              },
                            ),
                          ),

                          // const SizedBox(height: 24),
                          //
                          // // Popular Places Nearby Section
                          // const Text(
                          //   "Popular Places Nearby",
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          // SizedBox(
                          //   height: 230,
                          //   child: ListView.separated(
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: popularPlaces.length,
                          //     separatorBuilder: (context, index) =>
                          //         const SizedBox(width: 12),
                          //     itemBuilder: (context, index) {
                          //       final popularPlace = popularPlaces[index];
                          //       return PopularPlaceCard(place: popularPlace);
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
