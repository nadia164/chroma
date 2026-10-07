import 'package:flutter/material.dart';

import '../models/palette_color.dart';
import '../utils/color_utils.dart';

class ColorTile extends StatefulWidget {
  final PaletteColor paletteColor;
  final VoidCallback onLockChanged;

  const ColorTile({
    super.key,
    required this.paletteColor,
    required this.onLockChanged,
  });

  @override
  State<ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.paletteColor.color;
    final textColor = ColorUtils.textColorFor(color);
    final hex = ColorUtils.colorToHex(color);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });

        widget.onLockChanged();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: color,
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hex,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.paletteColor.name.toUpperCase(),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  widget.paletteColor.isLocked
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  color: textColor,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}