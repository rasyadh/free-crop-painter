import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:free_crop/camera_screen.dart';

class PickFrameScreen extends StatefulWidget {
  @override
  _PickFrameScreenState createState() => _PickFrameScreenState();
}

class _PickFrameScreenState extends State<PickFrameScreen> {
  File _image;
  List<CameraDescription> cameras;

  _getCameraList() async {
    cameras = await availableCameras();
  }

  @override
  void initState() {
    super.initState();
    _getCameraList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Frame')),
      body: Column(
        children: <Widget>[
          Container(
            height: 80.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: ButtonTheme(
                    height: 80.0,
                    child: FlatButton(
                      onPressed: () => getImage('rectangle'),
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/frame02.png',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ButtonTheme(
                    height: 80.0,
                    child: FlatButton(
                      onPressed: () => getImage('landscape'),
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/frame01.png',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: _image != null
                  ? Image(
                      image: FileImage(_image),
                      fit: BoxFit.fitWidth,
                    )
                  : Center(
                      child: Text('No Image'),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Future getImage(String frameType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          cameras: cameras,
          screenType: frameType,
          getPath: (v) {
            setState(() {
              _image = File(v);
            });
          },
        ),
      ),
    );
  }
}
