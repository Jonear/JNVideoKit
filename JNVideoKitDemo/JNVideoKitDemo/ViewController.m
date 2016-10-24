//
//  ViewController.m
//  JNVideoKitDemo
//
//  Created by NetEase on 16/10/24.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "ViewController.h"
#import "JNVideoRecord.h"
#import "JNVideoPlayer.h"

@interface ViewController ()

@end

@implementation ViewController {
    GPUImageView *_imageView;
    JNVideoRecord *_videoRecord;
    JNVideoPlayer *_videoPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 320)];
    [self.view addSubview:_imageView];

    // video Record
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"recordFile/a.mp4"];
//    _videoRecord = [[JNVideoRecord alloc] init];
//    [_videoRecord initVideoCapture:_imageView path:strpath];
//    [_videoRecord setFilterModel:IF_EARLYBIRD_FILTER];
//    [_videoRecord startVideoCapture];

    // video Player
    _videoPlayer = [[JNVideoPlayer alloc] init];
    NSURL *videoUrl = [NSURL URLWithString:@"http://115.231.22.25/v.cctv.com/flash/mp4video6/TMS/2011/01/05/cf752b1c12ce452b3040cab2f90bc265_h264818000nero_aac32-1.mp4?wshc_tag=0&wsts_tag=56e4fbf8&wsid_tag=7b3abf44&wsiphost=ipdbm"];
    [_videoPlayer initVideoPlayer:_imageView videoFilePath:videoUrl];
    [_videoPlayer play];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
