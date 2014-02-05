//
//  MusicDBManager.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DBManager.h"
#import "Music.h"

@interface MusicDBManager : DBManager
+ (id)sharedMusicDBManager;
- (BOOL)insertMusicWithBPM:(NSInteger)bpm title:(NSString *)title artist:(NSString *)artist location:(NSString *)location isMusic:(BOOL)isMusic;
- (Music *)getMusicWithIndex:(NSInteger)index;
- (Music *)getMusicWithMusicID:(NSInteger)musicID;
- (BOOL)deleteMusicWithMusicID:(NSInteger)musicID;
- (BOOL)syncMusic;
- (NSInteger)getNumberOfMusic;
- (BOOL)isExistWithlocation:(NSString *)location;
- (void)setDB:(sqlite3 *)getDB;
@end
