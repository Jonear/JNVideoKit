//
//  KSVideoPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JNVideoPlayer : NSObject

@property (assign, nonatomic, readonly) BOOL isPlaying;

- (BOOL)initVideoPlayer:(UIView *)p_view videoFilePath:(NSURL*)videoUrl;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)seek:(float)f_seek_time;

- (float)currentTime;
- (float)duration;

@end
