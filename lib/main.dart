import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goreto/data/datasources/remote/review_api_service.dart';
import 'package:goreto/data/providers/auth_provider.dart';
import 'package:goreto/data/providers/place_provider.dart';
import 'package:goreto/data/providers/review_provider.dart';
import 'package:goreto/features/chat/providers/chat_provider.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/providers/my_post_provider.dart';
import 'data/providers/popular_place_provider.dart';
import 'data/providers/post_providers.dart';
import 'features/storyboard/providers/story_board_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryBoardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PopularPlaceProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => MyPostProvider()),

        ChangeNotifierProvider(
          create: (_) => ReviewProvider(ReviewApiService(Dio())),
        ),
      ],
      child: const MyApp(), // Your main app widget
    ),
  );
}
