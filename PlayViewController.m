//
//  MainViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 15..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayViewController.h"
#import "DBManager.h"
#import "MusicFitPlayer.h"
#import "TimerLabel.h"

#define CLOCKPICKERVIEW_HIDDEN_Y 600
#define CLOCKPICKERVIEW_MARGIN_Y 100
#define FITPROGRESSVIEW_HIDDEN_X -640
#define FITPROGRESSVIEW_MARGIN_X 16

#define HOUR 0
#define MINUTE 1
@interface PlayViewController ()<FitModeImageViewDelegate, TimerLabelDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *fitModeImageView;
@property (weak, nonatomic) IBOutlet UIView *clockPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *clockPicker;

@property (weak, nonatomic) IBOutlet UIView *fitProgressView;
@property (weak, nonatomic) IBOutlet UILabel *notiColockSetLabel;

@property (weak, nonatomic) IBOutlet TimerLabel *timeViewLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *fitProgress;

@end

@implementation PlayViewController{
    //시간 설정이 되어 있느냐
    BOOL _startTimer;
    NSInteger _curMode;
    TimerLabel *_timerLabel;
}
-(NSInteger )numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == HOUR)
        return 12;
    else
        return 60;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *timeCompoentLabel = [[UILabel alloc]init];
    CGRect frame = CGRectMake(0, 0, 50, 30);
    timeCompoentLabel.frame = frame;
    [timeCompoentLabel setTextAlignment:NSTextAlignmentCenter];
    if(component == HOUR){
        timeCompoentLabel.text =[NSString stringWithFormat:@"%d",row];
//        NSLog(@"row: %d, component: %d", row, component);
    }
    else{
        timeCompoentLabel.text =[NSString stringWithFormat:@"%d",row];
//        NSLog(@"row: %d, component: %d", row, component);
    }

    UIView *labelView;
    if(view == nil){
        labelView = [[UIView alloc]initWithFrame:frame];
        [labelView setBackgroundColor:[UIColor redColor]];
        [labelView addSubview:timeCompoentLabel];
        [labelView setContentMode:UIViewContentModeScaleToFill];
    }else{
        [labelView addSubview:timeCompoentLabel];
    }
    
    return labelView;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
- (void)setfitModeImage{
    self.fitModeImageView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_0", (int)_curMode]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
- (IBAction)showclockPcikerView:(id)sender {
    
    [self.clockPicker selectRow:30 inComponent:1 animated:NO];
    [self moveClockPickerViewWithY:CLOCKPICKERVIEW_MARGIN_Y];
}
- (IBAction)setClock:(id)sender {
    [self moveClockPickerViewWithY:CLOCKPICKERVIEW_HIDDEN_Y];
    [self moveFitProgressView];
    
    _startTimer = YES;
    NSInteger hour = [self.clockPicker selectedRowInComponent:HOUR];
    NSInteger minute = [self.clockPicker selectedRowInComponent:MINUTE];
    NSInteger timerTime = (hour*60*60+minute*60);
    NSLog(@"Timer Setting : %02d : %02d, total Second: %d", hour, minute, timerTime);
    [_timerLabel setCountDownTime: 10];
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    
    if(![_timerLabel running]){
//        [_btnStartCountdownExample6 setTitle:@"Pause" forState:UIControlStateNormal];
        
        [_timerLabel start];
        NSLog(@"running....");
        if([player isPlaying])
            [_timerLabel pause];
    } else {
        [_timerLabel pause];
        NSLog(@"pause....");
//        [_btnStartCountdownExample6 setTitle:@"Resume" forState:UIControlStateNormal];
    }

    
    [self startFitModeAnimation];
}
- (void)startTimer{
    
}
- (IBAction)cancelSetClock:(id)sender {
    [self moveClockPickerViewWithY:CLOCKPICKERVIEW_HIDDEN_Y];
}


- (void)moveClockPickerViewWithY:(NSInteger)Y{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.clockPickerView.frame;
        frame.origin.y = Y;
        self.clockPickerView.frame = frame;
    }completion:nil];
}
- (void)fitmodeAnimation{
    if([self.timeViewLabel fire]){
        self.fitModeImageView.animationImages =@[[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_0", _curMode]],[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_1", _curMode]],[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_2", _curMode]],[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_3", _curMode]]];
        self.fitModeImageView.animationDuration=0.8;
        self.fitModeImageView.animationRepeatCount=INFINITY;
        
        [self.fitModeImageView startAnimating];
    }
}
- (void)moveFitProgressView{
    [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.fitProgressView.frame;
        self.fitProgressView.frame = self.notiColockSetLabel.frame;
        self.notiColockSetLabel.frame = frame;
    }completion:nil];
}
- (void)startFitModeAnimation{
    [NSThread detachNewThreadSelector:@selector(fitmodeAnimation) toTarget:self withObject:nil];
}
-(void)stopFitModeAnimation{
        [self.fitModeImageView stopAnimating];
}
-(void)setWorkPlayer:(BOOL)isPlaying mode:(NSInteger)curMode{
   
    _curMode = curMode;
    [self setfitModeImage];
}
- (void)timerLabel:(TimerLabel*)timerLabel startDate:(NSDate *)startDate timerValue:(NSInteger)timerValue{
//    [_btnStartCountdownExample6 setTitle:@"Start" forState:UIControlStateNormal];
    DBManager *dbManager = [DBManager sharedDBManager];
    [dbManager insertCalendarWithExerTime:timerValue/60 startdate:startDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"KST"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSString *date = [dateFormatter stringFromDate:startDate];
    
    NSString *msg = [NSString stringWithFormat:@"Countdown finished! timer:%d startDate:%@", timerValue , date];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"Awesome!" otherButtonTitles:nil];
    
    _startTimer = NO;
    
    [self stopFitModeAnimation];
    [self moveFitProgressView];
    
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    [player pause];
    NSLog(@"timer completion");
    [alertView show];
}
-(void)checkProgressTime{
//    self.fitProgressView
}
- (void)viewDidLoad{
    [super viewDidLoad];
    _timerLabel = [TimerLabel sharedTimerSetWithLabel:self.timeViewLabel progressView:self.fitProgress];
    _timerLabel.delegate = self;
    _startTimer = NO;
    
	// Do any additional setup after loading the view.
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    player.fitModeDelegate = self;
    _curMode = [[DBManager sharedDBManager] getCurModeID];
    self.fitModeImageView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_0", (int)_curMode]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    [self setCurMode];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
@end
