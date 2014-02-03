//
//  Music.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "Music.h"

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
@end
