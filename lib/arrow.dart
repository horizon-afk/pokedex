import 'dart:ui';
import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';


class ArrowPainter extends CustomPainter {

  double length;
  ArrowPainter(this.length);
  @override
  void paint(Canvas canvas, Size size) {
    Path path;

    // The arrows usually looks better with rounded caps.
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    /// Draw a single arrow.
    path = Path();
    path.moveTo(0, 0);
    path.relativeCubicTo(0, 0, 0, 0, length, 0);
    path = ArrowPath.make(path: path, tipLength: 10);
    canvas.drawPath(path, paint..color);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => false;
}
