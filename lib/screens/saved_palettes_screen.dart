import 'package:flutter/material.dart';

import '../models/saved_palette.dart';
import '../services/palette_storage_service.dart';
import '../utils/color_utils.dart';
import 'palette_detail_screen.dart';

class SavedPalettesScreen extends StatefulWidget {
  const SavedPalettesScreen({super.key});

  @override
  State<SavedPalettesScreen> createState() => _SavedPalettesScreenState();
}

class _SavedPalettesScreenState extends State<SavedPalettesScreen> {
  final PaletteStorageService _storageService = PaletteStorageService();

  List<SavedPalette> _palettes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPalettes();
  }

  Future<void> _loadPalettes() async {
    final palettes = await _storageService.loadPalettes();

    if (!mounted) {
      return;
    }

    setState(() {
      _palettes = palettes;
      _isLoading = false;
    });
  }

  Future<void> _deletePalette(SavedPalette palette) async {
    await _storageService.deletePalette(palette.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _palettes.removeWhere((item) => item.id == palette.id);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Palette deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Palettes')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_palettes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border_rounded, size: 56),
              SizedBox(height: 16),
              Text(
                'No saved palettes yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Generate a palette and save it to see it here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _palettes.length,
      itemBuilder: (context, index) {
        final palette = _palettes[index];

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
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
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
                  tooltip: 'Delete palette',
                  icon: const Icon(Icons.delete_outline_rounded),
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
