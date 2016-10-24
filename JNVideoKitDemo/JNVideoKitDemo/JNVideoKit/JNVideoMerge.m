//
//  KSVideoMerge.m
//  JNVideoKitDemo
//
//  Created by Jonear on 12-8-30.
//  Copyright (c) 2012年 Jonear. All rights reserved.
//

#import "JNVideoMerge.h"
#import <AVFoundation/AVFoundation.h>

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


+ (BOOL)cropVideoFilePath:(NSArray *)videoPathArray
            mergeFilePath:(NSString*)str_merge_path
                startTime:(CMTime)startTime
                  endTime:(CMTime)endTime
               completion:(CompletionBack)block {
    
    return YES;
}

@end
