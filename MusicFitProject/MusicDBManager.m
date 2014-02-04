//
//  MusicDBManager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "MusicDBManager.h"

@implementation MusicDBManager{
    NSMutableArray *_musicList;
}
static MusicDBManager *_instance = nil;
+ (id)sharedMusicDBManager{
    if (nil == _instance) {
        _instance = [[MusicDBManager alloc] init];
        _instance->_musicList = [[NSMutableArray alloc]init];
        _instance->db = [_instance dbReturn];
    }
    return _instance;
}
- (void)setDB:(sqlite3 *)getDB{
    db = getDB;
}
- (BOOL)insertMusicWithBPM:(NSInteger)bpm title:(NSString *)title artist:(NSString *)artist location:(NSString *)location isMusic:(BOOL)isMusic{
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO MUSIC (BPM, Title, Artist, Location, IsMusic) VALUES (%d,'%@','%@','%@',%d)", (int)bpm, title, artist, location, isMusic];
   
    return [self INSERT:insertQuery];
}
- (BOOL)deleteMusicWithMusicID:(NSInteger)musicID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM MUSIC WHERE musicID = %d LIMIT 1",(int)musicID];
    return [self DELETE:deleteQuery];
}
- (BOOL)syncMusic{
//    [self openDB];
    _musicList = [[NSMutableArray alloc]init];
    NSString *resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC"];
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [resolvingQuery UTF8String], -1, &stmt, NULL);
    
    __autoreleasing NSString *errMsg;
    errMsg = [NSString stringWithFormat:@"Error on syncMusic in MUSIC : %s", sqlite3_errmsg(db)];
    NSAssert2(ret == SQLITE_OK, errMsg, ret, NULL);
    
    NSInteger musicID;
    NSInteger BPM;
    char *title;
    char *artist;
    char *location;
    BOOL isMusic;
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        musicID = sqlite3_column_int(stmt, 0);
        BPM = sqlite3_column_int(stmt, 1);
        title = (char *)sqlite3_column_text(stmt, 2);
        NSString *titleString = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
        artist = (char *)sqlite3_column_text(stmt, 3);
        NSString *artistString = [NSString stringWithCString:artist encoding:NSUTF8StringEncoding];
        location = (char *)sqlite3_column_text(stmt, 4);
        NSString *locationString = [NSString stringWithCString:location encoding:NSUTF8StringEncoding];
        isMusic = sqlite3_column_int(stmt, 5);
        
        NSLog(@"musicID = %d , BPM = %d, title = %@, artist = %@, location = %@, isMusic = %s ", (int)musicID, BPM, titleString, artistString, locationString, isMusic == 0 ? "NO" : "YES");
        
        Music *music = [[Music alloc]initWithMusicID:musicID BPM:BPM title:titleString artist:artistString location:locationString isMusic:isMusic];
        
        [_musicList addObject:music];
    }
    sqlite3_finalize(stmt);
    
//    [self closeDB];
    return YES;
}
//FIXME:만약 isExist를 많이 쓴다면  DBManager로 옮길것
- (BOOL)isExistWithlocation:(NSString *)location{
    
    NSString *resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC where location='%@'", location];
    sqlite3_stmt *stmt;
    
//    [self openDB];
    int ret = sqlite3_prepare_v2(db, [resolvingQuery UTF8String], -1, &stmt, NULL);
    
    __autoreleasing NSString *errMsg;
    errMsg = [NSString stringWithFormat:@"Error on isExistWithLocation : %s", sqlite3_errmsg(db)];
    
    NSAssert2(ret == SQLITE_OK, errMsg, ret,NULL);
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        return YES;
    }
    sqlite3_finalize(stmt);
    
//    [self closeDB];
    return NO;
}
- (NSInteger)getNumberOfMusic{
    return [_musicList count];
}
- (Music *)getMusicWithIndex:(NSInteger)index{
    Music *music = _musicList[index];
    return music;
}
- (Music *)getMusicWithMusicID:(NSInteger)musicID{
//    [self openDB];
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC WHERE musicID = %d LIMIT 1",(int)musicID];
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [selectQuery UTF8String], -1, &stmt, NULL);
    
    __autoreleasing NSString *errMsg;
    errMsg = [NSString stringWithFormat:@"Error on getMusicWithMusicID in MUSIC : %s", sqlite3_errmsg(db)];
    NSAssert2(ret == SQLITE_OK, errMsg, ret, NULL);
    
    NSInteger BPM;
    char *title;
    char *artist;
    char *location;
    BOOL isMusic;
    
    if (sqlite3_step(stmt) != SQLITE_ROW)
        return nil;
    
    BPM = sqlite3_column_int(stmt, 1);
    title = (char *)sqlite3_column_text(stmt, 2);
    NSString *titleString = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
    artist = (char *)sqlite3_column_text(stmt, 3);
    NSString *artistString = [NSString stringWithCString:artist encoding:NSUTF8StringEncoding];
    location = (char *)sqlite3_column_text(stmt, 4);
    NSString *locationString = [NSString stringWithCString:location encoding:NSUTF8StringEncoding];
    isMusic = sqlite3_column_int(stmt, 5);
    
    NSLog(@"musicID = %d , BPM = %d, title = %@, artist = %@, location = %@, isMusic = %s ", (int)musicID, BPM, titleString, artistString, locationString, isMusic == 0 ? "NO" : "YES");
    
    Music *music = [[Music alloc]initWithMusicID:musicID BPM:BPM title:titleString artist:artistString location:locationString isMusic:isMusic];
    
    [_musicList addObject:music];
    
    sqlite3_finalize(stmt);
    
//    [self closeDB];
    return music;
}
@end
