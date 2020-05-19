import 'package:flutter/material.dart';

class GuidelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawGuideline(size, canvas);
  }

  Canvas _drawGuideline(Size size, Canvas canvas) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..color = Colors.blue
      ..style = PaintingStyle.stroke;
    var center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.3, paint);

    return canvas;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
