//
//  TimerLabel.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 13..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimerLabel;
@class CustomProgressBar;

@protocol TimerLabelDelegate <NSObject>
@optional
-(void)timerLabel:(TimerLabel*)timerLabel startDate:(NSDate *)startDate timerValue:(NSInteger)timerValue;
@end

@interface TimerLabel : UILabel
@property (strong) id<TimerLabelDelegate> delegate;

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic, strong) CustomProgressBar *progressView;
@property (assign,readonly) BOOL running;
@property (assign,readonly) BOOL fire;
+ (id)sharedTimerSetWithLabel:(UILabel *)theLabel progressView:(CustomProgressBar *)progressView;
+ (id)sharedTimer;
//- (id)initWithLabel:(UILabel *)theLabel progressView:(UIProgressView *)progressView;

/*--------Timer control methods to use*/
-(void)start;
-(void)pause;
-(void)reset;
- (void)stop;
/*--------Setter methods*/
-(void)setCountDownTime:(NSTimeInterval)time;

@end
