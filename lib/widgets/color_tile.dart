import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

class ColorTile extends StatefulWidget {
  final Color color;
  final String name;
  final bool isLocked;
  final VoidCallback onLockChanged;

  const ColorTile({
    super.key,
    required this.color,
    required this.name,
    required this.isLocked,
    required this.onLockChanged,
  });

  @override
  State<ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textColor = ColorUtils.textColorFor(widget.color);
    final hex = ColorUtils.colorToHex(widget.color);

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
            color: widget.color,
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
                      widget.name.toUpperCase(),
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
                  widget.isLocked
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