import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:free_crop/frame_painter.dart';

class CropScreen extends StatefulWidget {
  @override
  _CropScreenState createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  ui.Image image;
  bool isImageloaded = false;

  @override
  void initState() {
    super.initState();
    initImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop'),
      ),
      body: SafeArea(
        child: Container(
          width: 240,
          height: 240,
          child: isImageloaded
              ? Container(
                  child: CustomPaint(
                    painter: FramePainter(image: image),
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<Null> initImage() async {
    final ByteData data = await rootBundle.load('assets/images/danilla.jpg');
    image = await loadImage(Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }
}
