//
//  PlayerViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayerViewController.h"
#define SOUNDVIEW_HIDDEN_X -320
#define SOUNDVIEW_MARGIN_X 0

@interface PlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *soundView;

@end

@implementation PlayerViewController
- (IBAction)changeVolume:(id)sender {
    [self changePositionSoundViewWithX:SOUNDVIEW_MARGIN_X];
}
- (IBAction)hideVolumeSettingView:(id)sender {
    [self changePositionSoundViewWithX:SOUNDVIEW_HIDDEN_X];
}
- (void)changePositionSoundViewWithX:(NSInteger)X{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.soundView.frame = CGRectMake( X, self.soundView.frame.origin.y, self.soundView.frame.size.width, self.soundView.frame.size.height);
        }completion:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
