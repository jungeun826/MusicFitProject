//
//  PlayerViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CalendarViewController.h"

#import "DBManager.h"
#import "SwipeViewController.h"
#import "AddedModeDelegate.h"
#import "MusicFitPlayer.h"
#import "DBManager.h"
#import "TimerLabel.h"

#define SOUNDVIEW_HIDDEN_X -320
#define SOUNDVIEW_MARGIN_X 0

@interface PlayerViewController () <UIAlertViewDelegate, MusicFitPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *playCurProgressImg;

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
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (nonatomic, strong) MPVolumeView *volumeView;
@end

@implementation PlayerViewController{
    DBManager *_DBManager;
    NSInteger curPlayIndex;
//    TimerLabel *_timer;
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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)playORpause:(id)sender {
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    BOOL isPlaying = [player isPlaying];
    TimerLabel *timer = [TimerLabel sharedTimer];
    if(isPlaying){
        self.playBtn.selected = !self.playBtn.selected;
        [player pause];
        //정지임
        if([timer fire] && [timer running])
            [timer pause];
    }
    else{
        self.playBtn.selected = !self.playBtn.selected;
        [player play];
        //플레이임
        if([timer fire] && ![timer running])
            [timer start];
    }
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
    [self changePlaySliderImagePoint];
}
- (IBAction)changePlayVolume:(id)sender {
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    
    [player changePlayVolume:self.playVolumSlider.value];
}
- (void)addVolumeView{
    self.volumeView = [[MPVolumeView alloc] init];
    
    [self.volumeView setShowsVolumeSlider:YES];
    [self.volumeView setShowsRouteButton:NO];
    
    CGRect frame = self.volumeView.frame;
    frame.origin.x = 71;
    frame.origin.y = 10;
    frame.size.width = 238;
    self.volumeView.frame = frame;
//
    UIImage *thumbImage = [UIImage imageNamed:@"play_volume_control.png"] ;

    CGSize size = CGSizeMake(20, 20);
    UIGraphicsBeginImageContext(size);
    [thumbImage drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* thumbResizeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
//
    [self.volumeView setVolumeThumbImage:thumbResizeImage forState:UIControlStateSelected];

    [self.volumeView setVolumeThumbImage:thumbResizeImage forState:UIControlStateNormal];


    [self.soundView addSubview:self.volumeView];
    self.volumeView.userInteractionEnabled = YES;
    self.soundView.backgroundColor = [UIColor redColor];
    NSLog(@"sound view : %@", NSStringFromCGRect(self.soundView.frame));
    [self.volumeView sizeToFit];
}
- (void)changeSettingPlayTimeSlider{
    CGSize size = self.playTimeSlider.frame.size;

    [self.playTimeSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.playTimeSlider setMinimumTrackTintColor:[UIColor clearColor]];
    UIImage *tempImage = [UIImage imageNamed:@"play_control.png"] ;
    
    size = CGSizeMake(20, 20);
    
    UIGraphicsBeginImageContext(size);
    [tempImage drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.playTimeSlider setThumbImage:resizeImage forState:UIControlStateNormal];
    [self.playTimeSlider setThumbImage:resizeImage forState:UIControlStateSelected];
    
//    /Users/sdt-1/Documents/Projects/MusicFitProject/images/play_volume_control.png
    [self.playTimeSlider sizeToFit];
}
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    MusicFitPlayer *player= [MusicFitPlayer sharedPlayer];
    [self changeSettingPlayTimeSlider];
    [self addVolumeView];
    
    player.playerDelegate = self;
    [player setAudioSession];
    [player syncLabel];
    [player checkCurTime];
    [player callSliderMaxDelegate];
    
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
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [super viewWillDisappear:animated];
}
- (void)setSwipeController{
    SwipeViewController *swipeVC = [[SwipeViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 438)];
    
    [self addChildViewController:swipeVC];
    
    [self.view.subviews[1] addSubview:swipeVC.view];
    [swipeVC didMoveToParentViewController:self];
    
    UIViewController *modeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mode"];
    modeViewController.row = 0;
    modeViewController.col = 0;
    
    UIViewController *playViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"play"];
    playViewController.row = 0;
    playViewController.col = 1;
    
    UIViewController *playListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"playList"];
    playListViewController.row = 0;
    playListViewController.col = 2;
    
    UIViewController *calendarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"calendar"];
    calendarViewController.row = 0;
    calendarViewController.col = 3;
    
    NSArray *controllers = @[ modeViewController, playViewController,playListViewController, calendarViewController];
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
    
    [self changePlaySliderImagePoint];
}
- (void)changePlaySliderImagePoint{
    float rate = (float)(self.playTimeSlider.value / self.playTimeSlider.maximumValue);
    
    self.playCurProgressImg.frame = CGRectMake(8, 14 , 217*rate , 8);
}
- (void)setMusicProgressMax:(NSInteger)max{
    [self.playTimeSlider setMaximumValue:max];
//    NSLog(@"%d",(int)max);
}

- (void)initMusicProgress{
    self.playTimeSlider.value = 0;
}

- (void)showPlayerWithDuration:(CGFloat)duration{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.playerView.frame;
        frame.origin.x = 0;
        self.playerView.frame = frame;
    }completion:nil];
}
- (void)hiddenPlayerWithDuration:(CGFloat)duration{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.playerView.frame;
        frame.origin.x = -320;
        self.playerView.frame = frame;
    }completion:nil];
}
- (void)changePlayBtnSelected:(BOOL)selected{
    self.playBtn.selected = selected;
}
@end
