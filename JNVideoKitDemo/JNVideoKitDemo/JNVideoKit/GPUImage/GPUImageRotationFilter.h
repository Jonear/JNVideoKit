#import "GPUImageFilter.h"

//typedef enum { kGPUImageRotateLeft, kGPUImageRotateRight, kGPUImageFlipVertical, kGPUImageFlipHorizonal} GPUImageRotationMode;
typedef enum {kGPUImageNoRotation, kGPUImageRotateLeft, kGPUImageRotateRight, kGPUImageFlipVertical, kGPUImageFlipHorizonal, kGPUImageRotateRightFlipVertical, kGPUImageRotateRightFlipHorizontal, kGPUImageRotate180} GPUImageRotationMode;

@interface GPUImageRotationFilter : GPUImageFilter
{
    GPUImageRotationMode rotationMode;
}

// Initialization and teardown
- (id)initWithRotation:(GPUImageRotationMode)newRotationMode;

- (void)setRotation:(GPUImageRotationMode)newRotationMode;
@end
