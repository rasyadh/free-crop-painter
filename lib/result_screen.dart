import 'dart:io';

import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  ResultScreen({this.imagePath});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
