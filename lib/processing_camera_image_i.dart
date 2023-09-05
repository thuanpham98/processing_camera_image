import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:image/image.dart' as imglib;

import 'const.dart';
import 'processing_camera_image.dart';

class IProcessingCameraImage implements ProcessingCameraImage {
  static IProcessingCameraImage? _instance;
  late final ConvertImageYuv420pToRGBFlutter _convertImageYuv420pToRGB;
  late final ConvertImageYuv420pToGrayFlutter _convertImageYuv420pToGray;
  late final ConvertImageYuv420pToGray8BitFlutter
      _convertImageYuv420pToGray8Bit;
  late final ConvertImageNV12ToRGBFlutter _convertImageNV12ToRGB;

  factory IProcessingCameraImage() {
    _instance ??= IProcessingCameraImage._();
    return _instance!;
  }

  IProcessingCameraImage._() {
    final DynamicLibrary convertImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libconvertImage.so")
        : DynamicLibrary.process();
    _convertImageYuv420pToRGB = convertImageLib
        .lookup<NativeFunction<ConvertImageYuv420pToRGBC>>(
            'convert_image_yuv420p_to_rgb')
        .asFunction<ConvertImageYuv420pToRGBFlutter>();

    _convertImageYuv420pToGray = convertImageLib
        .lookup<NativeFunction<ConvertImageYuv420pToGrayC>>(
            'convert_image_yuv420p_to_gray')
        .asFunction<ConvertImageYuv420pToGrayFlutter>();

    _convertImageYuv420pToGray8Bit = convertImageLib
        .lookup<NativeFunction<ConvertImageYuv420pToGray8BitC>>(
            'convert_image_yuv420p_to_gray_8bit')
        .asFunction<ConvertImageYuv420pToGray8BitFlutter>();
    _convertImageNV12ToRGB = convertImageLib
        .lookup<NativeFunction<ConvertImageNV12ToRGBC>>(
            'convert_image_nv12_to_rgb')
        .asFunction<ConvertImageNV12ToRGBFlutter>();
  }

  /// [ProcessCameraImageToRGB].
  @override
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
  }) {
    if (width == null ||
        height == null ||
        plane0 == null ||
        plane1 == null ||
        plane2 == null ||
        plane0.isEmpty ||
        plane1.isEmpty ||
        plane2.isEmpty ||
        bytesPerRowPlane0 == null ||
        bytesPerRowPlane1 == null ||
        bytesPerPixelPlan1 == null) {
      return null;
    }
    rotationAngle ??= 0;
    double rad =
        (rotationAngle * 3.14159265358979323846264338327950288 / 180.0);
    double sinVal = sin(rad).abs();
    double cosVal = cos(rad).abs();
    int newImgWidth = (sinVal * height + cosVal * bytesPerRowPlane0).toInt();
    int newImgHeight = (sinVal * bytesPerRowPlane0 + cosVal * height).toInt();

    Pointer<Uint8> p = ffi.malloc.allocate(plane0.length);
    Pointer<Uint8> p1 = ffi.malloc.allocate(plane1.length);
    Pointer<Uint8> p2 = ffi.malloc.allocate(plane2.length);

    Uint8List pointerList = p.asTypedList(plane0.length);
    Uint8List pointerList1 = p1.asTypedList(plane1.length);
    Uint8List pointerList2 = p2.asTypedList(plane2.length);
    pointerList.setRange(0, plane0.length, plane0);
    pointerList1.setRange(0, plane1.length, plane1);
    pointerList2.setRange(0, plane2.length, plane2);

    Pointer<Uint32> imgP = _convertImageYuv420pToRGB(
      p,
      p1,
      p2,
      bytesPerRowPlane1,
      bytesPerPixelPlan1,
      bytesPerRowPlane0,
      height,
      rotationAngle,
      backGroundColor,
      isFlipVectical,
      isFlipHoriozntal,
    );

    List<int> imgData = imgP.asTypedList(((newImgWidth) * (newImgHeight)));
    imglib.Image img = imglib.Image.fromBytes(
        bytes: Uint32List.fromList(imgData).buffer,
        width: newImgWidth,
        height: newImgHeight,
        order: imglib.ChannelOrder.rgba);

    ffi.malloc.free(p);
    ffi.malloc.free(p1);
    ffi.malloc.free(p2);
    ffi.malloc.free(imgP);

    return img;
  }

  /// [processCameraImageToGray].
  @override
  imglib.Image? processCameraImageToGray({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
    int backGroundColor = 0xFFFFFFFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  }) {
    if (width == null || height == null || plane0?.isEmpty == null) {
      return null;
    }
    rotationAngle ??= 0;

    double rad =
        (rotationAngle * 3.14159265358979323846264338327950288 / 180.0);
    double sinVal = sin(rad).abs();
    double cosVal = cos(rad).abs();
    int newImgWidth = (sinVal * height + cosVal * width).toInt();
    int newImgHeight = (sinVal * width + cosVal * height).toInt();

    Pointer<Uint8> p = ffi.malloc.allocate(plane0?.length ?? 0);
    Uint8List pointerList = p.asTypedList(plane0?.length ?? 0);
    pointerList.setRange(0, plane0?.length ?? 0, plane0 ?? Uint8List(0));

    Pointer<Uint32> imgP = _convertImageYuv420pToGray(
      p,
      width,
      height,
      rotationAngle,
      backGroundColor,
      isFlipVectical,
      isFlipHoriozntal,
    );

    List<int> imgData = imgP.asTypedList(newImgWidth * newImgHeight);
    imglib.Image img = imglib.Image.fromBytes(
        bytes: Uint32List.fromList(imgData).buffer,
        width: newImgWidth,
        height: newImgHeight,
        order: imglib.ChannelOrder.rgba);

    ffi.malloc.free(p);
    ffi.malloc.free(imgP);

    return img;
  }

  /// [processCameraImageToGray8Bit].
  @override
  Image8bit? processCameraImageToGray8Bit({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
    int backGroundColor = 0xFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  }) {
    if (width == null || height == null || plane0 == null || plane0.isEmpty) {
      return null;
    }

    rotationAngle ??= 0;

    double rad =
        (rotationAngle * 3.14159265358979323846264338327950288 / 180.0);
    double sinVal = sin(rad).abs();
    double cosVal = cos(rad).abs();
    int newImgWidth = (sinVal * height + cosVal * width).toInt();
    int newImgHeight = (sinVal * width + cosVal * height).toInt();

    Pointer<Uint8> p = ffi.malloc.allocate(plane0.length);
    Uint8List pointerList = p.asTypedList(plane0.length);
    pointerList.setRange(0, plane0.length, plane0);

    Pointer<Uint8> imgP = _convertImageYuv420pToGray8Bit(
      p,
      width,
      height,
      rotationAngle,
      backGroundColor,
      isFlipVectical,
      isFlipHoriozntal,
    );

    Uint8List imgData = imgP.asTypedList(newImgHeight * newImgWidth);
    imglib.Image img = imglib.Image.fromBytes(
        bytes: imgData.buffer,
        width: newImgWidth,
        height: newImgHeight,
        numChannels: 1,
        order: imglib.ChannelOrder.red);

    ffi.malloc.free(p);
    ffi.malloc.free(imgP);

    return Image8bit(
      data: img.getBytes(),
      heigh: newImgHeight,
      width: newImgWidth,
    );
  }

  /// [processCameraImageToRGBIOS]. for IOS with YUV420.
  @override
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
  }) {
    if (width == null ||
        height == null ||
        plane0 == null ||
        plane1 == null ||
        plane0.isEmpty ||
        plane1.isEmpty ||
        bytesPerRowPlane0 == null ||
        bytesPerRowPlane1 == null ||
        bytesPerPixelPlan1 == null) {
      return null;
    }
    rotationAngle ??= 0;
    double rad =
        (rotationAngle * 3.14159265358979323846264338327950288 / 180.0);
    double sinVal = sin(rad).abs();
    double cosVal = cos(rad).abs();
    int newImgWidth = (sinVal * height + cosVal * bytesPerRowPlane0).toInt();
    int newImgHeight = (sinVal * bytesPerRowPlane0 + cosVal * height).toInt();

    Pointer<Uint8> p = ffi.malloc.allocate(plane0.length);
    Pointer<Uint8> p1 = ffi.malloc.allocate(plane1.length);

    Uint8List pointerList = p.asTypedList(plane0.length);
    Uint8List pointerList1 = p1.asTypedList(plane1.length);
    pointerList.setRange(0, plane0.length, plane0);
    pointerList1.setRange(0, plane1.length, plane1);

    Pointer<Uint32> imgP = _convertImageNV12ToRGB(
      p,
      p1,
      bytesPerRowPlane1,
      bytesPerPixelPlan1,
      bytesPerRowPlane0,
      height,
      rotationAngle,
      backGroundColor,
      isFlipVectical,
      isFlipHoriozntal,
    );

    final imgData = imgP.asTypedList(((newImgWidth) * (newImgHeight)));
    imglib.Image img = imglib.Image.fromBytes(
        bytes: imgData.buffer,
        width: newImgWidth,
        height: newImgHeight,
        order: imglib.ChannelOrder.rgba);

    ffi.malloc.free(p);
    ffi.malloc.free(p1);
    ffi.malloc.free(imgP);

    return img;
  }

  /// [processCameraImageToGrayIOS]. for IOS with YUV420.
  @override
  imglib.Image? processCameraImageToGrayIOS({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
    int backGroundColor = 0xFFFFFFFF,
    bool isFlipHoriozntal = false,
    bool isFlipVectical = false,
  }) {
    return processCameraImageToGray(
      height: height,
      width: width,
      plane0: plane0,
      rotationAngle: rotationAngle,
      backGroundColor: backGroundColor,
      isFlipHoriozntal: isFlipHoriozntal,
      isFlipVectical: isFlipVectical,
    );
  }
}
