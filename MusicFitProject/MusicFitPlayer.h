//
//  MusicFitPlayer.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 7..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

@protocol MusicFitPlayerDelegate <NSObject>

- (void)syncLabels:(UIImage *)albumImage music:(Music *)music;
- (void)syncMusicProgress:(NSString *)timeString timePoint:(NSInteger)timePoint;
- (void)setMusicProgressMax:(NSInteger)max;
- (void)initMusicProgress;
@end

@interface MusicFitPlayer : NSObject

@property (weak) id<MusicFitPlayerDelegate> delegate;

+ (id)sharedPlayer;
- (BOOL)setPlayList;
- (BOOL)changePlayMusicWithIndex:(NSInteger)index;
- (void)pause;
- (void)play;

- (void)nextPlay;
- (void)prevPlay;

- (BOOL)isPlaying;

- (void)changePlayPoint:(NSInteger)changeTimePoint;
- (void)setSliderMaxDelegate;
- (void)syncData;
- (void)checkCurTime;

- (int)getDuration;
- (int)getCurTime;
@end
