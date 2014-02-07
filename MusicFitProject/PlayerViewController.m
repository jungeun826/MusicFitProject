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
#import "MyMusicPlayer.h"
#import "DBManager.h"

#define SOUNDVIEW_HIDDEN_X -320
#define SOUNDVIEW_MARGIN_X 0

@interface PlayerViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIView *soundView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *BPMLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

@property (weak, nonatomic) IBOutlet UISlider *playTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;

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
    MyMusicPlayer *myMusicPlayer = [MyMusicPlayer sharedPlayer];
    
    if ([myMusicPlayer isPlaying]){
        [myMusicPlayer pausePlayerForcibly:YES];
        [myMusicPlayer pause];
    }else{
        [myMusicPlayer pausePlayerForcibly:NO];
        [myMusicPlayer play];
    }
}

//- (void)changePlayMusic:(NSInteger)selectIndex{
//    if(curPlayIndex == selectIndex)
//        return;
//    [_player pause];
//    Music *music = [_DBManager getMusicWithMusicID:[_DBManager getMusicInfoInPlayListWithIndex:selectIndex]];
//    if(music == nil)
//        return;
//    
//    NSURL *selectMusicURLPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", prePath,music.location]];
//    
//    AVPlayerItem * selectItem = [AVPlayerItem playerItemWithURL:selectMusicURLPath];
//    
//    [_player replaceCurrentItemWithPlayerItem:selectItem];
//    [_player play];
//    [self.playBtn setSelected:YES];
//    
//    [self setControlsValue:music];
//    
//    
//}
//- (void)playListSync{
//    [_DBManager syncPlayList];
//    Music *music = [_DBManager getMusicWithMusicID:[_DBManager getMusicInfoInPlayListWithIndex:0]];
//    if(music != nil){
//        [_player pause];
//        NSURL *selectMusicURLPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", prePath,music.location]];
//        
//        AVPlayerItem * selectItem = [AVPlayerItem playerItemWithURL:selectMusicURLPath];
//        
//        [_player replaceCurrentItemWithPlayerItem:selectItem];
//        [_player play];
//        [self.playBtn setSelected:YES];
//        
//        [self setControlsValue:music];
//    }
//}
- (IBAction)playNext:(id)sender {
    MyMusicPlayer *myMusicPlayer = [MyMusicPlayer sharedPlayer];
    
    [myMusicPlayer playNext];
}
- (IBAction)playPreviouse:(id)sender {
    MyMusicPlayer *myMusicPlayer = [MyMusicPlayer sharedPlayer];
    
    [myMusicPlayer playPrevious];
}
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    MyMusicPlayer *myMusicPlayer = [MyMusicPlayer sharedPlayer];
    
    [myMusicPlayer registerHandlerPlayerRateChanged:^{
        [self syncPlayPauseButtons];
    }CurrentItemChanged:^(AVPlayerItem *item) {
        [self syncPlayPauseButtons];
    } PlayerDidReachEnd:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Player did reach end" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
    
    [myMusicPlayer registerHandlerCurrentItemPreLoaded:^(CMTime time) {
        NSLog(@"item buffered time : %f", CMTimeGetSeconds(time));
    }];
    
    [myMusicPlayer registerHandlerReadyToPlay:^(HysteriaPlayerReadyToPlay identifier) {
        switch (identifier) {
            case HysteriaPlayerReadyToPlayPlayer:
                //플레이 준비시 하는 행동을 여기에서 업데이트(UI)
                break;
            case HysteriaPlayerReadyToPlayCurrentItem:
                //플레이 하기 위해 아이템이 불려졌을 때 자동으로 플레이 한다.
                //그걸 막고 싶으면 pausePlayerForcibly:YES를 해서 멈추면 된다.
                break;
            default:
                break;
        }
    }];
    
    [myMusicPlayer registerHandlerFailed:^(HysteriaPlayerFailed identifier, NSError *error) {
        switch (identifier) {
            case HysteriaPlayerFailedCurrentItem:
                [myMusicPlayer playNext];
                break;
            case HysteriaPlayerFailedPlayer:
                break;
            default:
                break;
        }
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)syncPlayPauseButtons{
    MyMusicPlayer *myMusicPlayer = [MyMusicPlayer sharedPlayer];
    
    
    switch ([myMusicPlayer getHysteriaPlayerStatus]) {
        case HysteriaPlayerStatusUnknown:
//            
//            [playBtn replaceObjectAtIndex:3 withObject:mRefresh];
            break;
        case HysteriaPlayerStatusForcePause:
            self.playBtn.imageView.image = [UIImage imageNamed:@"play_play.png"];
            break;
        case HysteriaPlayerStatusBuffering:
            self.playBtn.imageView.image = [UIImage imageNamed:@"play_play.png"];
            break;
        case HysteriaPlayerStatusPlaying:
            self.playBtn.imageView.image = [UIImage imageNamed:@"play_play.png"];
        default:
            break;
    }
}

- (void)setControlsValue:(Music *)music{
    self.titleLabel.text = music.title;
    self.artistLabel.text = music.artist;
    self.BPMLabel.text = [NSString stringWithFormat:@"%d",(int)music.BPM];
    //image
    MyMusicPlayer *myMusicPlayer = [MyMusicPlayer sharedPlayer];
    
    int duration = (int)CMTimeGetSeconds([myMusicPlayer getCurrentItem].duration);
    int currentTime = (int)CMTimeGetSeconds([myMusicPlayer getCurrentItem].currentTime);
    
    int durationMin = (int)(duration / 60);
    int durationSec = (int)(duration % 60);
    int currentMins = (int)(currentTime / 60);
    int currentSec = (int)(currentTime % 60);
    
    NSString * durationLabel =[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentMins,currentSec,durationMin,durationSec];
    _playTimeLabel.text = durationLabel;
    
    [self.playTimeSlider setMaximumValue:duration];
    _playTimeSlider.value = currentTime;
}
-(void) configurePlayer {
    //7
    __block PlayerViewController * weakSelf = self;
//    __block _
    //8
    MyMusicPlayer *myMusicPlayer = [MyMusicPlayer sharedPlayer];

    __block AVQueuePlayer *_player = myMusicPlayer.audioPlayer;
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                          queue:NULL
                                     usingBlock:^(CMTime time) {
                                         if(!time.value) {
                                             return;
                                         }
                                         
                                         
                                         int duration = (int)CMTimeGetSeconds(_player.currentItem.duration);
                                         int currentTime = (int)CMTimeGetSeconds(_player.currentTime);
                                         int durationMin = (int)(duration / 60);
                                         int durationSec = (int)(duration % 60);
                                         int currentMins = (int)(currentTime / 60);
                                         int currentSec = (int)(currentTime % 60);
                                         
                                         
                                         NSString * durationLabel =[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentMins,currentSec,durationMin,durationSec];
                                         
                                         weakSelf.playTimeLabel.text = durationLabel;
                                         weakSelf.playTimeSlider.value = currentTime;
                                     }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSwipeController{
    SwipeViewController *swipeVC = [[SwipeViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 438)];
    [self addChildViewController:swipeVC];

    [self.view.subviews[0] addSubview:swipeVC.view];
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
@end
