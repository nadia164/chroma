import 'package:flutter/material.dart';

class ColorUtils {
  static Color textColorFor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  static String colorToHex(Color color) {
    final red = color.r.round().toRadixString(16).padLeft(2, '0');
    final green = color.g.round().toRadixString(16).padLeft(2, '0');
    final blue = color.b.round().toRadixString(16).padLeft(2, '0');

    return '#${red.toUpperCase()}${green.toUpperCase()}${blue.toUpperCase()}';
  }
}