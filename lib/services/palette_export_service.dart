import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/saved_palette.dart';

class PaletteExportService {
  Future<Uint8List> createPaletteImage(
    SavedPalette palette, {
    int width = 1200,
    int height = 800,
  }) async {
    final recorder = ui.PictureRecorder();

    final canvas = Canvas(recorder);

    final size = Size(width.toDouble(), height.toDouble());

    final backgroundPaint = Paint()..color = Colors.white;

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final colorHeight = height * 0.65;
    final colorWidth = width / palette.colors.length;

    for (var index = 0; index < palette.colors.length; index++) {
      final color = palette.colors[index];

      final paint = Paint()..color = color.color;

      canvas.drawRect(
        Rect.fromLTWH(index * colorWidth, 0, colorWidth, colorHeight),
        paint,
      );
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final promptStyle = TextStyle(
      color: Colors.black,
      fontSize: 42,
      fontWeight: FontWeight.w900,
    );

    textPainter.text = TextSpan(text: palette.prompt, style: promptStyle);

    textPainter.layout(maxWidth: width - 80);

    textPainter.paint(canvas, Offset(40, colorHeight + 45));

    final hexStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );

    for (var index = 0; index < palette.colors.length; index++) {
      final color = palette.colors[index];

      final hex = _colorToHex(color.color);

      textPainter.text = TextSpan(text: hex, style: hexStyle);

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(index * colorWidth + 20, colorHeight + 120),
      );
    }

    final picture = recorder.endRecording();

    final image = await picture.toImage(width, height);

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Unable to create palette image.');
    }

    return byteData.buffer.asUint8List();
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32();

    final red = ((argb >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');

    final green = ((argb >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');

    final blue = (argb & 0xFF).toRadixString(16).padLeft(2, '0');

    return '#${red.toUpperCase()}'
        '${green.toUpperCase()}'
        '${blue.toUpperCase()}';
  }
}
