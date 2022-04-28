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
  });

  /// [processCameraImageToGray]. for Android with YUV420.
  imglib.Image? processCameraImageToGray({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
  });

  /// [processCameraImageToRGBIOS]. for IOS with YUV420.
  imglib.Image? processCameraImageToRGBIOS({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
  });

  /// [processCameraImageToGrayIOS]. for IOS with YUV420.
  imglib.Image? processCameraImageToGrayIOS({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
  });

  /// [processCameraImageToGray8Bit]. for Android with YUV420.
  Uint8List? processCameraImageToGray8Bit({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
  });
}
