 //
//  KSVideoPlayer.m
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "JNVideoPlayer.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@implementation JNVideoPlayer {
    AVPlayer *_player;
}

- (BOOL)initVideoPlayer:(UIView *)p_view videoFilePath:(NSURL*)videoUrl {
    if (p_view && videoUrl) {
        //使用playerItem获取视频的信息，当前播放时间，总时间等
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        //player是视频播放的控制器，可以用来快进播放，暂停等
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        //调用一下setter方法
        playerLayer.frame = p_view.bounds;
        
        [p_view.layer addSublayer:playerLayer];
        _isPlaying = false;
        
        return YES;
    }
    
    return NO;
}

- (BOOL)play {
    if (_player) {
        [_player play];
        _isPlaying = true;
        return YES;
    }else {
        return NO;
    }
}

//暂停
- (BOOL)pause{
    if (_player) {
        [_player pause];
        _isPlaying = false;
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)seek:(float)f_seek_time{
//    if (m_pMoviePlayer && (f_seek_time < m_pMoviePlayer.playableDuration)) {
//        NSLog(@"~~~~~~~~~mv:%f", f_seek_time+1);
//        if (m_bPlaying) {
//            [m_pMoviePlayer pause];
//            m_pMoviePlayer.currentPlaybackTime = f_seek_time+1;
//            [m_pMoviePlayer play];
//            
//            return true;
//        }else {
//            [m_pMoviePlayer pause];
//            m_pMoviePlayer.currentPlaybackTime = f_seek_time+1;
//            [m_pMoviePlayer play];
//            [m_pMoviePlayer pause];
//            return true;
//        }
//    }else {
        return false;
//    }
}

- (float)currentTime{
//    if (m_pMoviePlayer && 0 < m_pMoviePlayer.duration) {
//        return m_pMoviePlayer.currentPlaybackTime;
//    }else {
        return 0;
//    }
}

- (float)duration{
//    if (_player) {
////        return _player.duration;
//    }else {
        return 0;
//    }
}

@end
