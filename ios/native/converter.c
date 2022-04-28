//
// Created by thuanpm on 4/22/22.
//

#include <stdio.h>
#include "converter.h"
#include <math.h>
#include <stdlib.h>

int clamp(int lower, int higher, int val)
{
    if (val < lower)
        return 0;
    else if (val > higher)
        return 255;
    else
        return val;
}

int getRotatedImageByteIndex(int x, int y, int rotatedImageWidth)
{
    return rotatedImageWidth * (y) + (x);
}

uint32_t *convert_image_gray_scale(uint8_t *plane0, int width, int height, double angleRotation)
{
    int x, y;
    int yp, index;
    int hexFF = 255;
    double rad = (angleRotation * M_PI / 180.0);
    double sinVal = sin(rad);
    double cosVal = cos(rad);
    int newImgWidth = (int)(fabs(sinVal * height) + fabs(cosVal * width));
    int newImgHeight = (int)(fabs(sinVal * width) + fabs(cosVal * height));
    double w2 = 0.5 * width;
    double h2 = 0.5 * height;
    double dw2 = 0.5 * newImgWidth;
    double dh2 = 0.5 * newImgHeight;

    uint32_t *table = malloc(sizeof(uint32_t) * (width * height));
    uint32_t *imageRot = malloc(sizeof(uint32_t) * (newImgWidth * newImgHeight));

    for (x = 0; x < width; x++)
    {
        for (y = 0; y < height; y++)
        {
            index = y * width + x;
            yp = plane0[index];
            table[x + y * width] = (hexFF << 24) | (yp << 16) | (yp << 8) | yp;
        }
    }

    for (int i = 0; i < newImgHeight; i++)
    {
        for (int j = 0; j < newImgWidth; j++)
        {
            double oriX = (w2 + (j - dw2) * cosVal + (i - dh2) * sinVal);
            double oriY = (h2 - (j - dw2) * sinVal + (i - dh2) * cosVal);
            if (oriX >= 0 && oriX < width && oriY >= 0 && oriY < height)
            {
                imageRot[i * newImgWidth + j] =
                    table[(int)(oriX) + (int)(oriY)*newImgHeight];
            }
            else
            {
                imageRot[i * newImgWidth + j] = 0;
            }
        }
    }
    free(table);
    for (int i = 0; i < newImgHeight; i++)
    {
        int i1 = (int)(i * newImgWidth);
        for (int j = 0; j < (int)(dw2); j++)
        {
            int j2 = (newImgWidth - 1 - j);
            uint32_t t = imageRot[i1 + j2];
            imageRot[i1 + j2] = imageRot[i1 + j];
            imageRot[i1 + j] = t;
        }
    }

    return imageRot;
}

uint8_t *convert_image_gray_scale_8bit(uint8_t *plane0, int width, int height, double angleRotation)
{
    int x, y;
    int yp, index;
    int hexFF = 255;
    double rad = (angleRotation * M_PI / 180.0);
    double sinVal = sin(rad);
    double cosVal = cos(rad);
    int newImgWidth = (int)(fabs(sinVal * height) + fabs(cosVal * width));
    int newImgHeight = (int)(fabs(sinVal * width) + fabs(cosVal * height));
    double w2 = 0.5 * width;
    double h2 = 0.5 * height;
    double dw2 = 0.5 * newImgWidth;
    double dh2 = 0.5 * newImgHeight;

    uint32_t *table = malloc(sizeof(uint32_t) * (width * height));
    uint8_t *imageRot = malloc(sizeof(uint8_t) * (newImgWidth * newImgHeight));

    for (x = 0; x < width; x++)
    {
        for (y = 0; y < height; y++)
        {
            index = y * width + x;
            yp = plane0[index];
            table[x + y * width] = yp;
        }
    }

    for (int i = 0; i < newImgHeight; ++i)
    {
        for (int j = 0; j < newImgWidth; ++j)
        {
            double oriX = (w2 + (j - dw2) * cosVal + (i - dh2) * sinVal);
            double oriY = (h2 - (j - dw2) * sinVal + (i - dh2) * cosVal);
            if (oriX >= 0 && oriX < width && oriY >= 0 && oriY < height)
            {
                imageRot[i * newImgWidth + j] = table[(int)(oriX) + (int)(oriY)*newImgHeight];
            }
            else
            {
                imageRot[i * newImgWidth + j] = 0;
            }
        }
    }
    free(table);
    for (int i = 0; i < newImgHeight; ++i)
    {
        int i1 = (int)(i * newImgWidth);
        for (int j = 0; j < (int)(dw2); ++j)
        {
            int j2 = (newImgWidth - 1 - j);
            uint8_t t = imageRot[i1 + j2];
            imageRot[i1 + j2] = imageRot[i1 + j];
            imageRot[i1 + j] = t;
        }
    }

    return imageRot;
}

uint32_t *convert_image_rgb(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow, int bytesPerPixel, int width, int height, double angleRotation)
{
    int hexFF = 255;
    int x, y, uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;

    double rad = (angleRotation * M_PI / 180.0);
    double sinVal = sin(rad);
    double cosVal = cos(rad);
    int newImgWidth = (int)(fabs(sinVal * height) + fabs(cosVal * width));
    int newImgHeight = (int)(fabs(sinVal * width) + fabs(cosVal * height));
    double w2 = 0.5 * width;
    double h2 = 0.5 * height;
    double dw2 = 0.5 * newImgWidth;
    double dh2 = 0.5 * newImgHeight;

    uint32_t *table = malloc(sizeof(uint32_t) * (width * height));
    uint32_t *imageRot = malloc(sizeof(uint32_t) * (newImgWidth * newImgHeight));

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
            r = clamp(0, 255, rt);
            g = clamp(0, 255, gt);
            b = clamp(0, 255, bt);
            table[x + y * width] = (hexFF << 24) | (b << 16) | (g << 8) | r;
        }
    }

    for (int i = 0; i < newImgHeight; ++i)
    {
        for (int j = 0; j < newImgWidth; ++j)
        {
            double oriX = (w2 + (j - dw2) * cosVal + (i - dh2) * sinVal);
            double oriY = (h2 - (j - dw2) * sinVal + (i - dh2) * cosVal);
            if (oriX >= 0 && oriX < width && oriY >= 0 && oriY < height)
            {
                imageRot[i * newImgWidth + j] = table[(int)(oriX) + (int)(oriY)*newImgHeight];
            }
            else
            {
                imageRot[i * newImgWidth + j] = 0;
            }
        }
    }
    free(table);
    for (int i = 0; i < newImgHeight; ++i)
    {
        int i1 = (int)(i * newImgWidth);
        for (int j = 0; j < (int)(dw2); ++j)
        {
            int j2 = (newImgWidth - 1 - j);
            uint32_t t = imageRot[i1 + j2];
            imageRot[i1 + j2] = imageRot[i1 + j];
            imageRot[i1 + j] = t;
        }
    }

    return imageRot;
}