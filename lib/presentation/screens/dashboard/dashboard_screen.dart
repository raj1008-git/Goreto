import 'package:flutter/material.dart';
import 'package:goreto/core/constants/appColors.dart';
import 'package:goreto/core/utils/media_query_helper.dart';
import 'package:goreto/data/providers/place_provider.dart';
import 'package:goreto/presentation/widgets/place_card.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final double topSectionHeight = screen.heightP(51);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<PlaceProvider>(
        builder: (context, placeProvider, _) {
          final places = placeProvider.places;

          return CustomScrollView(
            slivers: [
              // Top section (non-scrollable)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: topSectionHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/story1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: 16,
                        child: Image.asset(
                          'assets/logos/goreto.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 20,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 150,
                        left: 16,
                        right: 16,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Explore Nepal Today",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Goreto - Take your travel experience to next level",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
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
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search destination',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.search, color: AppColors.primary),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 45,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    width: 120,
                                    child: Center(
                                      child: Text(
                                        "Lakes ${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
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
              if (placeProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
