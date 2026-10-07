import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const ChromaApp());
}

class ChromaApp extends StatelessWidget {
  const ChromaApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Chroma',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      themeMode: ThemeMode.system,

      debugShowCheckedModeBanner: false,

      home: const ChromaHomePage(),
    );
  }
} 

class ChromaHomePage extends StatelessWidget {
  const ChromaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chroma'),
      ),
      body: const Center(
        child: Text('Mood-Based Color Palette Generator'),
      ),
    );
  }
}