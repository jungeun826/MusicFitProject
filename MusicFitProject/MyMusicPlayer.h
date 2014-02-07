//
//  MusicPlayer.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 6..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#define HYSTERIAPLAYER_CURRENT_TIME @"CurrentTime"
#define HYSTERIAPLAYER_DURATION_TIME @"DurationTime"

typedef NS_ENUM(NSUInteger, HysteriaPlayerReadyToPlay) {
    HysteriaPlayerReadyToPlayPlayer = 3000,
    HysteriaPlayerReadyToPlayCurrentItem = 3001,
};

typedef NS_ENUM(NSUInteger, HysteriaPlayerFailed) {
    HysteriaPlayerFailedPlayer = 4000,
    HysteriaPlayerFailedCurrentItem = 4001,
    
};

typedef void (^ Failed)(HysteriaPlayerFailed identifier, NSError *error);
typedef void (^ ReadyToPlay)(HysteriaPlayerReadyToPlay identifier);
typedef void (^ SourceAsyncGetter)(NSUInteger index);
typedef NSString * (^ SourceSyncGetter)(NSUInteger index);
typedef void (^ PlayerRateChanged)();
typedef void (^ CurrentItemChanged)(AVPlayerItem *item);
typedef void (^ PlayerDidReachEnd)();
typedef void (^ CurrentItemPreLoaded)(CMTime time);

typedef enum{
    HysteriaPlayerStatusPlaying = 0,
    HysteriaPlayerStatusForcePause,
    HysteriaPlayerStatusBuffering,
    HysteriaPlayerStatusUnknown
}
HysteriaPlayerStatus;

typedef enum{
    RepeatMode_on = 0,
    RepeatMode_one,
    RepeatMode_off
}
PlayerRepeatMode;

typedef enum{
    ShuffleMode_on = 0,
    ShuffleMode_off
}
PlayerShuffleMode;



@interface MyMusicPlayer : NSObject
@property (nonatomic, strong, readonly) NSMutableArray *playerItems;
@property (nonatomic, weak) AVQueuePlayer *audioPlayer;
@property (nonatomic, readonly) BOOL isInEmptySound;
@property (nonatomic) BOOL showErrorMessages;

+ (MyMusicPlayer *)sharedPlayer;

- (void)registerHandlerPlayerRateChanged:(PlayerRateChanged)playerRateChanged CurrentItemChanged:(CurrentItemChanged)currentItemChanged PlayerDidReachEnd:(PlayerDidReachEnd)playerDidReachEnd;
- (void)registerHandlerReadyToPlay:(ReadyToPlay)readyToPlay;
- (void)registerHandlerCurrentItemPreLoaded:(CurrentItemPreLoaded)currentItemPreLoaded;
- (void)registerHandlerFailed:(Failed)failed;


/*!
 Recommend you use this method to handle your source getter, setupSourceAsyncGetter:ItemsCount: is for advanced usage.
 @method setupSourceGetter:ItemsCount:
 */
- (void)setupSourceGetter:(SourceSyncGetter)itemBlock ItemsCount:(NSUInteger) count;
/*!
 If you are using Async block handle your item, make sure you call setupPlayerItem: at last
 @method asyncSetupSourceGetter:ItemsCount
 */
- (void)asyncSetupSourceGetter:(SourceAsyncGetter)asyncBlock ItemsCount:(NSUInteger)count;
- (void)setItemsCount:(NSUInteger)count;

/*!
 This method is necessary if you setting up AsyncGetter.
 After you your AVPlayerItem initialized should call this method on your asyncBlock.
 Should not call this method directly if you using setupSourceGetter:ItemsCount.
 @method setupPlayerItem:
 */
- (void)setupPlayerItem:(NSString *)url Order:(NSUInteger)index;
- (void)fetchAndPlayPlayerItem: (NSUInteger )startAt;
- (void)removeAllItems;
- (void)removeQueuesAtPlayer;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)moveItemFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (void)play;
- (void)pause;
- (void)playPrevious;
- (void)playNext;
- (void)seekToTime:(double) CMTime;
- (void)seekToTime:(double) CMTime withCompletionBlock:(void (^)(BOOL finished))completionBlock;

- (void)setPlayerRepeatMode:(PlayerRepeatMode)mode;
- (PlayerRepeatMode)getPlayerRepeatMode;
- (void)setPlayerShuffleMode:(PlayerShuffleMode)mode;
- (void)pausePlayerForcibly:(BOOL)forcibly;

- (PlayerShuffleMode)getPlayerShuffleMode;
- (NSDictionary *)getPlayerTime;
- (float)getPlayerRate;
- (BOOL)isPlaying;
- (AVPlayerItem *)getCurrentItem;
- (HysteriaPlayerStatus)getHysteriaPlayerStatus;

- (BOOL)setPlayList;

/*
 * Disable memory cache, player will run SourceItemGetter everytime even the media has been played.
 * Default is YES
 */
- (void)enableMemoryCached:(BOOL) isMemoryCached;
- (BOOL)isMemoryCached;

/*
 * Indicating Playeritem's play order
 */
- (NSNumber *)getHysteriaOrder:(AVPlayerItem *)item;

- (void)deprecatePlayer;

//- (BOOL)changeMusic;
//- (BOOL)preMusic;
//- (BOOL)nextMusic;
//- (BOOL)changeVolume;

@end
