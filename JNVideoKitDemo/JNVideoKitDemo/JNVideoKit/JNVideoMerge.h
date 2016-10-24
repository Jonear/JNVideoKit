//
//  KSVideoMerge.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+(BOOL)mergeAVFile:(NSString*)str_audio_path
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
+(BOOL)mergeFreeVideoFilePath:(NSArray *)videoPathArray
                mergeFilePath:(NSString*)str_merge_path
                   completion:(CompletionBack)block;

@end
