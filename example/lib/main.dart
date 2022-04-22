import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:processing_camera_image/processing_camera_image.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final CameraController _cameraController;
  late Future<void> _instanceInit;
  final pipe = BehaviorSubject<CameraImage?>.seeded(null);
  int count = 0;
  final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();
  imglib.Image? currentImage;

  @override
  void initState() {
    pipe.listen((value) async {
      if (value != null) {
        final stopwatch = Stopwatch();
        stopwatch.start();
        currentImage = await Future.microtask(() => processImage(value));
        stopwatch.stop();
        print('this is time process: ${stopwatch.elapsedMilliseconds}');
        stopwatch.reset();
        print(currentImage?.length);
      }
    });
    _instanceInit = initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    await _cameraController.initialize();
    await _cameraController.startImageStream((image) {
      pipe.sink.add(image);
    });
  }

  imglib.Image? processImage(CameraImage _savedImage) {
    return _processingCameraImage.processCameraImageToRGB(
      height: _savedImage.height,
      width: _savedImage.width,
      plane0: _savedImage.planes[0].bytes,
      plane1: _savedImage.planes[1].bytes,
      plane2: _savedImage.planes[2].bytes,
      bytesPerRowPlane0: _savedImage.planes[0].bytesPerRow,
      bytesPerPixelPlan1: _savedImage.planes[1].bytesPerPixel,
      bytesPerRowPlane1: _savedImage.planes[1].bytesPerRow,
      rotationAngle: 180,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: InkWell(
        child: Container(
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                        body: Center(
                          child: Image.memory(Uint8List.fromList(
                              imglib.encodeJpg(currentImage!))),
                        ),
                      )));
        },
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _instanceInit,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: 1 /
                    (_cameraController.value.previewSize?.aspectRatio ?? 4 / 3),
                child: CameraPreview(_cameraController),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
