//
//  PlayerViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import "PlayListDBManager.h"
#import "DBManager.h"
#define SOUNDVIEW_HIDDEN_X -320
#define SOUNDVIEW_MARGIN_X 0
#define prePath @"ipod-library://item/item.mp3?id="
@interface PlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *soundView;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *BPMLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

//@property (weak, nonatomic) IBOutlet UISlider *playTimeSlider;
//@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;

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
- (void)refresh{
    [_DBManager syncPlayList];
    Music *music = [_DBManager getMusicWithMusicID:[_DBManager getMusicInfoInPlayListWithIndex:curPlayIndex]];
    if(music != nil){
        [self setLabels:music];
//        [self.playTimeSlider setMaximumValue:self.player.currentItem.duration.value];
        
        [self configurePlayer];
        //원하는 음악 정보를 가져오도록 predicates를 사용해보자.
        //MPMediaQuery *everything = [[MPMediaQuery alloc] initWithFilterPredicates:<#(NSSet *)#>];
        NSURL *musicURLPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", prePath,music.location]];
        AVPlayerItem * currentItem = [AVPlayerItem playerItemWithURL:musicURLPath];
        [_player replaceCurrentItemWithPlayerItem:currentItem];
        [_player play];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _player = [[AVPlayer alloc] init];
    curPlayIndex = 0;
    _DBManager = [DBManager sharedDBManager];
    
    [self refresh];
    [_player pause];
    //6
    [self configurePlayer];
}

- (void)setLabels:(Music *)music{
    self.titleLabel.text = music.title;
    self.artistLabel.text = music.artist;
    self.BPMLabel.text = [NSString stringWithFormat:@"%d",music.BPM];
    //image
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
                                         
                                         //                                                  int currentTime = (int)((weakSelf.player.currentTime.value)/weakSelf.player.currentTime.timescale);
                                         //                                                  int currentMins = (int)(currentTime/60);
                                         //                                                  int currentSec  = (int)(currentTime%60);
                                         
                                         
                                         
//                                         NSString * durationLabel =[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentMins,currentSec,durationMin,durationSec];
//                                         weakSelf.playTimeLabel.text = durationLabel;
                                         
//                                         weakSelf.playTimeSlider.value = currentTime;
                                     }];
    
}
@end
