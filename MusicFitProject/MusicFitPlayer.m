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
        
        [self playMusicWithIndex:_curPlayIndex];
        [self pause];
    }
    
    return self;
}
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
