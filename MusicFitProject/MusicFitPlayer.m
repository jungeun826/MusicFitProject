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
#import "DBManager.h"

#define PREVPATH @"ipod-library://item/item.mp3?id="
#define SCREENIMAGE_SIZE CGSizeMake(100, 100)
#define APPIMAGE_SIZE CGSizeMake(42, 42)
@interface MusicFitPlayer(){
    BOOL _interruptedWhilePlaying;
}
@property (nonatomic) BOOL ForcePause;
@property (nonatomic) BOOL BufferingPause;

@end

@implementation MusicFitPlayer{
    AVQueuePlayer *_player;
    NSMutableArray *_playQueue;
    Music *_curPlayMusic;
    MPMediaItem *_curPlayItem;
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
        DBManager *dbManager = [DBManager sharedDBManager];
        
        //일반 변수 초기화
        _curPlayMusic = [[Music alloc]init];
        _curPlayIndex = 0;
        _playingItemDeleted = NO;
        self.curMode = [dbManager getCurModeID];

        _playQueue = [[NSMutableArray alloc]init];
        //현재 모드에 대한 플레이 리스트 얻어오기 전에 싱크를 맞춤
        [dbManager syncList];
        
        //얻어온 플레이 리스트를 AVPlayerItem의 array로 만들어
        //플레이어의 아이템으로 만듦
       _player = [[AVQueuePlayer alloc]init];
        [self setPlayListQueueWithPlayIndex:0 edit:@"NO"];
            //그 아이템으로 플레이어 초기화
//            _player = [[AVQueuePlayer alloc]initWithItems:_playQueue];
            //바뀐 curPlayIndex와  curPlayMusic의 sync를 맞춤
        [self syncChangeMusic];

        
        _player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
        
        [self settingNoit];
        [self addObserver:self forKeyPath:@"self.playing" options:NSKeyValueObservingOptionNew context:nil];
        
        self.playing = NO;
    }
    
    return self;
}

//바뀐 curPlayIndex와  curPlayMusic의 sync를 맞춤
- (void)syncChangeMusic{
    //바뀐 인덱스에 대한  Music객체를 갖도록 변경
    [self syncCurPlayMusic];
    //바뀐 인덱스에 대해  변경된 Music 객체를 이용해
    //플레이어의 레이블과 아트뷰, 제목, 아티스트, 총 플레이타임 프로그레스바를 변경함.
    [self syncLabel];
    if(_playQueue.count == 0){
        [self.playerDelegate setMusicProgressMax:CMTimeGetSeconds(kCMTimeZero)];
        _curPlayItem = nil;
    }else{
        [self.playerDelegate setMusicProgressMax:CMTimeGetSeconds([[_playQueue[_curPlayIndex] asset] duration])];
        _curPlayItem = [_curPlayMusic getMPMediaItemOfMusic];
    }
}
- (void)changeLockScreen{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

    if (playingInfoCenter) {
        UIImage *albumImage = [_curPlayMusic getAlbumImageWithSize:SCREENIMAGE_SIZE];
        
        if(albumImage == nil){
            albumImage = [UIImage imageNamed:@"artview_1.png"];
        }
        MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:albumImage];
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        if(_curPlayItem != nil){
            
            [songInfo setObject:[_curPlayItem valueForKey:MPMediaItemPropertyTitle] forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:[_curPlayItem valueForKey:MPMediaItemPropertyArtist] forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:[_curPlayItem valueForKey:MPMediaItemPropertyPlaybackDuration] forKey:MPMediaItemPropertyPlaybackDuration];
            
        }else {
            [songInfo setObject:_curPlayMusic.title forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:_curPlayMusic.artist forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:[[NSNumber alloc] initWithInteger:[self getDuration]] forKey:MPMediaItemPropertyPlaybackDuration];
        }
        [songInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}
- (void)setAudioSession{
    NSError *error = nil;
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:kAudioSessionProperty_OverrideCategoryMixWithOthers error:&error];
    
    [session setActive:YES error:&error];
}
- (void)syncCurPlayMusic{
     DBManager *dbManager = [DBManager sharedDBManager];
    if(_playQueue.count == 0){
        NSLog(@"not file");
        _curPlayMusic =nil;
    }else{
        NSInteger musicID = [dbManager getKeyValueInListWithKey:@"musicID" index:_curPlayIndex];
        _curPlayMusic = [dbManager getMusicWithMusicID: musicID];
    }
}

//모드 변경이나 에디트 햇을 떄 새로운 큐리스트를 만들어
//플레이어 큐에 반영해야 하므로 -  에디트 인경우 현재인덱스. 모드변경은 0
- (BOOL)setPlayListQueueWithPlayIndex:(NSInteger)index edit:(NSString *)edit{
//    [self pause];
//에디트 했다 == 내가 듣고 있는 음악이 삭제되지 않음.
    if(_playQueue.count == 0)
        edit = @"NO";
    
    if([edit isEqualToString:@"YES"]){
        for (int i = 0; i <(int)_playQueue.count;  i ++) {
            if(_playQueue[i] == [_player currentItem]){
                while (++i < (int)_playQueue.count) {
                    [_player removeItem:_playQueue[i]];
                }
                break;
            }
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [_player removeAllItems];
            [self.playerDelegate initMusicProgress];
        });
    }
    [_playQueue removeAllObjects];
    _curPlayIndex = index;
    DBManager *dbManager = [DBManager sharedDBManager];
    NSArray *playList = [dbManager getListArray];
    if(playList == nil){
        [_player removeAllItems];
        return NO;
    }
    NSInteger count  = [playList count];
    for(NSInteger queueIndex = 0 ; queueIndex < count ; queueIndex++ ){
        NSInteger musicID = [playList[queueIndex][@"musicID"] intValue];
        
        Music *music = [dbManager getMusicWithMusicID:musicID];
        
        if(music == nil)
            continue;
        
        NSString *url = [NSString stringWithFormat:@"%@%@",PREVPATH, music.location];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
        
        [_playQueue addObject:item];
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^ {
       [self changePlayerQueueWithEdit:edit];
//    });
    
    return YES;
}
- (void)startTheBackgroundJobWithEdit:(NSString *)edit {
    [self performSelectorInBackground:@selector(changePlayerQueueWithEdit:) withObject:edit ];
}
//임의로 곡을 바꾸는 경우 index로 조절
//그냥 처음에 리스트 변경인 경우는 index0으로 사용
- (void)changePlayerQueueWithEdit:(NSString *)edit{
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        NSLog(@"index : %d, %@", (int)_curPlayIndex, edit);
        NSInteger index = _curPlayIndex;
        BOOL editing = [edit isEqualToString:@"YES"] ? YES : NO;
        
        int count = (int)[_playQueue count];
        
        if(editing){
            if( count == 1)
                return ;
            index++;
            //        [self play];
        }else
            [_player removeAllItems];
        
        //    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        AVPlayerItem *insertItem = [_playQueue objectAtIndex:index];
        AVPlayerItem *prevItem = [_player currentItem];
        
        for (int i = (int)index; i <count;  i ++) {
            if(editing) {
                if([_player canInsertItem:insertItem afterItem:prevItem]){
                    [insertItem seekToTime:kCMTimeZero];
                    [_player insertItem:insertItem afterItem:prevItem];
                    
                    prevItem = insertItem;
                    if(i == (int)(_playQueue.count -1))
                        break;
                    insertItem = [_playQueue objectAtIndex:i+1];
                }
            }else{
                if([_player canInsertItem:insertItem afterItem:nil]){
                    //                    NSLog(@"isMain Thread : %d", [NSThread isMainThread]);
                    [insertItem seekToTime:kCMTimeZero];
                    [_player insertItem:insertItem afterItem:nil];
                    if(i == (int)(_playQueue.count -1))
                        break;
                    insertItem = [_playQueue objectAtIndex:i+1];
                }
            }
            if(index == i){
                [self syncChangeMusic];
                [self syncPlayTimeLabel];
                if(_playing)
                    [self play];
            }
        }
    });
}
- (void)prevPlayItemAddInQueueWithIndex:(NSInteger)index{
    AVPlayerItem *prevItem = [_playQueue objectAtIndex:index];
    AVPlayerItem *curItem = _player.currentItem;

    if ([_player canInsertItem:prevItem afterItem:curItem]) {
        [_player.currentItem seekToTime:kCMTimeZero];
        [_player insertItem:prevItem afterItem:curItem];
        [_player advanceToNextItem];
        [_player insertItem:curItem afterItem:prevItem];
    }
}
//table에서 임의 인덱스 선택해서 음악 재생하는 경우
- (BOOL)changePlayMusicWithIndex:(NSInteger)index{
    if(_curPlayIndex == index)
        return YES;
//    if(_curPlayIndex > index){
//        int loopCount = (_curPlayIndex - index);
//        int startAddIndex = _curPlayIndex;
//        for( ; loopCount >0 ; loopCount--){
//            [self prevPlayItemAddInQueueWithIndex:--startAddIndex];
//        }
//    }else{
//        [_player.currentItem seekToTime:kCMTimeZero];
//        for(int loopCount = (index - _curPlayIndex-1) ; loopCount >0 ; loopCount--){
//            [_player removeItem:_player.currentItem];
//        }
//        [_player advanceToNextItem];
//    }
    //인덱스가 다르면 현재 인덱스로 맞추어 줘야함.
    _curPlayIndex = index;
    //index부터 시작하는 큐를 플레이어에 넣어줌
    [self changePlayerQueueWithEdit:@"NO"];
    
    return YES;
}
- (void)changePlayPoint:(NSInteger)changeTimePoint{
    [_player seekToTime:CMTimeMakeWithSeconds(changeTimePoint , 1)];
}
- (void)changePlayVolume:(CGFloat)changeVolumeValue{
    _player.volume = changeVolumeValue;
}
- (void)pause{
    self.playing = NO;
    [_player pause];
    [self.fitModeDelegate setWorkPlayer:self.playing mode:_curMode];
    [self.fitModeDelegate stopFitModeAnimation];
}
- (void)play{
    self.playing = YES;
//    NSLog(@"%d",[_player status]);
    [_player play];
    [self.fitModeDelegate setWorkPlayer:self.playing mode:_curMode];
    [self.fitModeDelegate startFitModeAnimation];
}
- (void)nextPlay{
    ++_curPlayIndex;
    if(_curPlayIndex != [_playQueue count]){
        [_player.currentItem seekToTime:kCMTimeZero];
        [_player advanceToNextItem];
    }else {
        _curPlayIndex = 0;
        [self changePlayerQueueWithEdit:@"NO"];
    }
    [self.playerDelegate initMusicProgress];
    
    [self syncChangeMusic];
    [self syncPlayTimeLabel];
} 
- (void)prevPlay{
    --_curPlayIndex;
    if(_curPlayIndex > 0){
        [self prevPlayItemAddInQueueWithIndex:_curPlayIndex];
    }else{
        _curPlayIndex = [_playQueue count]-1;
        [self changePlayerQueueWithEdit:@"NO"];
    }
    [self.playerDelegate initMusicProgress];
    [self syncChangeMusic];
    [self syncPlayTimeLabel];
}

- (BOOL)isPlaying{
    return self.playing;
}


- (void)syncLabel{
    UIImage *image;
    if (_curPlayMusic == nil) {
        image = [UIImage imageNamed:@"artview_2.png"];
    }else{
        image = [_curPlayMusic getAlbumImageWithSize:APPIMAGE_SIZE];
    }
    [self.playerDelegate syncLabels:image music:_curPlayMusic];
}

- (int)getDuration{
    return (int)CMTimeGetSeconds(_player.currentItem.asset.duration);
}
- (int)getCurTime{
    return (int)CMTimeGetSeconds(_player.currentTime);
}

- (NSInteger)getCurPlayIndex{
    return _curPlayIndex;
}
//1초마다 변경해 주어야 하는 음악 재생 시간 레이블에 대한 변경사항을 반영
//임의로 음악 재생 변경시에도 사용 (next, prev, random select)
- (void)syncPlayTimeLabel{
//    NSString * timeString;
//    int currentTime = 0;
//    if(_playQueue.count != 0){
    
    int duration = [self getDuration];
    int currentTime = [self getCurTime];
    int durationMin = (int)(duration / 60);
    int durationSec = (int)(duration % 60);
    int currentMins = (int)(currentTime / 60);
    int currentSec = (int)(currentTime % 60);
    
NSString    *timeString = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentMins,currentSec,durationMin,durationSec];
//    }else
//        timeString = @"00:00/00:00";
    
    
    [self.playerDelegate syncMusicProgress:timeString timePoint:currentTime];
}
- (void)checkCurTime{
    __block MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)  queue:NULL usingBlock:^(CMTime time) {
            if(!time.value)
                return;
        [player syncPlayTimeLabel];
        [player.fitModeDelegate checkProgressTime];
        [player changeLockScreen];
    }];
}

- (void)callSliderMaxDelegate{
    CMTime duration = _player.currentItem.asset.duration;
    
    [self.playerDelegate setMusicProgressMax:(int)CMTimeGetSeconds(duration)];
}

#pragma mark -
#pragma mark ===========  Interruption, Route changed  =========
#pragma mark -
- (void)interruption:(NSNotification *)noti{
    NSDictionary *interruptionDict = noti.userInfo;
    NSUInteger interruptionType = [[interruptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if(interruptionType == AVAudioSessionInterruptionTypeBegan &&!self.ForcePause){
        _interruptedWhilePlaying = YES;
        [self pausePlayerForcibly:YES];
        [self pause];
    }else if(interruptionType == AVAudioSessionInterruptionTypeEnded && _interruptedWhilePlaying){
        _interruptedWhilePlaying = NO;
        [self pausePlayerForcibly:NO];
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


- (void)settingNoit{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    //    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    //    [_player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    //    [_player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}
- (void)playerItemDidReachEnd:(NSNotification *)notification{
    //다음 음악 변경은 플레이어 초기화시 해서 필요 없음.
//    [_player advanceToNextItem];
    
    _curPlayIndex++;
    if(_curPlayIndex == [_playQueue count]){
        _curPlayIndex = 0;
        [self changePlayerQueueWithEdit:NO];
    }
    [self syncChangeMusic];
    [self.playerDelegate initMusicProgress];
}

//modeViewController에서 table selected action에 대해서 처리하는 부분
//이미 음악 리스트 sync를 맞춰놓음.
//getList부터 시작해야함.
/*
 1.현재 플레이어 모델의 리스트 변경
 2.현재플레이어모델내의AVQueuePlayer의item 변경
 3.현재 재생해야 할 음악의 index를 0으로 변경 (mode변경되었을 경우)
 
 4. 현재 재생중인 음악들에 대해
*/
- (void)changeMode:(NSInteger)mode{
    DBManager *dbManager = [DBManager sharedDBManager];
    NSInteger modeID = [dbManager getCurModeID];
    //mode가 변경되지 않으면 처음에 불러놓은 것을 쓰면 됨.
    if(_curMode == modeID)
        return;
    
    
    _curMode = modeID;
    //activity indicator 알려주기  delegate
    [self setPlayListQueueWithPlayIndex:0 edit:@"NO"];
    
    [self syncChangeMusic];
    [self.fitModeDelegate stopFitModeAnimation];
    [self.playerDelegate initMusicProgress];
    [self.fitModeDelegate startFitModeAnimation];
    
    [self syncPlayTimeLabel];
    //activity indicator 끄기 delegate
    [self.fitModeDelegate setWorkPlayer:self.playing mode:_curMode];
//    [NSThread detachNewThreadSelector:@selector(threadChangeMode:) toTarget:self withObject:[NSNumber numberWithInteger:mode]];

}
- (void)threadChangeMode:(NSInteger)mode{    
    //activity indicator 알려주기  delegate
        [self setPlayListQueueWithPlayIndex:0 edit:@"NO"];
        [self syncChangeMusic];
        [self.fitModeDelegate stopFitModeAnimation];
        [self.playerDelegate initMusicProgress];
        [self.fitModeDelegate startFitModeAnimation];
        
        [self syncPlayTimeLabel];
    //activity indicator 끄기 delegate
}
- (void)syncEditList{
    //큐 리스트 생성 후
    //편집된 음악리스트를 새로 만들어 주지만
    //재생중 음악 삭제가 아닌 경우는 계속 음악을 듣게 해야함.
    if (_playingItemDeleted) {
        //        [self nextPlay];
        [self setPlayListQueueWithPlayIndex:_curPlayIndex edit:@"NO"];
//        [_player advanceToNextItem];
//        [self changePlayerQueueWithIndex:_curPlayIndex edit:YES];
        //        [self playMusicWithIndex:_curPlayIndex];
        
        _playingItemDeleted = NO;
    }else
        [self setPlayListQueueWithPlayIndex:_curPlayIndex edit:@"YES"];
//    else if(!_playingItemDeleted){
//        //플레이 리스트가 편집되었는데 현재 듣고 있는 음악 삭제 안됨.
//        //그냥 현재 인덱스만 바뀜 (dbManager에서 바꿈)
//        return;
//    }
    [self.fitModeDelegate setWorkPlayer:self.playing mode:_curMode];
    [self.playerDelegate initMusicProgress];
    
    [self syncPlayTimeLabel];
    [self syncChangeMusic];
    
}
- (void)setPlaying:(BOOL)playing{
    _playing = playing;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath  isEqual: @"self.playing"] && object == self){
//        if(self.playing == YES)
            [self.playerDelegate changePlayBtnSelected:self.playing];
    }
}
- (void)pausePlayerForcibly:(BOOL)forcibly{
    if (forcibly)
        self.ForcePause = YES;
    else
        self.ForcePause = NO;
}
- (MusicFitPlayerStatus)status{
    if ([self isPlaying])
        return MusicFitPlayerStatusPlaying;
    else if (self.ForcePause)
        return MusicFitPlayerStatusForcePause;
    else if (self.BufferingPause)
        return MusicFitPlayerStatusBuffering;
    else
        return MusicFitPlayerStatusUnknown;
}
@end
