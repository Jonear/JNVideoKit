//
//  KSVideoMerge.h
//  JNVideoKitDemo
//
//  Created by Jonear on 12-8-30.
//  Copyright (c) 2012年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>

typedef void (^CompletionBack)(BOOL succes);

@interface JNVideoMerge : NSObject

/**
 语音和视频合成

 @param str_audio_path 语音文件路径
 @param str_video_path 视频文件路径
 @param str_merge_path 合成后导出路径
 @param block          完成回调

 @return 执行是否成功
 */
+ (BOOL)mergeAVFile:(NSString*)str_audio_path
      videoFilePath:(NSString*)str_video_path
      mergeFilePath:(NSString*)str_merge_path
         completion:(CompletionBack)block;


/**
 多个视频合成

 @param videoPathArray 多个视频路径数组
 @param str_merge_path 合成后导出路径
 @param block          完成回调

 @return 执行是否成功
 */
+ (BOOL)mergeFreeVideoFilePath:(NSArray *)videoPathArray
                 mergeFilePath:(NSString*)str_merge_path
                    completion:(CompletionBack)block;



/**
 裁剪视频

 @param videoPathArray 视频路径
 @param str_merge_path 裁剪完成后导出路径
 @param startTime      开始时间
 @param endTime        结束时间
 @param block          完成回调

 @return 执行是否成功
 */
+ (BOOL)cropVideoFilePath:(NSArray *)videoPathArray
            mergeFilePath:(NSString*)str_merge_path
                startTime:(CMTime)startTime
                  endTime:(CMTime)endTime
               completion:(CompletionBack)block;

@end
