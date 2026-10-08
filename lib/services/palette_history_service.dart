import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_palette.dart';

class PaletteHistoryService {
  static const String _storageKey = 'palette_history';
  static const int _maxHistory = 20;

  Future<List<SavedPalette>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();

    final storedHistory = preferences.getStringList(_storageKey);

    if (storedHistory == null) {
      return [];
    }

    final history = <SavedPalette>[];

    for (final storedPalette in storedHistory) {
      try {
        final json = jsonDecode(storedPalette) as Map<String, dynamic>;

        history.add(SavedPalette.fromJson(json));
      } catch (_) {
        // Ignore invalid history entries.
      }
    }

    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return history;
  }

  Future<void> addToHistory(SavedPalette palette) async {
    final preferences = await SharedPreferences.getInstance();

    final history = await loadHistory();

    history.removeWhere((item) => item.id == palette.id);

    history.insert(0, palette);

    final limitedHistory = history
        .take(_maxHistory)
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await preferences.setStringList(_storageKey, limitedHistory);
  }

  Future<void> deleteFromHistory(String id) async {
    final preferences = await SharedPreferences.getInstance();

    final history = await loadHistory();

    history.removeWhere((item) => item.id == id);

    final encodedHistory = history
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await preferences.setStringList(_storageKey, encodedHistory);
  }

  Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}
