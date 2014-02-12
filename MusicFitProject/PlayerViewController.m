//
//  PlayerViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DBManager.h"
#import "SwipeViewController.h"
#import "AddedModeDelegate.h"
#import "MusicFitPlayer.h"
#import "DBManager.h"

#define SOUNDVIEW_HIDDEN_X -320
#define SOUNDVIEW_MARGIN_X 0

@interface PlayerViewController () <UIAlertViewDelegate, MusicFitPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIView *soundView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *BPMLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

@property (weak, nonatomic) IBOutlet UISlider *playTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *playVolumSlider;

@end

@implementation PlayerViewController{
    DBManager *_DBManager;
    NSInteger curPlayIndex;
}

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

- (IBAction)playORpause:(id)sender {
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    BOOL isPlaying = [player isPlaying];
    if(isPlaying)
        [player pause];
    else
        [player play];
}

- (IBAction)playNext:(id)sender {
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    
    [player nextPlay];
}
- (IBAction)playPreviouse:(id)sender {
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    
    [player prevPlay];
}
- (IBAction)changePlayPoint:(id)sender {
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    
    [player changePlayPoint:self.playTimeSlider.value];
}
- (IBAction)changePlayVolume:(id)sender {
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    
    [player changePlayVolume:self.playVolumSlider.value];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    MusicFitPlayer *player= [MusicFitPlayer sharedPlayer];
    
    player.playerDelegate = self;
    [player syncData];
    [player checkCurTime];
    [player setSliderMaxDelegate];
//    [myMusicPlayer registerHandlerPlayerRateChanged:^{
//        [self syncPlayPauseButtons];
//    }CurrentItemChanged:^(AVPlayerItem *item) {
//        [self syncPlayPauseButtons];
//    } PlayerDidReachEnd:^{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Player did reach end" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }];
//    
//    [myMusicPlayer registerHandlerCurrentItemPreLoaded:^(CMTime time) {
//        NSLog(@"item buffered time : %f", CMTimeGetSeconds(time));
//    }];
//    
//    [myMusicPlayer registerHandlerReadyToPlay:^(HysteriaPlayerReadyToPlay identifier) {
//        switch (identifier) {
//            case HysteriaPlayerReadyToPlayPlayer:
//                //플레이 준비시 하는 행동을 여기에서 업데이트(UI)
//                break;
//            case HysteriaPlayerReadyToPlayCurrentItem:
//                //플레이 하기 위해 아이템이 불려졌을 때 자동으로 플레이 한다.
//                //그걸 막고 싶으면 pausePlayerForcibly:YES를 해서 멈추면 된다.
//                break;
//            default:
//                break;
//        }
//    }];
//    
//    [myMusicPlayer registerHandlerFailed:^(HysteriaPlayerFailed identifier, NSError *error) {
//        switch (identifier) {
//            case HysteriaPlayerFailedCurrentItem:
//                [myMusicPlayer playNext];
//                break;
//            case HysteriaPlayerFailedPlayer:
//                break;
//            default:
//                break;
//        }
//        NSLog(@"%@", [error localizedDescription]);
//    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSwipeController{
    SwipeViewController *swipeVC = [[SwipeViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 438)];
    [self addChildViewController:swipeVC];

    
    [self.view.subviews[1] addSubview:swipeVC.view];
    [swipeVC didMoveToParentViewController:self];
    
    UIViewController *modeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mode"];
    //    [self addChildViewController:modeViewController];
    //    [self.swipeContainerView addSubview:modeViewController.view];
    //    [modeViewController didMoveToParentViewController:self];
    modeViewController.row = 0;
    modeViewController.col = 0;
    
    UIViewController *playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"play"];
    //    [self addChildViewController:playViewController];
    //    [self.swipeContainerView addSubview:playViewController.view];
    playViewController.row = 0;
    playViewController.col = 1;
    
    UIViewController *playListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"playList"];
    //    [self addChildViewController:playListViewController];
    //    [self.swipeContainerView addSubview:playListViewController.view];
    playListViewController.row = 0;
    playListViewController.col = 2;
    
    UIViewController *myViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"my"];
    //    [self addChildViewController:myViewController];
    //    [self.swipeContainerView addSubview:myViewController.view];
    myViewController.row = 0;
    myViewController.col = 3;
    
    NSArray *controllers = @[ modeViewController, playViewController,playListViewController, myViewController];
    [swipeVC setControllers:controllers];
    
    [swipeVC moveRightAnimated:NO];
}

- (void)syncLabels:(UIImage *)albumImage music:(Music *)music{
    self.albumImageView.image = albumImage;
    
    self.titleLabel.text = music.title;
    self.artistLabel.text = music.artist;
    self.BPMLabel.text = [NSString stringWithFormat:@"%d",(int)music.BPM];
    
//    NSLog(@"%@,%@,%@,%d", albumImage, music.title, music.artist, music.BPM);
    [self.albumImageView setNeedsDisplay];
        [self.titleLabel setNeedsDisplay];
        [self.titleLabel setNeedsDisplay];
        [self.titleLabel setNeedsDisplay];
}
- (void)syncMusicProgress:(NSString *)timeString timePoint:(NSInteger)timePoint{
    self.playTimeLabel.text = timeString;
    self.playTimeSlider.value = timePoint;
}

- (void)setMusicProgressMax:(NSInteger)max{
    [self.playTimeSlider setMaximumValue:max];
//    NSLog(@"%d",(int)max);
}

- (void)initMusicProgress{
    self.playTimeSlider.value = 0;
}
@end
