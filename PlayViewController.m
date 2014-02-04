//
//  MainViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 15..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayViewController.h"
#import "ModeViewController.h"
#import "AppDelegate.h"

#define CLOCKPICKERVIEW_HIDDEN_Y 600
#define CLOCKPICKERVIEW_MARGIN_Y 100
#define FITPROGRESSVIEW_HIDDEN_X -640
#define FITPROGRESSVIEW_MARGIN_X 16
@interface PlayViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *fitModeImageView;
@property (weak, nonatomic) IBOutlet UIView *clockPickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *clockPicker;
@property (weak, nonatomic) IBOutlet UIView *fitProgressView;


@end

@implementation PlayViewController
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
	// Do any additional setup after loading the view.
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
@end
