#import <UIKit/UIKit.h>
#import "GPUImageOpenGLESContext.h"

typedef enum {
    kGPUImageFillModeStretch,                       // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
    kGPUImageFillModePreserveAspectRatio,           // Maintains the aspect ratio of the source image, adding bars of the specified background color
    kGPUImageFillModePreserveAspectRatioAndFill     // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
} GPUImageFillModeType;

@interface GPUImageView : UIView <GPUImageInput>

/** The fill mode dictates how images are fit in the view, with the default being kGPUImageFillModePreserveAspectRatio
 */
@property(readwrite, nonatomic) GPUImageFillModeType fillMode;

@end
