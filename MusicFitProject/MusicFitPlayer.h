//
//  MusicFitPlayer.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 7..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModeToPlayerDelegate.h"
#import "EditListToPlayerDelegate.h"

@class Music;

@protocol playViewDelegate <NSObject>

-(void)moveTimer;
-(void)pauseTimer;

@end

@protocol FitModeImageViewDelegate <NSObject>

- (void)startFitModeAnimation;
- (void)stopFitModeAnimation;
- (void)setWorkPlayer:(BOOL)isPlaying mode:(NSInteger)curMode;
- (void)checkProgressTime;

@end
typedef enum
{
    MusicFitPlayerStatusPlaying = 0,
    MusicFitPlayerStatusForcePause,
    MusicFitPlayerStatusBuffering,
    MusicFitPlayerStatusUnknown
}MusicFitPlayerStatus;

@protocol MusicFitPlayerDelegate <NSObject>

- (void)syncLabels:(UIImage *)albumImage music:(Music *)music;
- (void)syncMusicProgress:(NSString *)timeString timePoint:(NSInteger)timePoint;
- (void)setMusicProgressMax:(NSInteger)max;
- (void)initMusicProgress;
- (void)changePlayBtnSelected:(BOOL)selected;

@end

@interface MusicFitPlayer : NSObject <ModeToPlayerDelegate, EditListToPlayerDelegate>

@property NSInteger curMode;
@property NSInteger curPlayIndex;
@property BOOL playingItemDeleted;
@property (weak) id<MusicFitPlayerDelegate> playerDelegate;
@property (weak) id<FitModeImageViewDelegate> fitModeDelegate;
@property (nonatomic) MusicFitPlayerStatus status;
@property (nonatomic) BOOL playing;
+ (id)sharedPlayer;
- (void)setAudioSession;


- (BOOL)changePlayMusicWithIndex:(NSInteger)index;

- (void)changePlayPoint:(NSInteger)changeTimePoint;
- (void)changePlayVolume:(CGFloat)changeVolumeValue;

- (void)pause;
- (void)play;
- (void)nextPlay;
- (void)prevPlay;
- (BOOL)isPlaying;

- (void)syncLabel;

- (int)getDuration;
- (int)getCurTime;

- (void)syncPlayTimeLabel;
- (void)checkCurTime;

- (void)callSliderMaxDelegate;

@end
