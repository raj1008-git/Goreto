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
import 'core/services/pusher_service.dart';
import 'features/storyboard/providers/story_board_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pusherService = PusherService();
  await pusherService.initPusher();
  await pusherService.connect();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryBoardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()..fetchPlaces()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(ReviewApiService(Dio())),
        ),
      ],
      child: const MyApp(), // Your main app widget
    ),
  );
}
