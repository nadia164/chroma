import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();

  await themeController.load();

  runApp(ChromaApp(themeController: themeController));
}

class ChromaApp extends StatelessWidget {
  final ThemeController themeController;

  const ChromaApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Chroma',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
          debugShowCheckedModeBanner: false,
          home: HomeScreen(themeController: themeController),
        );
      },
    );
  }
}
