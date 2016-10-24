//
//  IFVideoCamera.h
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import "GPUImage.h"
#import "InstaFilters.h"
#import "IFRotationFilter.h"

@class IFVideoCamera;

@protocol IFVideoCameraDelegate <NSObject>

- (void)IFVideoCameraWillStartCaptureStillImage:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraDidFinishCaptureStillImage:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraDidSaveStillImage:(IFVideoCamera *)videoCamera;
- (BOOL)canIFVideoCameraStartRecordingMovie:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraWillStartProcessingMovie:(IFVideoCamera *)videoCamera;
- (void)IFVideoCameraDidFinishProcessingMovie:(IFVideoCamera *)videoCamera;
@end

@interface IFVideoCamera : GPUImageVideoCamera

@property (weak, nonatomic) id<IFVideoCameraDelegate> delegate;

@property (strong, readonly) GPUImageView *gpuImageView;
@property (strong, readonly) GPUImageView *gpuImageView_HD;
@property (nonatomic, strong) UIImage *rawImage;

@property (nonatomic, unsafe_unretained, readonly) BOOL isRecordingMovie;

@property (nonatomic, strong) IFImageFilter *internalFilter;

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition highVideoQuality:(BOOL)isHighQuality;
- (void)switchFilter:(IFFilterType)type;
- (void)cancelAlbumPhotoAndGoBackToNormal;
- (void)takePhoto;
- (void)startRecordingMovie;
- (void)stopRecordingMovie;
- (void)saveCurrentStillImage;
- (void)setRotation:(GPUImageRotationMode)newRotationMode;
@end
