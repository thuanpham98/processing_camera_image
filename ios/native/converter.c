//
// Created by thuanpm on 4/22/22.
//

#include <stdio.h>
#include "converter.h"
#include <math.h>
#include <stdlib.h>

#define HEXFF 255

int _clamp(int lower, int higher, int val)
{
    if (val < lower)
        return 0;
    else if (val > higher)
        return 255;
    else
        return val;
}

uint32_t *_rotaion_image_32bit(uint32_t *src, double angle, int width, int height, uint32_t background_color)
{
    double rad = (angle * M_PI / 180.0);
    double sinVal = sin(rad);
    double cosVal = cos(rad);
    int new_width = (int)(fabs(sinVal * height) + fabs(cosVal * width));
    int new_height = (int)(fabs(sinVal * width) + fabs(cosVal * height));
    double w2 = 0.5 * width;
    double h2 = 0.5 * height;
    double dw2 = 0.5 * new_width;
    double dh2 = 0.5 * new_height;

    uint32_t *dest = malloc(sizeof(uint32_t) * (new_width * new_height));

    for (int i = 0; i < new_height; ++i)
    {
        for (int j = 0; j < new_width; ++j)
        {
            int oriX = (int)(w2 + (j - dw2) * cosVal + (i - dh2) * sinVal);
            int oriY = (int)(h2 - (j - dw2) * sinVal + (i - dh2) * cosVal);
            if (oriX >= 0 && oriX < width && oriY >= 0 && oriY < height)
            {
                dest[i * new_width + j] = src[oriX + oriY * width];
            }
            else
            {
                dest[i * new_width + j] = background_color;
            }
        }
    }
    free(src);
    return dest;
}

uint8_t *_rotaion_image_8bit(uint8_t *src, double angle, int width, int height, uint8_t background_color)
{
    double rad = (angle * M_PI / 180.0);
    double sinVal = sin(rad);
    double cosVal = cos(rad);
    int new_width = (int)(fabs(sinVal * height) + fabs(cosVal * width));
    int new_height = (int)(fabs(sinVal * width) + fabs(cosVal * height));
    double w2 = 0.5 * width;
    double h2 = 0.5 * height;
    double dw2 = 0.5 * new_width;
    double dh2 = 0.5 * new_height;

    uint8_t *dest = malloc(sizeof(uint8_t) * (new_width * new_height));

    for (int i = 0; i < new_height; ++i)
    {
        for (int j = 0; j < new_width; ++j)
        {
            int oriX = (int)(w2 + (j - dw2) * cosVal + (i - dh2) * sinVal);
            int oriY = (int)(h2 - (j - dw2) * sinVal + (i - dh2) * cosVal);
            if (oriX >= 0 && oriX < width && oriY >= 0 && oriY < height)
            {
                dest[i * new_width + j] = src[oriX + oriY * width];
            }
            else
            {
                dest[i * new_width + j] = background_color;
            }
        }
    }
    free(src);
    return dest;
}

void _flip_horizontal_32bit(int width, int height, uint32_t *src)
{
    int dw2 = (int)(width / 2);
    for (int y = 0; y < height; ++y)
    {
        int y1 = (y * width);
        for (int x = 0; x < dw2; ++x)
        {
            int x2 = (width - 1 - x);
            uint32_t t = src[y1 + x2];
            src[y1 + x2] = src[y1 + x];
            src[y1 + x] = t;
        }
    }
}

void _flip_horizontal_8bit(int width, int height, uint8_t *src)
{
    int dw2 = (int)(width / 2);
    for (int y = 0; y < height; ++y)
    {
        int y1 = (y * width);
        for (int x = 0; x < dw2; ++x)
        {
            int x2 = (width - 1 - x);
            uint8_t t = src[y1 + x2];
            src[y1 + x2] = src[y1 + x];
            src[y1 + x] = t;
        }
    }
}

void _flip_vertical_32bit(int width, int height, uint32_t *src)
{
    int h2 = (int)(height / 2);
    for (int y = 0; y < h2; ++y)
    {
        int y1 = (y * width);
        int y2 = (height - 1 - y) * width;
        for (int x = 0; x < width; ++x)
        {
            uint32_t t = src[y2 + x];
            src[y2 + x] = src[y1 + x];
            src[y1 + x] = t;
        }
    }
}

void _flip_vertical_8bit(int width, int height, uint8_t *src)
{
    int h2 = (int)(height / 2);
    for (int y = 0; y < h2; ++y)
    {
        int y1 = (y * width);
        int y2 = (height - 1 - y) * width;
        for (int x = 0; x < width; ++x)
        {
            uint8_t t = src[y2 + x];
            src[y2 + x] = src[y1 + x];
            src[y1 + x] = t;
        }
    }
}

uint32_t *convert_image_yuv420p_to_gray(uint8_t *plane0, int width, int height, double angleRotation, uint32_t background_color, bool flip_vertical, bool flip_horizontal)
{
    int x, y;
    int yp, index;

    uint32_t *src = malloc(sizeof(uint32_t) * (width * height));

    for (x = 0; x < width; x++)
    {
        for (y = 0; y < height; y++)
        {
            index = y * width + x;
            yp = plane0[index];
            src[x + y * width] = (HEXFF << 24) | (yp << 16) | (yp << 8) | yp;
        }
    }
    if (flip_horizontal)
    {
        _flip_horizontal_32bit(width, height, src);
    }
    if (flip_vertical)
    {
        _flip_vertical_32bit(width, height, src);
    }

    if (angleRotation == 0)
    {
        return src;
    }

    else
    {
        return _rotaion_image_32bit(src, angleRotation, width, height, background_color);
    }
}

uint8_t *convert_image_yuv420p_to_gray_8bit(uint8_t *plane0, int width, int height, double angleRotation, uint8_t background_color, bool flip_vertical, bool flip_horizontal)
{
    int x, y;
    int index;
    uint8_t yp;

    uint8_t *src = malloc(sizeof(uint8_t) * (width * height));

    for (x = 0; x < width; x++)
    {
        for (y = 0; y < height; y++)
        {
            index = y * width + x;
            yp = plane0[index];
            src[x + y * width] = yp;
        }
    }

    if (flip_horizontal)
    {
        _flip_horizontal_8bit(width, height, src);
    }
    if (flip_vertical)
    {
        _flip_vertical_8bit(width, height, src);
    }

    if (angleRotation == 0)
    {
        return src;
    }
    else
    {
        return _rotaion_image_8bit(src, angleRotation, width, height, background_color);
    }
}

uint32_t *convert_image_yuv420p_to_rgb(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel, int width, int height, double angleRotation, uint32_t background_color, bool flip_vertical, bool flip_horizontal)
{
    int x, y, uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;

    uint32_t *src = malloc(sizeof(uint32_t) * (width * height));

    for (x = 0; x < width; ++x)
    {
        for (y = 0; y < height; ++y)
        {
            uvIndex = bytesPerPixel * ((int)floor(x / 2)) + bytesPerRow * ((int)floor(y / 2));
            index = y * width + x;

            yp = plane0[index];
            up = plane1[uvIndex];
            vp = plane2[uvIndex];
            rt = round(yp + vp * 1436 / 1024 - 179);
            gt = round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91);
            bt = round(yp + up * 1814 / 1024 - 227);
            r = _clamp(0, 255, rt);
            g = _clamp(0, 255, gt);
            b = _clamp(0, 255, bt);
            src[x + y * width] = (HEXFF << 24) | (b << 16) | (g << 8) | r;
        }
    }
    if (flip_horizontal)
    {
        _flip_horizontal_32bit(width, height, src);
    }
    if (flip_vertical)
    {
        _flip_vertical_32bit(width, height, src);
    }

    if (angleRotation == 0)
    {
        return src;
    }
    else
    {
        return _rotaion_image_32bit(src, angleRotation, width, height, background_color);
    }
}

uint32_t *convert_image_nv12_to_rgb(uint8_t *plane0, uint8_t *plane1, int bytesPerRow, int bytesPerPixel, int width, int height, double angleRotation, uint32_t background_color, bool flip_vertical, bool flip_horizontal)
{
    int x, y, uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;

    uint32_t *src = malloc(sizeof(uint32_t) * (width * height));

    for (x = 0; x < width; ++x)
    {
        for (y = 0; y < height; ++y)
        {
            uvIndex = bytesPerPixel * ((int)floor(x / 2)) + bytesPerRow * ((int)floor(y / 2));
            index = y * width + x;

            yp = plane0[index];
            up = plane1[uvIndex];
            vp = plane1[uvIndex + 1];
            rt = round(yp + vp * 1436 / 1024 - 179);
            gt = round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91);
            bt = round(yp + up * 1814 / 1024 - 227);
            r = _clamp(0, 255, rt);
            g = _clamp(0, 255, gt);
            b = _clamp(0, 255, bt);
            src[x + y * width] = (HEXFF << 24) | (b << 16) | (g << 8) | r;
        }
    }
    if (flip_horizontal)
    {
        _flip_horizontal_32bit(width, height, src);
    }
    if (flip_vertical)
    {
        _flip_vertical_32bit(width, height, src);
    }
    if (angleRotation == 0)
    {
        return src;
    }
    else
    {
        return _rotaion_image_32bit(src, angleRotation, width, height, background_color);
    }
}