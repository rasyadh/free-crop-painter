import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathLib;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final String screenType;
  final List<CameraDescription> cameras;
  final Function getPath;
  CameraScreen({this.cameras, this.screenType, this.getPath});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  GlobalKey frameKey = GlobalKey();
  CameraController controller;
  Future<void> _initializeControllerFuture;
  ui.Image image;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.high,
        enableAudio: false);
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final topMargin = size.height * 0.25;
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!controller.value.isInitialized) {
              return Material(
                child: Container(
                  child: Center(
                    child: Text(
                      'Tolong izinkan akses kamera',
                    ),
                  ),
                ),
              );
            }

            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Transform.scale(
                    scale: controller.value.aspectRatio / deviceRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller),
                      ),
                    ),
                  ),
                ),
                frameScreen(top: topMargin)
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  frameScreen({double top}) {
    var frameType = '';
    if (widget.screenType == 'rectangle') {
      frameType = 'assets/images/frame02.png';
    } else {
      frameType = 'assets/images/frame01.png';
    }
    return Positioned.fill(
      child: Container(
        margin: EdgeInsets.fromLTRB(32.0, top, 32.0, 16.0),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Mohon foto bagian mobil',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.0),
                    Image.asset(
                      frameType,
                      key: frameKey,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3.0),
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(1000.0),
                    onTap: _takePicture,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.camera_alt,
                        size: 32.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _takePicture() async {
    try {
      await _initializeControllerFuture;
      final path = pathLib.join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.jpg',
      );

      await controller.takePicture(path);
      File file = File(path);

      final result = await readFile(file);
      await widget.getPath(result);
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  Future<String> readFile(File file) async {
    Uint8List bytes = file.readAsBytesSync();
    image = await loadImage(bytes);

    Size size = Size(image.width.toDouble(), image.height.toDouble());
    return _saveCanvas(size);
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Canvas _drawFrame(
      Canvas canvas, Size size, Size frameSize, double x, double y) {
    Path path = Path()
      ..addRect(
        Rect.fromLTWH(x, y, frameSize.width, frameSize.height),
      );
    final paint = Paint()..color = Colors.red;
    canvas.drawPath(path, paint);
    canvas.clipPath(path);

    double drawImageWidth = 0;
    double drawImageHeight = 0;
    canvas.drawImage(image, Offset(drawImageWidth, drawImageHeight), Paint());
    return canvas;
  }

  Future<String> _saveCanvas(Size size) async {
    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;

    RenderBox box = frameKey.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);

    Size screenSize = MediaQuery.of(context).size;
    double widthScale = size.width / screenSize.width;
    double heightScale = size.height / screenSize.height;
    Size frameSize =
        Size(box.size.width * widthScale, box.size.height * heightScale);
    double x = position.dx * widthScale;
    double y = position.dy * heightScale;
    _drawFrame(canvas, size, frameSize, x, y);

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(image.width, image.height);
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();

    var documentDirectory = await getApplicationDocumentsDirectory();
    File result =
        File(pathLib.join(documentDirectory.path, '${DateTime.now()}.png'));
    result.writeAsBytesSync(buffer);

    return result.path;
  }
}
