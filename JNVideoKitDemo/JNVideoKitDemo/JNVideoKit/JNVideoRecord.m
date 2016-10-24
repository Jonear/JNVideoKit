//
//  KSVideoRecordNew.m
//  JNVideoKitDemo
//
//  Created by Jonear on 14-10-14.
//  Copyright (c) 2014年 Jonear. All rights reserved.
//

#import "JNVideoRecord.h"

#define VIDEO_WIDTH     480
#define VIDEO_HEIGHT    480

@implementation JNVideoRecord
{
    GPUImageMovieWriter *_movieWriter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.videoCamera = [[IFVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront highVideoQuality:YES];
        
//        self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//        self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
//        self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
//        [self.videoCamera switchFilter:IF_INKWELL_FILTER];
    }
    return self;
}

- (void)initVideoCapture:(GPUImageView *)imageView path:(NSString *)str_video_file_path{
    // 展示页
    _imageView = imageView;
    [imageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    [self.videoCamera.internalFilter addTarget:imageView];
//  imageView.layer.contentsScale = 2.0f; //高质量追求
    
    // 显示view左右调换
    [self moveVideoShowPosition];
    
    // 写文件
    if (str_video_file_path.length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:str_video_file_path error:nil];
        [self creatVideoWriter:str_video_file_path];
    }
}

- (void)creatVideoWriter:(NSString *)filePath {
    NSMutableDictionary *videoSettings = [[NSMutableDictionary alloc] init];;
    [videoSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [videoSettings setObject:[NSNumber numberWithInteger:VIDEO_WIDTH] forKey:AVVideoWidthKey];
    [videoSettings setObject:[NSNumber numberWithInteger:VIDEO_HEIGHT] forKey:AVVideoHeightKey];
    
    //init audio setting
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    //    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
    //                     [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
    //                     [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,
    //                     [ NSNumber numberWithFloat: 16000.0], AVSampleRateKey,
    //                     [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
    //                     [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,
    //                     nil];
    
    //init Movie path
    unlink([filePath UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    
    //init movieWriter
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(VIDEO_WIDTH, VIDEO_HEIGHT) fileType:AVFileTypeMPEG4 outputSettings:videoSettings];
    //    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    
    //    [_movieWriter setHasAudioTrack:YES audioSettings:audioSettings];
    
    [self.videoCamera.internalFilter addTarget:_movieWriter];
}

- (void)moveVideoShowPosition {
    if (self.videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        [self.videoCamera setRotation:kGPUImageRotate180];
    } else {
        [self.videoCamera setRotation:kGPUImageNoRotation];
    }
}

- (void)startVideoRecord {
    [_movieWriter startRecording];
}

- (void)rotateCamera {
    [_videoCamera rotateCamera];
    [self moveVideoShowPosition];
}

- (void)startVideoCapture {
    [_videoCamera startCameraCapture];
//    [self startVideoRecord];
}

- (void)stopVideoCapture {
    [_movieWriter finishRecording];
    [self.videoCamera.internalFilter removeTarget:_movieWriter];
    [_videoCamera stopCameraCapture];
}

- (void)waitVideoCapture {
    [_movieWriter finishRecording];
    [self.videoCamera.internalFilter removeTarget:_movieWriter];
}

- (BOOL)pauseVideoCapture {
    NSTimeInterval time = [_movieWriter getRecordTime];
    if (time > 1.) {
        [_movieWriter finishRecording];
        [self.videoCamera.internalFilter removeTarget:_movieWriter];
        return YES;
    } else {
        return NO;
    }
}

- (void)continueVideoCapture:(NSString *)filePath {
    if (filePath.length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [self creatVideoWriter:filePath];
    } else {
        [self.videoCamera.internalFilter addTarget:_movieWriter];
    }
    [self startVideoRecord];
}

- (void)setFilterModel:(IFFilterType)effect{
    [self.videoCamera switchFilter:effect];
    [self updateFilterView];
}

- (void)updateFilterView
{
//    [_videoCamera removeTarget:self.videoCamera.internalFilter];
    if (_imageView) {
        [self.videoCamera.internalFilter addTarget:_imageView];
    }
    if (_movieWriter) {
        [self.videoCamera.internalFilter addTarget:_movieWriter];
    }
//    [_videoCamera addTarget:self.videoCamera.internalFilter];
}

- (void)dealloc
{
    [_videoCamera stopCameraCapture];
}

@end
