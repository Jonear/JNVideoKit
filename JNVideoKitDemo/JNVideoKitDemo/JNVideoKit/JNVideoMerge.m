//
//  KSVideoMerge.m
//  JNVideoKitDemo
//
//  Created by Jonear on 12-8-30.
//  Copyright (c) 2012年 Jonear. All rights reserved.
//

#import "JNVideoMerge.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@implementation JNVideoMerge

static BOOL s_b_merge_success = YES;

+(BOOL)mergeAVFile:(NSString *)str_audio_path videoFilePath:(NSString *)str_video_path mergeFilePath:(NSString*)str_merge_path completion:(CompletionBack)block {
    
    s_b_merge_success = YES;
    
    AVURLAsset* asset_audio = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:str_audio_path] options:nil];
    AVURLAsset* asset_video = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:str_video_path] options:nil];
    AVAssetTrack *assetTrack = [[asset_video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    AVMutableComposition* mix_composition = [AVMutableComposition composition];
    NSError *error = nil;
    AVMutableCompositionTrack* composition_comment_track = [mix_composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [composition_comment_track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset_video.duration)  ofTrack:[[asset_audio tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:&error];
    if(error)
        NSLog(@"Insertion audio error: %@", error);
    
    AVMutableCompositionTrack* composition_video_track = [mix_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [composition_video_track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset_video.duration) ofTrack:assetTrack atTime:kCMTimeZero error:&error];
    //    composition_video_track.preferredTransform = CGAffineTransformMakeRotation(M_PI_2);
    if(error)
        NSLog(@"Insertion video error: %@", error);
    
    AVAssetExportSession* asset_export = [[AVAssetExportSession alloc] initWithAsset:mix_composition presetName:AVAssetExportPresetMediumQuality];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:str_merge_path]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:str_merge_path] error:nil];
    }
    
    
    //截取成正方形
    
    CGFloat renderW = MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
    CGFloat renderH = renderW*3/4;
    CGFloat rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
//
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:composition_video_track];
    
    // 缩放
    //    CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
    //    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影响
    //    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
    
    // 缩放
    CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, (renderH - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影响
    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
    
    //    CGAffineTransform layerTransform = CGAffineTransformMake(1, 0, 0, 1, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0, - assetTrack.naturalSize.height);//向上移动取中部影响
    //    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
    //    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMakeRotation(M_PI_2));
    
    [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
    [layerInstruciton setOpacity:0.0 atTime:asset_video.duration];
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, asset_video.duration);
    mainInstruciton.layerInstructions = [NSArray arrayWithObject:layerInstruciton];//@[layerInstruciton];
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruciton];//@[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderH);
    mainCompositionInst.renderScale = 1.0;
    asset_export.videoComposition = mainCompositionInst;
    
    // 合成
    asset_export.outputFileType = AVFileTypeMPEG4;
    asset_export.outputURL = [NSURL fileURLWithPath:str_merge_path];
    asset_export.shouldOptimizeForNetworkUse = YES;
    [asset_export exportAsynchronouslyWithCompletionHandler:^(void){
        if (AVAssetExportSessionStatusCompleted != asset_export.status) {
            NSLog(@"video mix error: %d", (int)asset_export.status);
            block(NO);
        }else{
            block(YES);
        }
    }];
    return s_b_merge_success;
}

+(BOOL)mergeFreeVideoFilePath:(NSArray *)videoPathArray mergeFilePath:(NSString*)str_merge_path completion:(CompletionBack)block {
    if (videoPathArray.count == 0 || str_merge_path.length==0) {
        block(NO);
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:str_merge_path]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:str_merge_path] error:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        
        CGSize renderSize = CGSizeMake(0, 0);
        
        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        CMTime totalDuration = kCMTimeZero;
        
        //先去assetTrack 也为了取renderSize
        NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
        NSMutableArray *assetArray = [[NSMutableArray alloc] init];
        for (NSString *fileURL in videoPathArray) {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:fileURL]];
            
            if (!asset) {
                continue;
            }
            
            [assetArray addObject:asset];
            
            AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [assetTrackArray addObject:assetTrack];
            
            renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
            renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
        }
        
        CGFloat renderW = MIN(renderSize.width, renderSize.height);
        CGFloat renderH = renderW*3/4;
        CGFloat rate = renderW / MIN(renderSize.width, renderSize.height);
        
        for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
            
            AVAsset *asset = [assetArray objectAtIndex:i];
            AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
            
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:assetTrack
                                 atTime:totalDuration
                                  error:&error];
            
            //fix orientationissue
            AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            totalDuration = CMTimeAdd(totalDuration, asset.duration);
            
            // 缩放
            CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, (renderH - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影响
            layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
            
            [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
            [layerInstruciton setOpacity:0.0 atTime:totalDuration];
            
            //data
            [layerInstructionArray addObject:layerInstruciton];
        }
        
        //get save path
        NSURL *mergeFileURL = [NSURL fileURLWithPath:str_merge_path];
        
        //export
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        mainInstruciton.layerInstructions = layerInstructionArray;
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        mainCompositionInst.instructions = @[mainInstruciton];
        mainCompositionInst.frameDuration = CMTimeMake(1, 30);
        mainCompositionInst.renderSize = CGSizeMake(renderW, renderH);
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
        exporter.videoComposition = mainCompositionInst;
        exporter.outputURL = mergeFileURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (AVAssetExportSessionStatusCompleted != exporter.status) {
                    NSLog(@"free video mix error: %d", (int)exporter.status);
                    block(NO);
                }else{
                    block(YES);
                }
            });
        }];
    });
    
    return YES;
}


+ (BOOL)cropVideoFilePath:(NSString *)videoPath
            mergeFilePath:(NSString *)str_merge_path
                startTime:(CMTime)startTime
               lengthTime:(CMTime)lengthTime
               completion:(CompletionBack)block {
    
    if (videoPath.length == 0 || str_merge_path.length==0) {
        block(NO);
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:str_merge_path]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:str_merge_path] error:nil];
    }
    
    //1 — 采集
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    // 2 创建AVMutableComposition实例. apple developer 里边的解释 【AVMutableComposition is a mutable subclass of AVComposition you use when you want to create a new composition from existing assets. You can add and remove tracks, and you can add, remove, and scale time ranges.】
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *error = nil;
    // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长 (我这裁剪的是从第二秒开始裁剪，裁剪2.55秒时长.)
    [videoTrack insertTimeRange:CMTimeRangeMake(startTime, lengthTime)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero
                          error:&error];
    
    // 3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, lengthTime);
    
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:lengthTime];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    // AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    // 4 - Get path
    NSURL *outUrl = [NSURL fileURLWithPath:str_merge_path];
    
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = outUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (AVAssetExportSessionStatusCompleted != exporter.status) {
                NSLog(@"crop video error: %d", (int)exporter.status);
                block(NO);
            }else{
                block(YES);
            }
        });
    }];
    
    return YES;
}

@end
