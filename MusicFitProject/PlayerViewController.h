//
//  PlayerViewController.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController : UIViewController <AVAudioSessionDelegate>
- (void)playListSync;
- (void)changePlayMusic:(NSInteger)selectIndex;
- (void)setSwipeController;
@end
