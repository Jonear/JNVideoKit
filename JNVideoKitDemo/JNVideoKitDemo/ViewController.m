//
//  ViewController.m
//  JNVideoKitDemo
//
//  Created by Jonear on 16/10/24.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import "ViewController.h"
#import "JNVideoRecord.h"
#import "JNVideoPlayer.h"
#import "JNVideoMerge.h"

@interface ViewController ()

@end

@implementation ViewController {
    GPUImageView *_imageView;
    JNVideoRecord *_videoRecord;
    JNVideoPlayer *_videoPlayer;
    
    UIButton *_demoButton;
    NSString *_strpath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 320)];
    [self.view addSubview:_imageView];

    // video Record
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"a.mp4"];
    _videoRecord = [[JNVideoRecord alloc] init];
    [_videoRecord initVideoCapture:_imageView path:_strpath];
    [_videoRecord setFilterModel:IF_EARLYBIRD_FILTER];
    [_videoRecord startVideoCapture];
    
    _demoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 100, 100)];
    [_demoButton setCenter:CGPointMake(self.view.bounds.size.width/2, _demoButton.center.y)];
    [_demoButton.layer setCornerRadius:50];
    [_demoButton.layer setMasksToBounds:YES];
    [_demoButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_demoButton setBackgroundColor:[UIColor redColor]];
    [_demoButton setTitle:@"record" forState:UIControlStateNormal];
    [self.view addSubview:_demoButton];

    // video Player
    _videoPlayer = [[JNVideoPlayer alloc] init];
//    NSURL *videoUrl = [NSURL URLWithString:@"http://115.231.22.25/v.cctv.com/flash/mp4video6/TMS/2011/01/05/cf752b1c12ce452b3040cab2f90bc265_h264818000nero_aac32-1.mp4?wshc_tag=0&wsts_tag=56e4fbf8&wsid_tag=7b3abf44&wsiphost=ipdbm"];
//    [_videoPlayer initVideoPlayer:_imageView videoFilePath:videoUrl];
//    [_videoPlayer play];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClick:(UIButton *)sender {
    NSString *title = [sender titleForState:UIControlStateNormal];
    
    if ([title isEqualToString:@"record"]) {
        [sender setTitle:@"stop record" forState:UIControlStateNormal];
        [_videoRecord startVideoRecord];
    } else if ([title isEqualToString:@"stop record"]) {
        [sender setTitle:@"play" forState:UIControlStateNormal];
        [_videoRecord stopVideoCapture];
    
        [_videoPlayer initVideoPlayer:_imageView videoFilePath:[NSURL fileURLWithPath:_strpath]];
        
        // notification
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinishNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:_videoPlayer.playerItem];
    } else if ([title isEqualToString:@"play"]) {
        [sender setTitle:@"stop play" forState:UIControlStateNormal];
        
        [_videoPlayer play];
    } else if ([title isEqualToString:@"stop play"]) {
        [sender setTitle:@"play" forState:UIControlStateNormal];
        
        [_videoPlayer pause];
    } else if ([title isEqualToString:@"crop"]) {
        // crop
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *outpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"b.mp4"];
        
        NSLog(@"~~~~~~~croping");
        CMTime time = CMTimeMake([_videoPlayer duration]/2*[_videoPlayer timeScale], [_videoPlayer timeScale]);
        [JNVideoMerge cropVideoFilePath:_strpath
                          mergeFilePath:outpath
                              startTime:time
                             lengthTime:time
                             completion:^(BOOL succes) {
                                 NSLog(@"~~~~~~~crop success:%zd, path:%@", succes, outpath);
                                 [_videoPlayer initVideoPlayer:_imageView videoFilePath:[NSURL fileURLWithPath:outpath]];
                                 
                                 // removeObserver
                                 [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                                 [_videoPlayer play];
                                 
                                 [sender setTitle:@"finish" forState:UIControlStateNormal];
                             }];
    }
}

- (void)playFinishNotification:(id)sender {
    [_demoButton setTitle:@"crop" forState:UIControlStateNormal];
}


@end
