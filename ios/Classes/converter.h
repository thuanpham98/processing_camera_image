//
// Created by thuanpm on 4/22/22.
//

#ifndef PROCESSING_CAMERA_IMAGE_CONVERTER_H
#define PROCESSING_CAMERA_IMAGE_CONVERTER_H

#ifdef __cplusplus
extern "C"{
#endif

uint32_t *convertImage(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel, int width, int height);

#ifdef __cplusplus
extern "C"{
#endif

#endif //PROCESSING_CAMERA_IMAGE_CONVERTER_H