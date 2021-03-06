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
#import "CustomProgressBar.h"

#define CLOCKPICKERVIEW_HIDDEN_Y 600
#define CLOCKPICKERVIEW_MARGIN_Y 80
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
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet TimerLabel *timeViewLabel;
@property (weak, nonatomic) IBOutlet CustomProgressBar *progressBar;

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
        return 7;
    else
        return 60;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *timeCompoentLabel = [[UILabel alloc]init];
    CGRect frame = CGRectMake(0, 0, 50, 30);
    timeCompoentLabel.frame = frame;
    [timeCompoentLabel setTextAlignment:NSTextAlignmentLeft];
    if(component == HOUR){
        timeCompoentLabel.text =[NSString stringWithFormat:@"%d",(int)row];
//        NSLog(@"row: %d, component: %d", row, component);
    }
    else{
        timeCompoentLabel.text =[NSString stringWithFormat:@"%d",(int)row];
//        NSLog(@"row: %d, component: %d", row, component);
    }

    UIView *labelView;
    if(view == nil){
        labelView = [[UIView alloc]initWithFrame:frame];
        [labelView setBackgroundColor:[UIColor clearColor]];
        [labelView addSubview:timeCompoentLabel];
        [labelView setContentMode:UIViewContentModeCenter];
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
    
    [self.startBtn setSelected:!self.startBtn.selected];
    if(!self.startBtn.selected){
        [_timerLabel stop];
        return;
    }
    [self moveFitProgressView:YES];
    
    
    
    _startTimer = YES;
    NSInteger hour = [self.clockPicker selectedRowInComponent:HOUR];
    NSInteger minute = [self.clockPicker selectedRowInComponent:MINUTE];
    NSInteger timerTime = (hour*60*60+minute*60);
    NSLog(@"Timer Setting : %02d : %02d, total Second: %d", (int)hour, (int)minute, (int)timerTime);
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    
    //재생중인데 파이어 아니었음 -> 애니매이션도 처리해야함
    if([player isPlaying] == YES && ![_timerLabel fire]){
        [_timerLabel setCountDownTime: timerTime];
        [_timerLabel start];
        [self startFitModeAnimation];
        NSLog(@"running....");
    //플레이중이 아니면 그냥 시작했다 정지시킴
    }else if(![player isPlaying] && ![_timerLabel fire]){
        [_timerLabel setCountDownTime: timerTime];
        [_timerLabel start];
        [_timerLabel pause];
    }
    //재생중에 파이어 다시 하면 ?!?! -> 카운트 다운 추가해야함.
    
//    if(![_timerLabel fire]){
//        [_timerLabel pause];
//        NSLog(@"pause....");
//        [_btnStartCountdownExample6 setTitle:@"Resume" forState:UIControlStateNormal];
//    }

    
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
- (void)moveFitProgressView:(BOOL)animated{
    if(animated){
        [UIView animateWithDuration:0.1 delay:0 options:  UIViewAnimationOptionCurveLinear animations:^{
            CGRect frame = self.fitProgressView.frame;
            self.fitProgressView.frame = self.notiColockSetLabel.frame;
            self.notiColockSetLabel.frame = frame;
        }completion:nil];
    }else{
        [UIView animateWithDuration:0 delay:1 options:  UIViewAnimationOptionCurveLinear animations:^{
        }completion:^(BOOL finished) {
            CGRect frame = self.fitProgressView.frame;
            self.fitProgressView.frame = self.notiColockSetLabel.frame;
            self.notiColockSetLabel.frame = frame;
        }];
    }
}
- (void)startFitModeAnimation{
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
//    [NSThread detachNewThreadSelector:@selector(fitmodeAnimation) toTarget:self withObject:nil];
    if([_timerLabel fire] && [player isPlaying]){
        self.fitModeImageView.animationImages =@[[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_0", (int)_curMode]],[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_1", (int)_curMode]],[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_2", (int)_curMode]],[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_3", (int)_curMode]]];
        self.fitModeImageView.animationDuration=0.8;
        self.fitModeImageView.animationRepeatCount=INFINITY;
        
        [self.fitModeImageView startAnimating];
    }
}
-(void)stopFitModeAnimation{
        [self.fitModeImageView stopAnimating];
}
-(void)setWorkPlayer:(BOOL)isPlaying mode:(NSInteger)curMode{
   if(curMode > 4)
       curMode = 5;
    _curMode = curMode;
    [self setfitModeImage];
}
- (void)timerLabel:(TimerLabel*)timerLabel startDate:(NSDate *)startDate timerValue:(NSInteger)timerValue{
//    [_btnStartCountdownExample6 setTitle:@"Start" forState:UIControlStateNormal];
    self.startBtn.selected = NO;
    DBManager *dbManager = [DBManager sharedDBManager];
    [dbManager insertCalendarWithExerTime:timerValue/60 startdate:startDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"KST"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSString *date = [dateFormatter stringFromDate:startDate];
    
//    NSString *msg = [NSString stringWithFormat:@"Countdown finished! timer:%d startDate:%@", (int)timerValue , date];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"Awesome!" otherButtonTitles:nil];
    
    _startTimer = NO;
    [self.progressBar setProgress:0.0f];
    [self stopFitModeAnimation];
    [self moveFitProgressView:NO];
    
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    [player pause];
    NSLog(@"timer completion");
//    [alertView show];
}
-(void)checkProgressTime{
//    self.fitProgressView
}

//FIXME:운동시간 배경색 고치기
- (void)initRoundedSlimProgressBar{
    NSArray *tintColors = @[
                            [UIColor colorWithRed:224/255.0f green:70/255.0f blue:113/255.0f alpha:1.0f],
                            [UIColor colorWithRed:184/255.0f green:119/255.0f blue:154/255.0f alpha:1.0f],
                            [UIColor colorWithRed:185/255.0f green:185/255.0f blue:199/255.0f alpha:1.0f],
                            [UIColor colorWithRed:119/255.0f green:168/255.0f blue:201/255.0f alpha:1.0f],
                            [UIColor colorWithRed:58/255.0f green:194/255.0f blue:232/255.0f alpha:1.0f]];
    
    self.progressBar.progressTintColors = tintColors;
    self.progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeTrack;
    
    self.progressBar.stripesColor             = [UIColor clearColor];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    CGAffineTransform t0 = CGAffineTransformMakeTranslation (0, self.clockPicker.bounds.size.height/2);
    CGAffineTransform s0 = CGAffineTransformMakeScale       (1.0, 0.8);
    CGAffineTransform t1 = CGAffineTransformMakeTranslation (0, -self.clockPicker.bounds.size.height/2);
    self.clockPicker.transform = CGAffineTransformConcat          (t0, CGAffineTransformConcat(s0, t1));
    
    [self initRoundedSlimProgressBar];
    _timerLabel = [TimerLabel sharedTimerSetWithLabel:self.timeViewLabel progressView:self.progressBar];
    _timerLabel.delegate = self;
    _startTimer = NO;
    
	// Do any additional setup after loading the view.
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    player.fitModeDelegate = self;
    _curMode = [[DBManager sharedDBManager] getCurModeID];
    if(_curMode > 4)
        _curMode = 5;
    self.fitModeImageView.image = [[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_0", (int)_curMode]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
@end
