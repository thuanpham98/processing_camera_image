/*
'C' Header definition
uint32_t *convertImage(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel, int width, int height);
 */
import 'dart:ffi';

/*
  native convert camera image YUV420p to rgb
*/
typedef ConvertImageYuv420pToRGBC = Pointer<Uint32> Function(
  Pointer<Uint8>,
  Pointer<Uint8>,
  Pointer<Uint8>,
  Int32,
  Int32,
  Int32,
  Int32,
  Double,
  Uint32,
  Bool,
  Bool,
);
typedef ConvertImageYuv420pToRGBFlutter = Pointer<Uint32> Function(
  Pointer<Uint8>,
  Pointer<Uint8>,
  Pointer<Uint8>,
  int,
  int,
  int,
  int,
  double,
  int,
  bool,
  bool,
);

/*
  native convert camera image YUV420p to grayscale 32 bit
*/
typedef ConvertImageYuv420pToGrayC = Pointer<Uint32> Function(
    Pointer<Uint8>, Int32, Int32, Double, Uint32, Bool, Bool);
typedef ConvertImageYuv420pToGrayFlutter = Pointer<Uint32> Function(
    Pointer<Uint8>, int, int, double, int, bool, bool);

/*
  native convert camera image YUV420p to grayscale 8 bit
*/
typedef ConvertImageYuv420pToGray8BitC = Pointer<Uint8> Function(
    Pointer<Uint8>, Int32, Int32, Double, Uint8, Bool, Bool);
typedef ConvertImageYuv420pToGray8BitFlutter = Pointer<Uint8> Function(
    Pointer<Uint8>, int, int, double, int, bool, bool);

/*
  native convert camera image YUV420sp( or NV12) to rgb
*/
typedef ConvertImageNV12ToRGBC = Pointer<Uint32> Function(Pointer<Uint8>,
    Pointer<Uint8>, Int32, Int32, Int32, Int32, Double, Uint32, Bool, Bool);
typedef ConvertImageNV12ToRGBFlutter = Pointer<Uint32> Function(Pointer<Uint8>,
    Pointer<Uint8>, int, int, int, int, double, int, bool, bool);
