import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:processing_camera_image/processing_camera_image_i.dart';

abstract class ProcessingCameraImage {
  factory ProcessingCameraImage() => IProcessingCameraImage();

  /// [processCameraImageToRGB]. for Android with YUV420.
  imglib.Image? processCameraImageToRGB({
    int? width,
    int? height,
    Uint8List? plane0,
    Uint8List? plane1,
    Uint8List? plane2,
    double? rotationAngle,
    int? bytesPerRowPlane0,
    int? bytesPerRowPlane1,
    int? bytesPerPixelPlan1,
    int backGroundColor = 0xFFFFFFFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  });

  /// [processCameraImageToGray]. for Android with YUV420.
  imglib.Image? processCameraImageToGray({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
    int backGroundColor = 0xFFFFFFFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  });

  /// [processCameraImageToRGBIOS]. for IOS with NV12.
  imglib.Image? processCameraImageToRGBIOS({
    int? width,
    int? height,
    Uint8List? plane0,
    Uint8List? plane1,
    double? rotationAngle,
    int? bytesPerRowPlane0,
    int? bytesPerRowPlane1,
    int? bytesPerPixelPlan1,
    int backGroundColor = 0xFFFFFFFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  });

  /// [processCameraImageToGrayIOS]. for IOS with NV12.
  imglib.Image? processCameraImageToGrayIOS({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
    int backGroundColor = 0xFFFFFFFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  });

  /// [processCameraImageToGray8Bit]. for Android with YUV420.
  Image8bit? processCameraImageToGray8Bit({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
    int backGroundColor = 0xFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  });
}

class Image8bit {
  final int width;
  final int heigh;
  final Uint8List data;
  Image8bit({required this.data, required this.heigh, required this.width});
}
