import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(IrisRecognitionApp(firstCamera));
}

class IrisRecognitionApp extends StatelessWidget {
  final CameraDescription camera;

  IrisRecognitionApp(this.camera);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iris Recognition',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(camera),
    );
  }
}

class HomePage extends StatelessWidget {
  final CameraDescription camera;

  HomePage(this.camera);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iris Recognition'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the camera capture screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraCapturePage(camera),
              ),
            );
          },
          child: Text('Capture Eye Image'),
        ),
      ),
    );
  }
}

class CameraCapturePage extends StatefulWidget {
  final CameraDescription camera;

  CameraCapturePage(this.camera);

  @override
  _CameraCapturePageState createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Eye Image'),
      ),
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                setState(() {
                  _imageFile = image;
                });
              } catch (e) {
                print('Error capturing image: $e');
              }
            },
            child: Text('Capture Image'),
          ),
          if (_imageFile != null)
            Image.file(
              File(_imageFile!.path),
              height: 200,
            ),
        ],
      ),
    );
  }
}
