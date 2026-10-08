import 'dart:convert';
import 'dart:math';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/palette_color.dart';

class PaletteService {
  static const String _baseUrl = 'https://colorfor.ai/api/public/v1/palette';

  final Random _random = Random();

  String? _lastVariant;

  Future<List<PaletteColor>> generatePalette({
    required String prompt,
    required List<PaletteColor> currentPalette,
  }) async {
    final lockedColors = currentPalette
        .where((paletteColor) => paletteColor.isLocked)
        .map((paletteColor) => _colorToHex(paletteColor.color))
        .take(3)
        .toList();

    final queryParameters = <String, String>{
      'query': prompt.trim(),
      'count': currentPalette.length.toString(),
    };

    if (lockedColors.isNotEmpty) {
      queryParameters['anchors'] = lockedColors.join(',');
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

    debugPrint('Palette request: $uri');

    final response = await http.get(uri);

    debugPrint('Palette response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Palette generation failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final palettes = data['palettes'] as List<dynamic>?;

    if (palettes == null || palettes.isEmpty) {
      throw Exception('No palettes were returned.');
    }

    final availablePalettes = palettes
        .whereType<Map<String, dynamic>>()
        .toList();

    if (availablePalettes.isEmpty) {
      throw Exception('No valid palettes were returned.');
    }

    var selectablePalettes = availablePalettes;

    if (_lastVariant != null && availablePalettes.length > 1) {
      final filtered = availablePalettes
          .where((palette) => palette['variant'] != _lastVariant)
          .toList();

      if (filtered.isNotEmpty) {
        selectablePalettes = filtered;
      }
    }

    final selectedPalette =
        selectablePalettes[_random.nextInt(selectablePalettes.length)];

    _lastVariant = selectedPalette['variant'] as String?;

    final colors = selectedPalette['colors'] as List<dynamic>?;

    if (colors == null || colors.isEmpty) {
      throw Exception('The selected palette has no colors.');
    }

    final apiColors = colors.whereType<String>().map(_hexToColor).toList();

    if (apiColors.length < currentPalette.length) {
      throw Exception('The API returned too few colors.');
    }

    /*
     * ColorFor.ai puts anchor colors into the returned palette.
     *
     * Remove those anchor colors before assigning generated
     * colors to unlocked positions.
     */
    final generatedColors = <Color>[];

    for (var index = 0; index < apiColors.length; index++) {
      final color = apiColors[index];

      final isAnchor = _isAnchorColor(color, lockedColors);

      if (!isAnchor) {
        generatedColors.add(color);
      }
    }

    final unlockedCount = currentPalette
        .where((paletteColor) => !paletteColor.isLocked)
        .length;

    if (generatedColors.length < unlockedCount) {
      throw Exception('The API did not return enough unlocked colors.');
    }

    var generatedIndex = 0;

    final result = List.generate(currentPalette.length, (index) {
      final currentColor = currentPalette[index];

      if (currentColor.isLocked) {
        return currentColor;
      }

      final color = generatedColors[generatedIndex];
      generatedIndex++;

      return PaletteColor(color: color, name: _generateColorName(color));
    });

    debugPrint('Selected variant: $_lastVariant');

    debugPrint(
      'Generated colors: '
      '${result.map((paletteColor) => _colorToHex(paletteColor.color)).join(', ')}',
    );

    return result;
  }

  bool _isAnchorColor(Color color, List<String> lockedColors) {
    final hex = _colorToHex(color);

    return lockedColors.contains(hex);
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32();

    final red = ((argb >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');

    final green = ((argb >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');

    final blue = (argb & 0xFF).toRadixString(16).padLeft(2, '0');

    return '$red$green$blue'.toUpperCase();
  }

  Color _hexToColor(String hex) {
    final normalizedHex = hex.replaceFirst('#', '');

    return Color(int.parse('FF$normalizedHex', radix: 16));
  }

  String _generateColorName(Color color) {
    return ColorTools.nameThatColor(color);
  }
}
