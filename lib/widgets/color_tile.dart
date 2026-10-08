import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  Future<void> _copyHex(String hex) async {
    await Clipboard.setData(ClipboardData(text: hex));

    HapticFeedback.lightImpact();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$hex copied'),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        width: 180,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleLock() {
    HapticFeedback.lightImpact();
    widget.onLockChanged();
  }

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
          decoration: BoxDecoration(color: color),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _copyHex(hex);
                      },
                      child: Text(
                        hex,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
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
                child: IconButton(
                  onPressed: _toggleLock,
                  tooltip: widget.paletteColor.isLocked
                      ? 'Unlock color'
                      : 'Lock color',
                  icon: Icon(
                    widget.paletteColor.isLocked
                        ? Icons.lock_rounded
                        : Icons.lock_open_rounded,
                    color: textColor,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
