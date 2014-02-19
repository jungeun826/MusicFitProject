//
//  Music.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "Music.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Music

-(id)initWithMusicID:(NSInteger)musicID BPM:(NSInteger)bpm title:(NSString *)title artist:(NSString *)artist location:(NSString *)location isMusic:(BOOL)isMusic{
    self = [super init];
    if(self){
        _musicID = musicID;
        _BPM = bpm;
        _title = title;
        _artist = artist;
        _location = location;
        _isMusic = isMusic;
    }
    
    return self;
}
- (UIImage *)getAlbumImageWithSize:(CGSize)size{
    UIImage *albumImage = nil;
    
    if(_title==nil || _artist==nil){
        albumImage = [UIImage imageNamed:@"artview.png"];
        return albumImage;
    }
    MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate predicateWithValue:_title forProperty:MPMediaItemPropertyTitle];
    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:_artist forProperty:MPMediaItemPropertyArtist];
    
    NSSet *predicateSet = [NSSet setWithObjects:titlePredicate, artistPredicate, nil];
    
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
  
    NSArray *musics = [mediaQuery items];
    
    if([musics count] != 0){
        MPMediaItem *music = [musics objectAtIndex:0];
        
        MPMediaItemArtwork *artwork = [music valueForProperty: MPMediaItemPropertyArtwork];
        
        // Obtain a UIImage object from the MPMediaItemArtwork object
        if (artwork)
            albumImage = [artwork imageWithSize:size];
        
    }else
        albumImage = [UIImage imageNamed:@"artview_1.png"];
    
    return albumImage;
}

- (MPMediaItem *)getMPMediaItemOfMusic{
    
    MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate predicateWithValue:_title forProperty:MPMediaItemPropertyTitle];
    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:_artist forProperty:MPMediaItemPropertyArtist];
    
    NSSet *predicateSet = [NSSet setWithObjects:titlePredicate, artistPredicate, nil];
    
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
    NSArray *musics = [mediaQuery items];
    
    if([musics count] == 0)
        return nil;
    
    return [musics objectAtIndex:0];
}
@end
