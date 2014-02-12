//
//  MainViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 15..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayViewController.h"
//#import "ModeViewController.h"
//#import "AppDelegate.h"
#import "MusicFitPlayer.h"

#define CLOCKPICKERVIEW_HIDDEN_Y 600
#define CLOCKPICKERVIEW_MARGIN_Y 100
#define FITPROGRESSVIEW_HIDDEN_X -640
#define FITPROGRESSVIEW_MARGIN_X 16
@interface PlayViewController ()<FitModeImageViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *fitModeImageView;
@property (weak, nonatomic) IBOutlet UIView *clockPickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *clockPicker;
@property (weak, nonatomic) IBOutlet UIView *fitProgressView;


@end

@implementation PlayViewController{
    //시간 설정이 되어 있느냐
    BOOL _startTimer;
    //지금 음악을 듣고 있느냐
    BOOL _isPlaing;
    NSInteger _curMode;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    _startTimer = NO;
    _isPlaing = NO;
    
	// Do any additional setup after loading the view.
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    player.fitModeDelegate = self;
    _curMode = 0;
    [self setCurMode];
}
- (void)setCurMode{
    NSInteger curMode = [[DBManager sharedDBManager] getCurModeID];
    if(_curMode == curMode )
        return;
    
    if(curMode > 4)
        _curMode = 5;
    else
        _curMode = curMode;
    
    self.fitModeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img_%d_0", _curMode]];
}
- (void)viewDidAppear:(BOOL)animated{
    
    [self setCurMode];
    [super viewDidAppear:animated];
    
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showclockPcikerView:(id)sender {
    [self moveClockPickerViewWithY:CLOCKPICKERVIEW_MARGIN_Y];
}
- (IBAction)setClock:(id)sender {
    [self moveClockPickerViewWithY:CLOCKPICKERVIEW_HIDDEN_Y];
    [self moveFitProgressViewWithX:FITPROGRESSVIEW_MARGIN_X];
    
    _startTimer = YES;
    [self thread];
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
- (void)moveFitProgressViewWithX:(NSInteger)X{
    [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.fitProgressView.frame;
        frame.origin.x = X;
        self.fitProgressView.frame = frame;
    }completion:nil];
}
- (void)startFitModeAnimation{
    
}
-(void)fitModeAnimation{
    if(_startTimer && _isPlaing){
        [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
            
        }completion:^(BOOL finished){
//            [self.fitModeImageView setImage:[UIImage image:[NSString stringWithFormat:@"img_%d_0", _curMode]]];
        }];
        
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
        }completion:^(BOOL finished){
            [self.fitModeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_1", _curMode]]];
        }];
        [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveLinear animations:^{
            
        }completion:^(BOOL finished){
            [self.fitModeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_2", _curMode]]];
        }];
        [UIView animateWithDuration:1 delay:4 options:UIViewAnimationOptionCurveLinear animations:^{
           
        }completion:^(BOOL finished){
            [self.fitModeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"img_%d_3", _curMode]]];
            if (_isPlaing) {
                [self fitModeAnimation];
            }
        }];
    }
}
- (void)thread{
//    [NSThread detachNewThreadSelector:@selector(fitModeAnimation) toTarget:self withObject:nil];
    [self performSelectorInBackground:@selector(fitModeAnimation) withObject:nil];
}
-(void)stopFitModeAnimation{
//    _st
}

-(void)setWorkPlayer:(BOOL)isPlaying {
    _isPlaing = isPlaying;
//    _startTimer = isPlaying;
}
@end
