import 'dart:async' show Future;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:processing_camera_image/processing_camera_image.dart';
import 'package:rxdart/rxdart.dart';

final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();

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
  imglib.Image? currentImage;
  final stopwatch = Stopwatch();
  bool checked = false;

  void _processinngImage(CameraImage? value) async {
    if (value != null && !checked) {
      checked = true;
      stopwatch.start();
      currentImage = await compute(processImage, value);
      stopwatch.stop();
      print(stopwatch.elapsedMilliseconds); // Likely > 0.
      stopwatch.reset();
      checked = false;
    }
  }

  @override
  void initState() {
    pipe.listen(_processinngImage);
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
    _cameraController = CameraController(cameras[0], ResolutionPreset.veryHigh,
        imageFormatGroup: ImageFormatGroup.yuv420);
    await _cameraController.initialize();
    await _cameraController.startImageStream((image) {
      pipe.sink.add(image);
    });
  }

  static imglib.Image? processImage(CameraImage savedImage) {
    return _processingCameraImage.processCameraImageToRGB(
      // height: savedImage.height,
      // plane0: savedImage.planes[0].bytes,
      // width: savedImage.width,
      bytesPerPixelPlan1: savedImage.planes[1].bytesPerPixel,
      bytesPerRowPlane0: savedImage.planes[0].bytesPerRow,
      bytesPerRowPlane1: savedImage.planes[1].bytesPerRow,
      height: savedImage.height,
      plane0: savedImage.planes[0].bytes,
      plane1: savedImage.planes[1].bytes,
      plane2: savedImage.planes[2].bytes,
      // rotationAngle: 15,
      width: savedImage.width,
      // isFlipHoriozntal: true,
      // isFlipVectical: true,
    );

    // return _processingCameraImage.processCameraImageToGrayIOS(
    //   height: savedImage.height,
    //   width: savedImage.width,
    //   plane0: savedImage.planes[0].bytes,
    //   rotationAngle: 15,
    //   backGroundColor: Colors.red.value,
    //   isFlipVectical: true,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: InkWell(
        child: Container(
          color: Colors.white.withOpacity(0.0),
          height: 36,
          width: 36,
          child: const Icon(Icons.photo_camera),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                        body: Center(
                          child: currentImage != null
                              ? Image.memory(Uint8List.fromList(
                                  imglib.encodeJpg(currentImage!)))
                              : Container(),
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
