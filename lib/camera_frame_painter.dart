import 'package:flutter/material.dart';

class CameraFramePainter extends CustomPainter {
  final String screenType;
  final Size frameSize;
  final double dx;
  final double dy;
  CameraFramePainter({this.screenType, this.frameSize, this.dx, this.dy});

  @override
  void paint(Canvas canvas, Size size) {
    if (screenType == 'rectangle') {
      _drawFrameRectangle(size, canvas);
    } else {
      _drawFrameLandscape(size, canvas);
    }
  }

  Canvas _drawFrameRectangle(Size size, Canvas canvas) {
    Path path = Path()
      ..addRect(
        Rect.fromLTWH(dx, dy, frameSize.width, frameSize.height),
      );
    final paint = Paint()..color = Colors.red;
    canvas.drawPath(path, paint);
    canvas.clipPath(path);

    return canvas;
  }

  Canvas _drawFrameLandscape(Size size, Canvas canvas) {
    Path path = Path()
      ..addRect(
        Rect.fromLTWH(dx, dy, frameSize.width, frameSize.height),
      );
    final paint = Paint()..color = Colors.white;
    canvas.drawPath(path, paint);
    canvas.clipPath(path);

    return canvas;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
