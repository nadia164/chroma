import 'dart:math';

import 'package:flutter/material.dart';

class PaletteGenerator {
  static final Random _random = Random();

  static List<Color> seedColorsForPrompt(String prompt) {
    final normalizedPrompt = prompt.toLowerCase().trim();

    if (normalizedPrompt.contains('autumn') ||
        normalizedPrompt.contains('fall') ||
        normalizedPrompt.contains('forest')) {
      return _autumnForestPalette();
    }

    if (normalizedPrompt.contains('ocean') ||
        normalizedPrompt.contains('sea') ||
        normalizedPrompt.contains('water')) {
      return _oceanPalette();
    }

    if (normalizedPrompt.contains('sunset') ||
        normalizedPrompt.contains('sunrise')) {
      return _sunsetPalette();
    }

    if (normalizedPrompt.contains('cyberpunk') ||
        normalizedPrompt.contains('neon')) {
      return _cyberpunkPalette();
    }

    if (normalizedPrompt.contains('melancholy') ||
        normalizedPrompt.contains('sad') ||
        normalizedPrompt.contains('lonely')) {
      return _melancholyPalette();
    }

    return _randomPalette();
  }

  static List<Color> _autumnForestPalette() {
    return const [
      Color(0xFF24382F),
      Color(0xFF4D5C3C),
      Color(0xFF8A5A3B),
      Color(0xFFC47A3D),
      Color(0xFFE2C48D),
    ];
  }

  static List<Color> _oceanPalette() {
    return const [
      Color(0xFF0B3D4A),
      Color(0xFF126E82),
      Color(0xFF2A9D8F),
      Color(0xFF64C7C0),
      Color(0xFFC5E8E5),
    ];
  }

  static List<Color> _sunsetPalette() {
    return const [
      Color(0xFF4A1942),
      Color(0xFF8F3B5F),
      Color(0xFFD45D5D),
      Color(0xFFF28C5B),
      Color(0xFFFFD18A),
    ];
  }

  static List<Color> _cyberpunkPalette() {
    return const [
      Color(0xFF16002E),
      Color(0xFF5B1A8E),
      Color(0xFFB026FF),
      Color(0xFF00C8FF),
      Color(0xFF64FFDA),
    ];
  }

  static List<Color> _melancholyPalette() {
    return const [
      Color(0xFF202938),
      Color(0xFF39465A),
      Color(0xFF59677A),
      Color(0xFF777B91),
      Color(0xFFB0AFC0),
    ];
  }

  static List<Color> _randomPalette() {
    return List.generate(
      5,
      (_) => Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      ),
    );
  }
}