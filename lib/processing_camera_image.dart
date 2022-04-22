import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:image/image.dart' as imglib;

/*
'C' Header definition
uint32_t *convertImage(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel, int width, int height);
 */
typedef convert_image_rgb_c = Pointer<Uint32> Function(Pointer<Uint8>,
    Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32, Double);
typedef ConvertImageRGBFlutter = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int, double);

typedef convert_image_gray_c = Pointer<Uint32> Function(
    Pointer<Uint8>, Int32, Int32, Double);
typedef ConvertImageGrayFlutter = Pointer<Uint32> Function(
    Pointer<Uint8>, int, int, double);

class ProcessingCameraImage {
  static ProcessingCameraImage? _instance;
  late final ConvertImageRGBFlutter _convertImageRGB;
  late final ConvertImageGrayFlutter _convertImageGrayFlutter;

  factory ProcessingCameraImage() {
    _instance ??= ProcessingCameraImage._();
    return _instance!;
  }

  ProcessingCameraImage._() {
    final DynamicLibrary convertImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libconvertImage.so")
        : DynamicLibrary.process();
    _convertImageRGB = convertImageLib
        .lookup<NativeFunction<convert_image_rgb_c>>('convertImageRGB')
        .asFunction<ConvertImageRGBFlutter>();

    _convertImageGrayFlutter = convertImageLib
        .lookup<NativeFunction<convert_image_gray_c>>('convertImageGrayScale')
        .asFunction<ConvertImageGrayFlutter>();
  }

  /// [ProcessCameraImageToRGB].
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

    if (Platform.isAndroid) {
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
          bytesPerPixelPlan1, bytesPerRowPlane0, height, rotationAngle ?? 0.0);

      // Get the pointer of the data returned from the function to a List
      List<int> imgData = imgP.asTypedList(((bytesPerRowPlane0) * (height)));
      // Generate image from the converted data
      imglib.Image img =
          imglib.Image.fromBytes(height, bytesPerRowPlane0, imgData);

      // Free the memory space allocated
      // from the planes and the converted data
      ffi.malloc.free(p);
      ffi.malloc.free(p1);
      ffi.malloc.free(p2);
      ffi.malloc.free(imgP);

      if (rotationAngle != null) {
        // imglib.Image imgRot = imglib.copyRotate(img, rotationAngle);
        return img;
      } else {
        return img;
      }
    } else if (Platform.isIOS) {
      imglib.Image img = imglib.Image.fromBytes(
        bytesPerRowPlane0,
        height,
        plane0 ?? Uint8List(0),
        format: imglib.Format.bgra,
      );

      if (rotationAngle != null) {
        imglib.Image imgRot = imglib.copyRotate(img, rotationAngle);
        return imgRot;
      } else {
        return img;
      }
    }
    return null;
  }

  /// [processCameraImageToGray].
  imglib.Image? processCameraImageToGray({
    int? width,
    int? height,
    Uint8List? plane0,
    double? rotationAngle,
  }) {
    if (width == null || height == null || plane0?.isEmpty == null) {
      return null;
    }

    if (Platform.isAndroid) {
      Pointer<Uint8> p = ffi.malloc.allocate(plane0?.length ?? 0);
      Uint8List pointerList = p.asTypedList(plane0?.length ?? 0);
      pointerList.setRange(0, plane0?.length ?? 0, plane0 ?? Uint8List(0));

      Pointer<Uint32> imgP =
          _convertImageGrayFlutter(p, width, height, rotationAngle ?? 0.0);

      List<int> imgData = imgP.asTypedList(width * height);
      imglib.Image img = imglib.Image.fromBytes(height, width, imgData);

      ffi.malloc.free(p);
      ffi.malloc.free(imgP);

      if (rotationAngle != null) {
        imglib.Image imgRot = imglib.copyRotate(img, rotationAngle);
        return imgRot;
      } else {
        return img;
      }
    } else if (Platform.isIOS) {
      imglib.Image img = imglib.Image.fromBytes(
        width,
        height,
        plane0 ?? Uint8List(0),
        format: imglib.Format.bgra,
      );

      if (rotationAngle != null) {
        imglib.Image imgRot = imglib.copyRotate(img, rotationAngle);
        return imgRot;
      } else {
        return img;
      }
    }
    return null;
  }
}
