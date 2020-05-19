import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:free_crop/guideline_painter.dart';
import 'package:free_crop/result_screen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController controller;
  List<CameraDescription> cameras;
  File file;
  File result;
  ui.Image image;

  @override
  void initState() {
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller != null
          ? !controller.value.isInitialized
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: CustomPaint(
                          foregroundPainter: GuidelinePainter(),
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: ButtonTheme(
                              height: 48.0,
                              child: FlatButton(
                                onPressed: _takePicture,
                                child: Text('Take Picture'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ButtonTheme(
                              height: 48.0,
                              child: FlatButton(
                                onPressed: result != null
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResultScreen(
                                                imagePath: result.path),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text('Open Result'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
          : Container(),
    );
  }

  _initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _takePicture() async {
    try {
      var dir = (await getTemporaryDirectory()).path;
      var filePath = '$dir/${DateTime.now()}.jpg';

      await controller.takePicture(filePath);
      file = File(filePath);
      print('filePath: $filePath');
      print('file: $file');
      print(file);

      readFile(file);
    } catch (e) {
      print(e);
    }
  }

  Future<Null> readFile(File file) async {
    Uint8List bytes = file.readAsBytesSync();
    image = await loadImage(bytes);

    print('image: $image');
    Size size = Size(image.width.toDouble(), image.height.toDouble());
    _saveCanvas(size);
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Canvas _drawGuideline(Size size, Canvas canvas) {
    var center = Offset(size.width / 2, size.height / 2);
    Path path = Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: size.width * 0.3,
        ),
      );
    final paint = Paint()..color = Colors.red;
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

    _drawGuideline(size, canvas);

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(image.width, image.height);
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData.buffer.asUint8List();

    var documentDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      result = File(join(documentDirectory.path, '${DateTime.now()}.png'));
      result.writeAsBytesSync(buffer);
    });

    print('result: $result');
    print('result: ${result.path}');
  }
}
