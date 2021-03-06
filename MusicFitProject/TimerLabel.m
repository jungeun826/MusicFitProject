//
//  TimerLabel.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 13..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "TimerLabel.h"
#import "CustomProgressBar.h"
#define TimeFormat  @"HH:mm:ss"

#define FireInterval  0.1


@interface TimerLabel(){
    NSTimeInterval timerValue;
    NSDate *startCountDate;
    NSDate *pausedTime;
    NSDate *date1970;
    NSDate *timeToCountOff;
    BOOL _stop;
}

@property (strong) NSTimer *timer;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
- (void)setup;
- (void)updateLabel;
@end

@implementation TimerLabel
static TimerLabel *_timerInstance;
+ (id)sharedTimerSetWithLabel:(UILabel *)theLabel progressView:(CustomProgressBar *)progressView{
    if(_timerInstance == nil){
        _timerInstance = [[TimerLabel alloc]initWithLabel:theLabel progressView:progressView];
    }
    return _timerInstance;
}
+ (id)sharedTimer{
    return _timerInstance;
}
- (id)initWithLabel:(UILabel *)theLabel progressView:(CustomProgressBar *)progressView{
    self = [super init];
    
    if(self){
        self.timeLabel = theLabel;
        self.progressView = progressView;
        _fire = NO;
        _running = NO;
        [self setup];
    }
    return self;
}

#pragma mark - Getter and Setter Method
- (void)setCountDownTime:(NSTimeInterval)time{
    _fire = YES;
    timerValue = time;
    timeToCountOff = [date1970 dateByAddingTimeInterval:0];
    [self updateLabel];
}
- (void)setExtendTime:(NSTimeInterval)time{
    timerValue += time;
    [self updateLabel];
}

- (NSDateFormatter*)dateFormatter{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        _dateFormatter.dateFormat = TimeFormat;
    }
    return _dateFormatter;
}

- (UILabel*)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = self;
    }
    return _timeLabel;
}

#pragma mark - Timer Control Method


-(void)start{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:FireInterval target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    if(startCountDate == nil){
        startCountDate = [NSDate date];
        
    }
    if(pausedTime != nil){
        NSTimeInterval countedTime = [pausedTime timeIntervalSinceDate:startCountDate];
        startCountDate = [[NSDate date] dateByAddingTimeInterval:-countedTime];
        pausedTime = nil;
    }
    _fire = YES;
    _running = YES;
    [_timer fire];
}
- (void)stop{
    _stop = YES;
    [self updateLabel];
}
-(void)pause{
    [_timer invalidate];
    _timer = nil;
    _running = NO;
    pausedTime = [NSDate date];
}

-(void)reset{
    pausedTime = nil;
    _fire = NO;
    startCountDate = nil;
    _running = NO;
    [self updateLabel];
}


#pragma mark - Private method

-(void)setup{
    date1970 = [NSDate dateWithTimeIntervalSince1970:0];
    [self updateLabel];
}


-(void)updateLabel{
    
    NSTimeInterval timeDiff = [[[NSDate alloc] init] timeIntervalSinceDate:startCountDate];
    NSDate *timeToShow = [NSDate date];
    
    
    /***MZTimerLabelTypeTimer Logic***/
    if (_running) {
        if(abs(timeDiff) >= timerValue || _stop){
            [self pause];
            timeToShow = [date1970 dateByAddingTimeInterval:0];
            
            [self.progressView setProgress:0.0f animated:NO];
            if (_stop) {
                if([_delegate respondsToSelector:@selector(timerLabel:startDate:timerValue:)]){
                    [_delegate timerLabel:self startDate:startCountDate timerValue:timeDiff];
                    [self reset];
                }
            }else{
            if([_delegate respondsToSelector:@selector(timerLabel:startDate:timerValue:)]){
                [_delegate timerLabel:self startDate:startCountDate timerValue:timerValue];
                [self reset];
            }
            }
            pausedTime = nil;
            startCountDate = nil;
            _stop = NO;
        }else{
            
            timeToShow = [timeToCountOff dateByAddingTimeInterval:(timeDiff)]; //added 0.999 to make it actually counting the whole first second
        }
    }else{
        timeToShow = timeToCountOff;
    }
    
    
    
    NSString *strDate = [self.dateFormatter stringFromDate:timeToShow];
    self.timeLabel.text = strDate;
    float value = (float)(timeDiff/timerValue);
    if(!isnan(value))
        [self.progressView setProgress:value animated:YES];
}
@end
