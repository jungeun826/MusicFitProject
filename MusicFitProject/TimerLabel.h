//
//  TimerLabel.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 13..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimerLabel;
@protocol TimerLabelDelegate <NSObject>
@optional
-(void)timerLabel:(TimerLabel*)timerLabel;
@end

@interface TimerLabel : UILabel
@property (strong) id<TimerLabelDelegate> delegate;

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (assign,readonly) BOOL running;
@property (assign,readonly) BOOL fire;
+ (id)sharedTimerSetWithLabel:(UILabel *)theLabel progressView:(UIProgressView *)progressView;
+ (id)sharedTimer;
//- (id)initWithLabel:(UILabel *)theLabel progressView:(UIProgressView *)progressView;

/*--------Timer control methods to use*/
-(void)start;
-(void)pause;
-(void)reset;

/*--------Setter methods*/
-(void)setCountDownTime:(NSTimeInterval)time;

@end
