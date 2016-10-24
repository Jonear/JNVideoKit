//
//  IFRotationFilter.m
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import "IFRotationFilter.h"

@implementation IFRotationFilter

//- (void)newFrameReady
//{
//    static const GLfloat rotationSquareVertices[] = {
//        -1.0f, -1.0f,
//        1.0f, -1.0f,
//        -1.0f,  1.0f,
//        1.0f,  1.0f,
//    };
//    
//    static const GLfloat rotateLeftTextureCoordinates[] = {
//        1.0f, 0.0f,
//        1.0f, 1.0f,
//        0.0f, 0.0f,
//        0.0f, 1.0f,
//    };
//    
//    static const GLfloat rotateRightTextureCoordinates[] = {
//        0.0f, 1.0f,
//        0.0f, 0.0f,
//        0.75f, 1.0f,
//        0.75f, 0.0f,
//    };
//
//    static const GLfloat verticalFlipTextureCoordinates[] = {
//        0.0f, 1.0f,
//        1.0f, 1.0f,
//        0.0f,  0.0f,
//        1.0f,  0.0f,
//    };
//    
//    static const GLfloat horizontalFlipTextureCoordinates[] = {
//        1.0f, 0.0f,
//        0.0f, 0.0f,
//        1.0f,  1.0f,
//        0.0f,  1.0f,
//    };
//    
//    switch (rotationMode)
//    {
//        case kGPUImageRotateLeft: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:rotateLeftTextureCoordinates]; break;
//        case kGPUImageRotateRight: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:rotateRightTextureCoordinates]; break;
//        case kGPUImageFlipHorizonal: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:verticalFlipTextureCoordinates]; break;
//        case kGPUImageFlipVertical: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:horizontalFlipTextureCoordinates]; break;
//    }
//    
//}

- (void)newFrameReady;
{
    //    static const GLfloat noRotationTextureCoordinates[] = {
    //        0.0f, 0.0f,
    //        1.0f, 0.0f,
    //        0.0f, 1.0f,
    //        1.0f, 1.0f,
    //    };
    
    static const GLfloat rotationSquareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 1.0f,
        0.0f, 0.0f,
        0.75f, 1.0f,
        0.75f, 0.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        0.75f, 0.0f,
        0.75f, 1.0f,
    };
    
    switch(rotationMode)
    {
        case kGPUImageNoRotation: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:noRotationTextureCoordinates]; break;
        case kGPUImageRotateLeft: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:rotateLeftTextureCoordinates]; break;
        case kGPUImageRotateRight: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:rotateRightTextureCoordinates]; break;
        case kGPUImageFlipVertical: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:verticalFlipTextureCoordinates]; break;
        case kGPUImageFlipHorizonal: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:horizontalFlipTextureCoordinates]; break;
        case kGPUImageRotateRightFlipVertical: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:rotateRightVerticalFlipTextureCoordinates]; break;
        case kGPUImageRotateRightFlipHorizontal: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:rotateRightHorizontalFlipTextureCoordinates]; break;
        case kGPUImageRotate180: [self renderToTextureWithVertices:rotationSquareVertices textureCoordinates:rotate180TextureCoordinates]; break;
    }
}

@end
