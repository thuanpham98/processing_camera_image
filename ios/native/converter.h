//
// Created by thuanpm on 4/22/22.
//

#ifndef PROCESSING_CAMERA_IMAGE_CONVERTER_H
#define PROCESSING_CAMERA_IMAGE_CONVERTER_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>

    uint8_t *convert_image_yuv420p_to_gray_8bit(uint8_t *plane0, int width, int height, double angleRotation, uint8_t background_color, bool flip_vertical, bool flip_horizontal);
    uint32_t *convert_image_nv12_to_rgb(uint8_t *plane0, uint8_t *plane1, int bytesPerRow, int bytesPerPixel, int width, int height, double angleRotation, uint32_t background_color, bool flip_vertical, bool flip_horizontal);
    uint32_t *convert_image_yuv420p_to_gray(uint8_t *plane0, int width, int height, double angleRotation, uint32_t background_color, bool flip_vertical, bool flip_horizontal);
    uint32_t *convert_image_yuv420p_to_rgb(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel, int width, int height, double angleRotation, uint32_t background_color, bool flip_vertical, bool flip_horizontal);

#ifdef __cplusplus
}
#endif

#endif // PROCESSING_CAMERA_IMAGE_CONVERTER_H