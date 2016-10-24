//
//  KSVideoRecordNew.h
//  KwSing
//
//  Created by zg.shao on 14-10-14.
//  Copyright (c) 2014年 kuwo.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "GPUImageFilter.h"
#import "IFVideoCamera.h"

@interface JNVideoRecord : NSObject

@property (nonatomic, strong) IFVideoCamera *videoCamera;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput>  *imageFilter;
@property (nonatomic, strong) GPUImageView   *imageView;

- (void)initVideoCapture:(GPUImageView *)imageView path:(NSString *)str_video_file_path;

/**
 *  开始写入文件
 */
- (void)startVideoRecord;

/**
 *  切换摄像头
 */
- (void)rotateCamera;

/**
 *  开始录制并写入文件
 */
- (void)startVideoCapture;

/**
 *  停止视频
 */
- (void)stopVideoCapture;

/**
 *  停止写入文件，预览一直存在
 */
- (void)waitVideoCapture;

/**
 *  暂停 (小视频使用)
 */
- (BOOL)pauseVideoCapture;

/**
 *  继续 (小视频使用)
 */
- (void)continueVideoCapture:(NSString *)filePath;

/**
 *  选择滤镜
 */
- (void)setFilterModel:(IFFilterType)effect;

@end
