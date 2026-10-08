import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_palette.dart';

class PaletteStorageService {
  static const String _storageKey = 'saved_palettes';

  Future<List<SavedPalette>> loadPalettes() async {
    final preferences = await SharedPreferences.getInstance();

    final storedPalettes = preferences.getStringList(_storageKey);

    if (storedPalettes == null) {
      return [];
    }

    final palettes = <SavedPalette>[];

    for (final storedPalette in storedPalettes) {
      try {
        final json = jsonDecode(storedPalette) as Map<String, dynamic>;

        palettes.add(SavedPalette.fromJson(json));
      } catch (_) {
        // Ignore invalid saved palettes.
      }
    }

    palettes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return palettes;
  }

  Future<void> savePalette(SavedPalette palette) async {
    final preferences = await SharedPreferences.getInstance();

    final palettes = await loadPalettes();

    palettes.removeWhere((savedPalette) => savedPalette.id == palette.id);

    palettes.insert(0, palette);

    final encodedPalettes = palettes
        .map((savedPalette) => jsonEncode(savedPalette.toJson()))
        .toList();

    await preferences.setStringList(_storageKey, encodedPalettes);
  }

  Future<void> deletePalette(String id) async {
    final preferences = await SharedPreferences.getInstance();

    final palettes = await loadPalettes();

    palettes.removeWhere((palette) => palette.id == id);

    final encodedPalettes = palettes
        .map((palette) => jsonEncode(palette.toJson()))
        .toList();

    await preferences.setStringList(_storageKey, encodedPalettes);
  }
}
