import 'package:flutter/material.dart';

import '../models/saved_palette.dart';
import '../services/palette_history_service.dart';
import '../utils/color_utils.dart';
import 'palette_detail_screen.dart';

class PaletteHistoryScreen extends StatefulWidget {
  const PaletteHistoryScreen({super.key});

  @override
  State<PaletteHistoryScreen> createState() => _PaletteHistoryScreenState();
}

class _PaletteHistoryScreenState extends State<PaletteHistoryScreen> {
  final PaletteHistoryService _historyService = PaletteHistoryService();

  List<SavedPalette> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.loadHistory();

    if (!mounted) {
      return;
    }

    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deletePalette(SavedPalette palette) async {
    await _historyService.deleteFromHistory(palette.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _history.removeWhere((item) => item.id == palette.id);
    });
  }

  Future<void> _clearHistory() async {
    await _historyService.clearHistory();

    if (!mounted) {
      return;
    }

    setState(() {
      _history.clear();
    });
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear history?'),
          content: const Text(
            'All generated palettes in your history '
            'will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('CLEAR'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await _clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              onPressed: _confirmClearHistory,
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 56),
              SizedBox(height: 16),
              Text(
                'No palette history yet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Generate a palette and it will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final palette = _history[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaletteDetailScreen(palette: palette),
              ),
            );
          },
          child: _buildPaletteCard(palette),
        );
      },
    );
  }

  Widget _buildPaletteCard(SavedPalette palette) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: Row(
              children: palette.colors.map((paletteColor) {
                return Expanded(child: Container(color: paletteColor.color));
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    palette.prompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _deletePalette(palette);
                  },
                  tooltip: 'Remove from history',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: palette.colors.map((paletteColor) {
                return Text(
                  ColorUtils.colorToHex(paletteColor.color),
                  style: Theme.of(context).textTheme.labelMedium,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
