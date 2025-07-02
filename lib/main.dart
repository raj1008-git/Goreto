import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goreto/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'app.dart';
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
      ],
      child: const MyApp(), // Your main app widget
    ),
  );
}
