import 'package:flutter/material.dart';

import 'palette_color.dart';

class SavedPalette {
  final String id;
  final String prompt;
  final List<PaletteColor> colors;
  final DateTime createdAt;

  const SavedPalette({
    required this.id,
    required this.prompt,
    required this.colors,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'colors': colors.map((paletteColor) {
        return {
          'color': paletteColor.color.toARGB32(),
          'name': paletteColor.name,
        };
      }).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedPalette.fromJson(Map<String, dynamic> json) {
    final colors = (json['colors'] as List<dynamic>).map((item) {
      final colorData = item as Map<String, dynamic>;

      return PaletteColor(
        color: Color(colorData['color'] as int),
        name: colorData['name'] as String,
      );
    }).toList();

    return SavedPalette(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      colors: colors,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
