 //
//  KSVideoPlayer.m
//  JNVideoKitDemo
//
//  Created by Jonear on 12-8-23.
//  Copyright (c) 2012年 Jonear. All rights reserved.
//

#import "JNVideoPlayer.h"
#import <AudioToolbox/AudioServices.h>


@implementation JNVideoPlayer {
    AVPlayer *_player;
}

- (BOOL)initVideoPlayer:(UIView *)p_view videoFilePath:(NSURL*)videoUrl {
    if (p_view && videoUrl) {
        //使用playerItem获取视频的信息，当前播放时间，总时间等
        _playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        //player是视频播放的控制器，可以用来快进播放，暂停等
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        //调用一下setter方法
        playerLayer.frame = p_view.bounds;
        
        [p_view.layer addSublayer:playerLayer];
        
        _isPlaying = NO;
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playFinishNotification:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_playerItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playFiledNotification:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                   object:_playerItem];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)play {
    if (_player) {
        [_player play];
        _isPlaying = YES;
        return YES;
    }else {
        return NO;
    }
}

//暂停
- (BOOL)pause{
    if (_player) {
        [_player pause];
        _isPlaying = NO;
        return YES;
    }else {
        return NO;
    }
}

// 停止
- (BOOL)stop {
    if (_player) {
        [self seek:0.];
        [_player play];
        [_player pause];
        _isPlaying = NO;
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)seek:(CGFloat)f_seek_time{
    if (_player) {
        CMTime time = CMTimeMake(f_seek_time*_player.currentTime.timescale, _player.currentTime.timescale);
        [_player seekToTime:time];
        return YES;
    } else {
        return NO;
    }
}

- (CGFloat)currentTime{
    if (_player) {
        CMTime ctime = _player.currentTime;
        UInt64 currentTimeSec = ctime.value/ctime.timescale;
        return currentTimeSec;
    }else {
        return 0;
    }
}

- (CGFloat)duration{
    if (_player && _playerItem) {
        CMTime ctime = _playerItem.duration;
        UInt64 currentTimeSec = ctime.value/ctime.timescale;
        return currentTimeSec;
    }else {
        return 0;
    }
}

- (CGFloat)timeScale {
    return _player.currentTime.timescale;
}

// MARK: - play notifcation
- (void)playFinishNotification:(NSNotification *)notification {
    _isPlaying = NO;
    [self seek:0.];
}

- (void)playFiledNotification:(NSNotification *)notification {
    _isPlaying = NO;
}

@end
