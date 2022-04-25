/*
'C' Header definition
uint32_t *convertImage(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel, int width, int height);
 */
import 'dart:ffi';

/*
  native convert camera image to rgb
*/
typedef ConvertImageRGBC = Pointer<Uint32> Function(Pointer<Uint8>,
    Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32, Double);
typedef ConvertImageRGBFlutter = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int, double);

/*
  native convert camera image to grayscale 32 bit
*/
typedef ConvertImageGrayC = Pointer<Uint32> Function(
    Pointer<Uint8>, Int32, Int32, Double);
typedef ConvertImageGrayFlutter = Pointer<Uint32> Function(
    Pointer<Uint8>, int, int, double);

/*
  native convert camera image to grayscale 8 bit
*/
typedef ConvertImageGray8BitC = Pointer<Uint8> Function(
    Pointer<Uint8>, Int32, Int32, Double);
typedef ConvertImageGray8BitFlutter = Pointer<Uint8> Function(
    Pointer<Uint8>, int, int, double);
