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
  late final ConvertImageRGBFlutter _convertImageRGB;
  late final ConvertImageGrayFlutter _convertImageGrayFlutter;
  late final ConvertImageGray8BitFlutter _convertImageGray8BitFlutter;

  factory IProcessingCameraImage() {
    _instance ??= IProcessingCameraImage._();
    return _instance!;
  }

  IProcessingCameraImage._() {
    final DynamicLibrary convertImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libconvertImage.so")
        : DynamicLibrary.process();
    _convertImageRGB = convertImageLib
        .lookup<NativeFunction<ConvertImageRGBC>>('convert_image_rgb')
        .asFunction<ConvertImageRGBFlutter>();

    _convertImageGrayFlutter = convertImageLib
        .lookup<NativeFunction<ConvertImageGrayC>>('convert_image_gray_scale')
        .asFunction<ConvertImageGrayFlutter>();

    _convertImageGray8BitFlutter = convertImageLib
        .lookup<NativeFunction<ConvertImageGray8BitC>>(
            'convert_image_gray_scale_8bit')
        .asFunction<ConvertImageGray8BitFlutter>();
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
  }) {
    if (width == null ||
        height == null ||
        plane0?.isEmpty == null ||
        plane1?.isEmpty == null ||
        plane2?.isEmpty == null ||
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

    // Allocate memory for the 3 planes of the image
    Pointer<Uint8> p = ffi.malloc.allocate(plane0?.length ?? 0);
    Pointer<Uint8> p1 = ffi.malloc.allocate(plane1?.length ?? 0);
    Pointer<Uint8> p2 = ffi.malloc.allocate(plane2?.length ?? 0);

    // Assign the planes data to the pointers of the image
    Uint8List pointerList = p.asTypedList(plane0?.length ?? 0);
    Uint8List pointerList1 = p1.asTypedList(plane1?.length ?? 0);
    Uint8List pointerList2 = p2.asTypedList(plane2?.length ?? 0);
    pointerList.setRange(0, plane0?.length ?? 0, plane0 ?? Uint8List(0));
    pointerList1.setRange(0, plane1?.length ?? 0, plane1 ?? Uint8List(0));
    pointerList2.setRange(0, plane2?.length ?? 0, plane2 ?? Uint8List(0));

    // Call the convertImage function and convert the YUV to RGB
    Pointer<Uint32> imgP = _convertImageRGB(p, p1, p2, bytesPerRowPlane1,
        bytesPerPixelPlan1, bytesPerRowPlane0, height, rotationAngle);

    // Get the pointer of the data returned from the function to a List
    List<int> imgData = imgP.asTypedList(((newImgWidth) * (newImgHeight)));
    // Generate image from the converted data
    imglib.Image img =
        imglib.Image.fromBytes(newImgWidth, newImgHeight, imgData);

    // Free the memory space allocated
    // from the planes and the converted data
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

    Pointer<Uint32> imgP =
        _convertImageGrayFlutter(p, width, height, rotationAngle);

    List<int> imgData = imgP.asTypedList(newImgWidth * newImgHeight);
    imglib.Image img =
        imglib.Image.fromBytes(newImgWidth, newImgHeight, imgData);

    ffi.malloc.free(p);
    ffi.malloc.free(imgP);

    return img;
  }

  /// [processCameraImageToGray8Bit].
  @override
  Uint8List? processCameraImageToGray8Bit({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
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

    Pointer<Uint8> imgP =
        _convertImageGray8BitFlutter(p, width, height, rotationAngle);

    Uint8List imgData = imgP.asTypedList(newImgHeight * newImgWidth);

    ffi.malloc.free(p);
    ffi.malloc.free(imgP);

    return imgData;
  }
}
