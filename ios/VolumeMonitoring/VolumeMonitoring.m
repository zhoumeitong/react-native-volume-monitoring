//
//  VolumeMonitoring.m
//  VolumeMonitoring
//
//  Created by meitongzhou on 2019/3/7.
//  Copyright © 2019 meitongzhou. All rights reserved.
//

#import "VolumeMonitoring.h"
#import <AVFoundation/AVFoundation.h>

@interface VolumeMonitoring ()
{
    AVAudioRecorder *recorder;
}
@property (nonatomic, weak) NSTimer *levelTimer;
@end

@implementation VolumeMonitoring

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"VolumeMonitoring"];
}

//开始音量检测
RCT_EXPORT_METHOD(startVolumeMonitoring)
{
    if (_isMonitoring) {
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    /* 不需要保存录音文件 */
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (recorder)
    {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        dispatch_async(dispatch_get_main_queue(), ^{//这里NSTimer的使用要放在主线程中，否则不调用
            self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.3 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        });
        _isMonitoring = YES;
    }
    else
    {
        NSLog(@"%@", [error description]);
        [self sendEventWithName:@"VolumeMonitoring" body:@{@"error": [error description]}];
        _isMonitoring = NO;
    }
}

/* 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究 */
- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -60.0f; // use -80db Or use -60dB, which I measured in a silent room.
    float   decibels    = [recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 5.0f; //modified level from 2.0 to 5.0 is neast to real test
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    NSLog(@"voice updated :%f",level * 120);
    NSString *volume = [NSString stringWithFormat:@"%f",level * 120];
    [self sendEventWithName:@"VolumeMonitoring" body:@{@"volume": volume}];
}

//取消音量检测
RCT_EXPORT_METHOD(cancleVolumeMonitoring)
{
    if (_isMonitoring) {
        //取消定时器
        [self.levelTimer invalidate];
        self.levelTimer = nil;
        _isMonitoring = NO;
    }
}

- (void)dealloc
{
    //取消定时器
    [self.levelTimer invalidate];
    self.levelTimer = nil;
    _isMonitoring = NO;
}

@end
