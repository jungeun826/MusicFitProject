//
//  MusicFitPlayer.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 7..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
@protocol FitModeImageViewDelegate <NSObject>

- (void)startFitModeAnimation;
- (void)stopFitModeAnimation;
- (void)setWorkPlayer:(BOOL)isPlaying;
@end

@protocol MusicFitPlayerDelegate <NSObject>

- (void)syncLabels:(UIImage *)albumImage music:(Music *)music;
- (void)syncMusicProgress:(NSString *)timeString timePoint:(NSInteger)timePoint;
- (void)setMusicProgressMax:(NSInteger)max;
- (void)initMusicProgress;

@end

@interface MusicFitPlayer : NSObject

@property NSInteger curMode;
@property NSInteger curPlayIndex;
@property BOOL playingItemDeleted;
@property (weak) id<MusicFitPlayerDelegate> playerDelegate;
@property (weak) id<FitModeImageViewDelegate> fitModeDelegate;

+ (id)sharedPlayer;
- (BOOL)setPlayList;
- (BOOL)changePlayMusicWithIndex:(NSInteger)index;
- (void)pause;
- (void)play;

- (void)nextPlay;
- (void)prevPlay;

- (BOOL)isPlaying;

- (void)changePlayPoint:(NSInteger)changeTimePoint;
- (void)changePlayVolume:(CGFloat)changeVolumeValue;

- (void)setSliderMaxDelegate;
- (void)syncData;
- (void)checkCurTime;

- (int)getDuration;
- (int)getCurTime;
@end
