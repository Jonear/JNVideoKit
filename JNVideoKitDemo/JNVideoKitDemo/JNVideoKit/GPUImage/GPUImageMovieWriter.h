#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImageOpenGLESContext.h"

@interface GPUImageMovieWriter : NSObject <GPUImageInput>
{
    CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;

    NSURL *movieURL;
	AVAssetWriter *assetWriter;
//	AVAssetWriterInput *assetWriterAudioIn;
	AVAssetWriterInput *assetWriterVideoInput;
    AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;
	dispatch_queue_t movieWritingQueue;
    
    CGSize videoSize;
    NSString *fileType;
}

// Initialization and teardown
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize;
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize fileType:(NSString *)newFileType outputSettings:(NSMutableDictionary *)outputSettings;

// Movie recording
- (void)startRecording;
- (void)startRecording:(BOOL)isDelay;
- (void)finishRecording;

- (NSTimeInterval)getRecordTime;

@end
