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

#define SOUNDVIEW_HIDDEN_X -320
#define SOUNDVIEW_MARGIN_X 0
#define prePath @"ipod-library://item/item.mp3?id="

@interface PlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIView *soundView;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *BPMLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

@property (weak, nonatomic) IBOutlet UISlider *playTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;

@property (strong, nonatomic) AVPlayer *player;
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
- (IBAction)playOpause:(id)sender {
    if(self.playOrPauseBtn.selected) {
        [_player pause];
        [self.playOrPauseBtn setSelected:NO];
    } else {
        [_player play];
        [self.playOrPauseBtn setSelected:YES];
    }
}
- (void)changePlayMusic:(NSInteger)selectIndex{
    if(curPlayIndex == selectIndex)
        return;
    [_player pause];
    Music *music = [_DBManager getMusicWithMusicID:[_DBManager getMusicInfoInPlayListWithIndex:selectIndex]];
    if(music == nil)
        return;
    
    NSURL *selectMusicURLPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", prePath,music.location]];
    
    AVPlayerItem * selectItem = [AVPlayerItem playerItemWithURL:selectMusicURLPath];
    
    [_player replaceCurrentItemWithPlayerItem:selectItem];
    [_player play];
    [self.playOrPauseBtn setSelected:YES];
    
    [self setControlsValue:music];
    
    
}
- (void)playListSync{
    [_DBManager syncPlayList];
    Music *music = [_DBManager getMusicWithMusicID:[_DBManager getMusicInfoInPlayListWithIndex:0]];
    if(music != nil){
        [_player pause];
        NSURL *selectMusicURLPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", prePath,music.location]];
        
        AVPlayerItem * selectItem = [AVPlayerItem playerItemWithURL:selectMusicURLPath];
        
        [_player replaceCurrentItemWithPlayerItem:selectItem];
        [_player play];
        [self.playOrPauseBtn setSelected:YES];
        
        [self setControlsValue:music];
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _player = [[AVPlayer alloc] init];
    curPlayIndex = 0;
    _DBManager = [DBManager sharedDBManager];
    
    [self playListSync];
    [_player pause];
    //6
    [self configurePlayer];
}

- (void)setControlsValue:(Music *)music{
    self.titleLabel.text = music.title;
    self.artistLabel.text = music.artist;
    self.BPMLabel.text = [NSString stringWithFormat:@"%d",(int)music.BPM];
    //image
    
    int duration = (int)CMTimeGetSeconds(_player.currentItem.duration);
    int currentTime = (int)CMTimeGetSeconds(_player.currentTime);
    int durationMin = (int)(duration / 60);
    int durationSec = (int)(duration % 60);
    int currentMins = (int)(currentTime / 60);
    int currentSec = (int)(currentTime % 60);
    
    NSString * durationLabel =[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentMins,currentSec,durationMin,durationSec];
    _playTimeLabel.text = durationLabel;
    
    [self.playTimeSlider setMaximumValue:self.player.currentItem.duration.value];
    _playTimeSlider.value = currentTime;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) configurePlayer {
    //7
    __block PlayerViewController * weakSelf = self;
    //8
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                          queue:NULL
                                     usingBlock:^(CMTime time) {
                                         if(!time.value) {
                                             return;
                                         }
                                         
                                         
                                         int duration = (int)CMTimeGetSeconds(weakSelf.player.currentItem.duration);
                                         int currentTime = (int)CMTimeGetSeconds(weakSelf.player.currentTime);
                                         int durationMin = (int)(duration / 60);
                                         int durationSec = (int)(duration % 60);
                                         int currentMins = (int)(currentTime / 60);
                                         int currentSec = (int)(currentTime % 60);
                                         
                                         
                                         NSString * durationLabel =[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentMins,currentSec,durationMin,durationSec];
                                         
                                         weakSelf.playTimeLabel.text = durationLabel;
                                         weakSelf.playTimeSlider.value = currentTime;
                                     }];
    
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
}
@end
