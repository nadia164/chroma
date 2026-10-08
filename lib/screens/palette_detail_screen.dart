import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/saved_palette.dart';
import '../utils/color_utils.dart';
import '../models/palette_color.dart';

class PaletteDetailScreen extends StatelessWidget {
  final SavedPalette palette;

  const PaletteDetailScreen({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          palette.prompt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              return _buildMobileLayout(context);
            }

            return _buildDesktopLayout(context);
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: palette.colors.map((paletteColor) {
              return Expanded(child: _buildColorSection(context, paletteColor));
            }).toList(),
          ),
        ),
        _buildPaletteInfo(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: palette.colors.map((paletteColor) {
              return Expanded(child: _buildColorSection(context, paletteColor));
            }).toList(),
          ),
        ),
        _buildPaletteInfo(context),
      ],
    );
  }

  Widget _buildColorSection(BuildContext context, PaletteColor paletteColor) {
    final color = paletteColor.color;
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    final hex = ColorUtils.colorToHex(color);

    return Material(
      color: color,
      child: InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: hex));

          HapticFeedback.lightImpact();

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('$hex copied'),
                duration: const Duration(milliseconds: 1200),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hex,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paletteColor.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaletteInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      color: Theme.of(context).colorScheme.surface,
      child: Text(
        'Tap a color to copy its HEX code',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
