import 'package:flutter/material.dart';
class BorderPainter extends CustomPainter {
  final double scoreBarHeight;

  BorderPainter(this.scoreBarHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth =0.1;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height - scoreBarHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
