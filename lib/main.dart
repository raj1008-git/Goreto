import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:goreto/data/datasources/remote/review_api_service.dart';
import 'package:goreto/data/providers/auth_provider.dart';
import 'package:goreto/data/providers/place_provider.dart';
import 'package:goreto/data/providers/review_provider.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/datasources/remote/activity_api_service.dart';
import 'data/datasources/remote/group_service_api.dart';
import 'data/providers/activity_provider.dart';
import 'data/providers/category_filter_provider.dart';
import 'data/providers/group_provider.dart';
import 'data/providers/like_and_comment_provider.dart';
import 'data/providers/location_provider.dart';
import 'data/providers/my_post_provider.dart';
import 'data/providers/optimized_place_provider.dart';
import 'data/providers/popular_place_provider.dart';
import 'data/providers/post_providers.dart';
import 'data/providers/post_review_provider.dart';
import 'data/providers/search_provider.dart';
import 'features/storyboard/providers/story_board_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51RidvvFJdJ18eFS1fTgTCklody1FH0GXY5i0n4Ztsfgzc1C7pnFzC8o7FXcfCbc3q05ce4AhJ8HFHcJfwFCMbSyI00TV5ZxqSA';
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryBoardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => PopularPlaceProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => MyPostProvider()),
        ChangeNotifierProvider(create: (_) => PostReviewProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => OptimizedPlaceProvider()),
        ChangeNotifierProvider(create: (_) => CategoryFilterProvider()),
        ChangeNotifierProvider(create: (_) => LikeCommentProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(
          create: (_) => GroupProvider(GroupService(Dio())),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(ReviewApiService(Dio())),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(ActivityApiService(Dio())),
        ),
      ],
      child: const MyApp(), // Your main app widget
    ),
  );
}
