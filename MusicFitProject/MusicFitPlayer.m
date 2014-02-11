//
//  MusicFitPlayer.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 7..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "MusicFitPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioSession.h>

#define PREVPATH @"ipod-library://item/item.mp3?id="
@implementation MusicFitPlayer{
    AVPlayer *_player;
    NSMutableArray *_playList;
    Music *_curPlayMusic;
    NSInteger _curPlayIndex;
    AVPlayerItem *_curPlayItem;
    BOOL _playing;
}
static MusicFitPlayer *_playerInstance = nil;
+ (id)sharedPlayer{
    if(_playerInstance == nil){
        _playerInstance = [[MusicFitPlayer alloc]init];
    }
    return _playerInstance;
}
- (id)init{
    self = [super init];
    if(self){
        _player = [[AVQueuePlayer alloc]init];
        
        DBManager *dbManager = [DBManager sharedDBManager];
        _playList = [[NSMutableArray alloc]init];
        [dbManager syncPlayList];
        _playList = [dbManager getPlayListArray];
        
        _curPlayMusic = [[Music alloc]init];
        _curPlayIndex = 0;
        _playing = NO;
        [self settingNoit];
        [self playMusicWithIndex:_curPlayIndex];
        [self pause];
    }
    
    return self;
}
- (void)settingNoit{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
//    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
//    [_player addObserver:self forKeyPath:@"rate" options:0 context:nil];
//    [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}
#pragma mark -
#pragma mark ===========  Interruption, Route changed  =========
#pragma mark -
- (void)interruption:(NSNotification *)noti{
    NSDictionary *interruptionDict = noti.userInfo;
    NSUInteger interruptionType = [[interruptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if(interruptionType == AVAudioSessionInterruptionTypeBegan /*&&!_PAUSE_REASON_ForcePause*/){
//        interruptedWhilePlaying = YES;
//        [self pausePlayerForcibly:YES];
        [self pause];
    }else if(interruptionType == AVAudioSessionInterruptionTypeEnded /*&interruptedWhilePlaying*/){
//        interruptedWhilePlaying = NO;
//        [self pausePlayerForcibly:NO];
        [self play];
    }
    NSLog(@"interruption : %@", interruptionType == AVAudioSessionInterruptionTypeBegan ? @"began" : @"end");
}
- (void)routeChange:(NSNotification *)noti{
    NSDictionary *routeChangeDict = noti.userInfo;
    NSUInteger routeChangeType = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if(routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable /*&& !_PAUSE_RESON_ForcePause*/){
//        routeChangedWhilePlaying = YES;
//        [self pausePlayerForcibly:YES];
    }else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable /*&& routeCHangedWHilePlaying*/){
//        routeChangedWhilePlaying = YES;
//        [self pausePlayerForcibly:YES];
        [self play];
    }
    
    NSLog(@"routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
}
//- (void)routeChange:(NSNotification *)notification
//{
//    NSDictionary *routeChangeDict = notification.userInfo;
//    NSUInteger routeChangeType = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
//    
//    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable && !_PAUSE_REASON_ForcePause) {
//        routeChangedWhilePlaying = YES;
//        [self pausePlayerForcibly:YES];
//    } else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable && routeChangedWhilePlaying) {
//        routeChangedWhilePlaying = NO;
//        [self pausePlayerForcibly:NO];
//        [self play];
//    }
//    NSLog(@"HysteriaPlayer routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
//}
//
//#pragma mark -
//#pragma mark ===========  KVO  =========
//#pragma mark -
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
//                        change:(NSDictionary *)change context:(void *)context {
//    if (object == _audioPlayer && [keyPath isEqualToString:@"status"]) {
//        if (_audioPlayer.status == AVPlayerStatusReadyToPlay) {
//            if (_readyToPlay != nil) {
//                _readyToPlay(HysteriaPlayerReadyToPlayPlayer);
//            }
//            if (![self isPlaying]) {
//                [_audioPlayer play];
//            }
//        } else if (_audioPlayer.status == AVPlayerStatusFailed) {
//            NSLog(@"%@",_audioPlayer.error);
//            
//            if (self.showErrorMessages)
//                [MyMusicPlayer showAlertWithError:_audioPlayer.error];
//            
//            if (_failed != nil) {
//                _failed(HysteriaPlayerFailedPlayer, _audioPlayer.error);
//            }
//        }
//    }
//    
//    if(object == _audioPlayer && [keyPath isEqualToString:@"rate"]){
//        if (!_isInEmptySound && _playerRateChanged)
//            _playerRateChanged();
//        else if (_isInEmptySound && [_audioPlayer rate] == 0.f)
//            _isInEmptySound = NO;
//    }
//    
//    if(object == _audioPlayer && [keyPath isEqualToString:@"currentItem"]){
//        if (_currentItemChanged != nil) {
//            AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
//            if (newPlayerItem != (id)[NSNull null])
//                _currentItemChanged(newPlayerItem);
//        }
//    }
//    
//    if (object == _audioPlayer.currentItem && [keyPath isEqualToString:@"status"]) {
//        _isPreBuffered = NO;
//        if (_audioPlayer.currentItem.status == AVPlayerItemStatusFailed) {
//            if (self.showErrorMessages)
//                [MyMusicPlayer showAlertWithError:_audioPlayer.currentItem.error];
//            
//            if (_failed)
//                _failed(HysteriaPlayerFailedCurrentItem, _audioPlayer.currentItem.error);
//        }else if (_audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
//            if (_readyToPlay != nil) {
//                _readyToPlay(HysteriaPlayerReadyToPlayCurrentItem);
//            }
//            if (![self isPlaying] && !_PAUSE_REASON_ForcePause) {
//                [_audioPlayer play];
//            }
//        }
//    }
//    
//    if (_audioPlayer.items.count > 1 && object == [_audioPlayer.items objectAtIndex:1] && [keyPath isEqualToString:@"loadedTimeRanges"])
//        _isPreBuffered = YES;
//    
//    if(object == _audioPlayer.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"]){
//        if (_audioPlayer.currentItem.hash != CHECK_AvoidPreparingSameItem) {
//            [self prepareNextPlayerItem];
//            CHECK_AvoidPreparingSameItem = _audioPlayer.currentItem.hash;
//        }
//        
//        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
//        if (timeRanges && [timeRanges count]) {
//            CMTimeRange timerange=[[timeRanges objectAtIndex:0]CMTimeRangeValue];
//            
//            if (_currentItemPreLoaded)
//                _currentItemPreLoaded(CMTimeAdd(timerange.start, timerange.duration));
//            
//            
//            if (_audioPlayer.rate == 0 && !_PAUSE_REASON_ForcePause) {
//                _PAUSE_REASON_Buffering = YES;
//                
//                [self longTimeBufferBackground];
//                
//                CMTime bufferdTime = CMTimeAdd(timerange.start, timerange.duration);
//                CMTime milestone = CMTimeAdd(_audioPlayer.currentTime, CMTimeMakeWithSeconds(5.0f, timerange.duration.timescale));
//                
//                if (CMTIME_COMPARE_INLINE(bufferdTime , >, milestone) && _audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay && !interruptedWhilePlaying && !routeChangedWhilePlaying) {
//                    if (![self isPlaying]) {
//                        NSLog(@"resume from buffering..");
//                        _PAUSE_REASON_Buffering = NO;
//                        
//                        [_audioPlayer play];
//                        [self longTimeBufferBackgroundCompleted];
//                    }
//                }
//            }
//        }
//    }
//}
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
//    NSNumber *CHECK_Order = [self getHysteriaOrder:_audioPlayer.currentItem];
//    if (CHECK_Order) {
//        if (_repeatMode == RepeatMode_one) {
//            NSInteger currentIndex = [CHECK_Order integerValue];
//            [self fetchAndPlayPlayerItem:currentIndex];
//        } else if (_shuffleMode == ShuffleMode_on){
//            [self fetchAndPlayPlayerItem:[self getRandomSong]];
//        } else {
//            if (_audioPlayer.items.count == 1 || !_isPreBuffered) {
//                NSInteger nowIndex = [CHECK_Order integerValue];
//                if (nowIndex + 1 < items_count) {
                    [self nextPlay];
//                } else {
//                    if (_repeatMode == RepeatMode_off) {
//                        [self pausePlayerForcibly:YES];
//                        if (_playerDidReachEnd != nil)
//                            _playerDidReachEnd();
//                    }
//                    [self fetchAndPlayPlayerItem:0];
//                }
//            }
//        }
//    }
}
//- (NSUInteger)getRandomSong
//{
//    NSUInteger index;
//    do {
//        index = arc4random() % items_count;
//    } while ([_playedItems containsObject:[NSNumber numberWithInteger:index]]);
//    
//    return index;
//}
//
//#pragma mark -
//#pragma mark ===========   Deprecation  =========
//#pragma mark -
//
//- (void)deprecatePlayer
//{
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    
//    [_audioPlayer removeObserver:self forKeyPath:@"status" context:nil];
//    [_audioPlayer removeObserver:self forKeyPath:@"rate" context:nil];
//    [_audioPlayer removeObserver:self forKeyPath:@"currentItem" context:nil];
//    
//    [self removeAllItems];
//    
//    _failed = nil;
//    _readyToPlay = nil;
//    _sourceAsyncGetter = nil;
//    _sourceSyncGetter = nil;
//    _playerRateChanged = nil;
//    _playerDidReachEnd = nil;
//    _currentItemChanged = nil;
//    _currentItemPreLoaded = nil;
//    
//    [_audioPlayer pause];
//    _audioPlayer = nil;
//    
//    onceToken = 0;
//}

- (BOOL)setPlayList{
    DBManager *dbManager = [DBManager sharedDBManager];
    [_playList removeAllObjects];
    _playList = [dbManager getPlayListArray];
    if(_playList == nil)
        return NO;
    else{
        [self playMusicWithIndex:0];
        [self.delegate initMusicProgress];
        return YES;
    }
}
- (BOOL)changePlayMusicWithIndex:(NSInteger)index{
    if(_curPlayIndex == index){
        return YES;
    }else{
        return [self playMusicWithIndex:index];
    }
}
- (void)changePlayPoint:(NSInteger)changeTimePoint{
    [_player seekToTime:CMTimeMakeWithSeconds(changeTimePoint , 1)];
}
- (void)changePlayVolume:(CGFloat)changeVolumeValue{
    _player.volume = changeVolumeValue;
}
- (void)pause{
    _playing = NO;
    [_player pause];
}
- (void)play{
    _playing = YES;
    [_player play];
}
- (void)nextPlay{
    ++_curPlayIndex;
    if(_curPlayIndex == [_playList count])
        _curPlayIndex = 0;
    
    [self.delegate initMusicProgress];
    [self playMusicWithIndex:_curPlayIndex];
}
- (void)prevPlay{
    --_curPlayIndex;
    if(_curPlayIndex == 0)
        _curPlayIndex = [_playList count]-1;
    
    [self.delegate initMusicProgress];
    [self playMusicWithIndex:_curPlayIndex];
}

- (BOOL)playMusicWithIndex:(NSInteger)index{
    _playing = NO;
    _curPlayIndex = index;
    [_player pause];
    DBManager *dbManager = [DBManager sharedDBManager];
    NSInteger musicID = [_playList[_curPlayIndex][@"musicID"] intValue];
    
    _curPlayMusic = [dbManager getMusicWithMusicID:musicID];
    
    if(_curPlayMusic == nil)
        return NO;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",PREVPATH, _curPlayMusic.location];
    
    _curPlayItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    
    [_player replaceCurrentItemWithPlayerItem:_curPlayItem];
    [self setSliderMaxDelegate];
    [_player play];
    _playing = YES;
    
    [self syncData];
    return YES;
}

- (void)setSliderMaxDelegate{
    CMTime duration = _player.currentItem.asset.duration;
    
    [self.delegate setMusicProgressMax:(int)CMTimeGetSeconds(duration)];
}

- (void)syncData{
    [self.delegate syncLabels:[_curPlayMusic getAlbumImage] music:_curPlayMusic];
}
- (BOOL)isPlaying{
    return _playing;
}
- (int)getDuration{
    return (int)CMTimeGetSeconds(_player.currentItem.asset.duration);
}
- (int)getCurTime{
    return (int)CMTimeGetSeconds(_player.currentTime);
}

- (void)callMusicProgressDelegate:(NSString *)timeString timePoint:(NSInteger)timePoint{
    [self.delegate syncMusicProgress:timeString timePoint:timePoint];
}
- (void)checkCurTime{
    __block MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)  queue:NULL usingBlock:^(CMTime time) {
            if(!time.value)
                return;
            int duration = [player getDuration];
            int currentTime = [player getCurTime];
            int durationMin = (int)(duration / 60);
            int durationSec = (int)(duration % 60);
            int currentMins = (int)(currentTime / 60);
            int currentSec = (int)(currentTime % 60);
        
        NSString * timeString =[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentMins,currentSec,durationMin,durationSec];
        
        [player callMusicProgressDelegate:timeString timePoint:currentTime];
        
    }];
}
@end
