//
//  KSVideoPlayer.h
//  JNVideoKitDemo
//
//  Created by Jonear on 12-8-23.
//  Copyright (c) 2012年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const AVPlayerItemDidPlayToEndTimeNotification; //播放完成
extern NSString *const AVPlayerItemFailedToPlayToEndTimeNotification; //播放失败

@interface JNVideoPlayer : NSObject

@property (strong, nonatomic, readonly) AVPlayerItem *playerItem;
@property (assign, nonatomic, readonly) BOOL isPlaying;

- (BOOL)initVideoPlayer:(UIView *)p_view videoFilePath:(NSURL*)videoUrl;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)stop;
- (BOOL)seek:(float)f_seek_time;

- (float)currentTime;
- (float)duration;

@end
