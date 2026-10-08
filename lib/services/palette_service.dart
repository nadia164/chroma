import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/palette_color.dart';

class PaletteService {
  static const String _baseUrl = 'http://colormind.io/api/';

  Future<List<PaletteColor>> generatePalette({
    required List<PaletteColor> currentPalette,
  }) async {
    final input = currentPalette.map((paletteColor) {
      if (!paletteColor.isLocked) {
        return 'N';
      }

      final color = paletteColor.color;

      return [
        color.r.round(),
        color.g.round(),
        color.b.round(),
      ];
    }).toList();

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'default',
        'input': input,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Palette generation failed: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final colors = data['result'] as List<dynamic>;

    // Convert the API response into PaletteColor objects.
    final generatedPalette = List.generate(
      colors.length,
      (index) {
        final rgb = colors[index] as List<dynamic>;

        final color = Color.fromARGB(
          255,
          rgb[0] as int,
          rgb[1] as int,
          rgb[2] as int,
        );

        return PaletteColor(
          color: color,
          name: _generateColorName(color),
          isLocked: currentPalette[index].isLocked,
        );
      },
    );

    // Make sure locked colors remain exactly unchanged.
    return List.generate(
      generatedPalette.length,
      (index) {
        final currentColor = currentPalette[index];

        if (currentColor.isLocked) {
          return currentColor;
        }

        return generatedPalette[index];
      },
    );
  }

  String _generateColorName(Color color) {
    final hue = HSVColor.fromColor(color).hue;

    if (hue < 30) {
      return 'Red';
    }

    if (hue < 60) {
      return 'Orange';
    }

    if (hue < 90) {
      return 'Yellow';
    }

    if (hue < 150) {
      return 'Green';
    }

    if (hue < 210) {
      return 'Cyan';
    }

    if (hue < 270) {
      return 'Blue';
    }

    if (hue < 330) {
      return 'Purple';
    }

    return 'Red';
  }
}