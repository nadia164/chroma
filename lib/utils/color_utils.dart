import 'package:flutter/material.dart';

class ColorUtils {
  static Color textColorFor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  static String colorToHex(Color color) {
    final argb = color.toARGB32();

    final red = ((argb >> 16) & 0xFF)
        .toRadixString(16)
        .padLeft(2, '0');

    final green = ((argb >> 8) & 0xFF)
        .toRadixString(16)
        .padLeft(2, '0');

    final blue = (argb & 0xFF)
        .toRadixString(16)
        .padLeft(2, '0');

    return '#${red.toUpperCase()}'
        '${green.toUpperCase()}'
        '${blue.toUpperCase()}';
  }
}