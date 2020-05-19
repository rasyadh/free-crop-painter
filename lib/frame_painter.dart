import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FramePainter extends CustomPainter {
  FramePainter({this.image});
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCanvas(size, canvas);
    _saveCanvas(size);
  }

  Canvas _drawCanvas(Size size, Canvas canvas) {
    Path path = Path();
    Paint paint = Paint();

    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.55,
        size.width * 0.22, size.height * 0.70);
    path.quadraticBezierTo(size.width * 0.30, size.height * 0.90,
        size.width * 0.40, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.52, size.height * 0.50,
        size.width * 0.65, size.height * 0.70);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.85, size.width, size.height * 0.60);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = Colors.red;
    canvas.drawPath(path, paint);
    canvas.clipPath(path);

    double drawImageWidth = 0;
    double drawImageHeight = 0;
    canvas.drawImage(image, Offset(drawImageWidth, drawImageHeight), Paint());
    return canvas;
  }

  _saveCanvas(Size size) async {
    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;

    _drawCanvas(size, canvas);

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(image.width, image.height);
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();

    var documentDirectory = await getApplicationDocumentsDirectory();
    File file = File(join(documentDirectory.path, 'ayune-danilla.png'));
    file.writeAsBytesSync(buffer);

    print(file.path);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
