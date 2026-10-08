import 'package:flutter/material.dart';

class PaletteColor {
  final Color color;
  final String name;
  final bool isLocked;

  const PaletteColor({
    required this.color,
    required this.name,
    this.isLocked = false,
  });

  PaletteColor copyWith({Color? color, String? name, bool? isLocked}) {
    return PaletteColor(
      color: color ?? this.color,
      name: name ?? this.name,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
