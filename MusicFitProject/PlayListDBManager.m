//
//  PlayListDBManager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayListDBManager.h"
@interface PlayListDBManager()
- (NSArray *)getMusicWithMinBPM:(NSInteger)minBPM getMusicWitMaxBPM:(NSInteger)maxBPM;
- (BOOL)deleteAll;
@end;
@implementation PlayListDBManager{
    NSMutableArray *_musicListInPlayList;
}
static PlayListDBManager *_instance = nil;
+ (id)sharedPlayListDBManager{
    if(_instance == nil){
        _instance = [[PlayListDBManager alloc] init];
        //[_instance openDB]; //이미 앞에서 다른 매니저가 open
    }
    
    return _instance;
}

- (BOOL)addPlayListWithMusicID:(NSInteger)musicID{
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO PLAYLIST (musicID) VALUES (%d)",(int)musicID];
    NSLog(@"insertQuery: %@", insertQuery);
    
    char *errorMsg;
    int ret = sqlite3_exec(db,[insertQuery UTF8String], NULL, NULL, &errorMsg);
    
    if(ret != SQLITE_OK){
        NSLog(@"Error on InsertQuery: %s", errorMsg);
        return NO;
    }
    sqlite3_last_insert_rowid(db);
    return YES;
}
- (NSInteger)getMusicInfoInPlayListWithIndex:(NSInteger)index{
    //해당하는 musicID에 대한 Music을 반환
    NSString *musicIDString = _musicListInPlayList[index][@"musicID"];
    
    return [musicIDString intValue];
}
- (BOOL)deletePlayListWithPlayListID:(NSInteger)playListID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM PLAYLIST WHERE PlayListID = %d",(int)playListID];
    char *errorMsg;
    int ret = sqlite3_exec(db, [deleteQuery UTF8String], NULL, NULL, &errorMsg);
    if(ret != SQLITE_OK){
        NSLog(@"Error on DeleteQuery : %s", errorMsg);
        return NO;
    }
    return YES;
}
- (BOOL)deleteAll{
    NSString *AlldeleteQuery = @"TRUNCATE PLAYLIST";
    char *errorMsg;
    int ret = sqlite3_exec(db, [AlldeleteQuery UTF8String], NULL, NULL, &errorMsg);
    if(ret != SQLITE_OK){
        NSLog(@"Error on DeleteAll : %s", errorMsg);
        return NO;
    }
    return YES;
}
- (BOOL)syncPlayList{
    _musicListInPlayList = [[NSMutableArray alloc]init];
    NSString *resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM PLAYLIST"];
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [resolvingQuery UTF8String], -1, &stmt, NULL);
    
    NSAssert2(ret == SQLITE_OK, @"Error on resolving data", ret, sqlite3_errmsg(db));
    
    char *listID;
    char *musicID;
    NSDictionary *musicInfoInPlayList = [[NSDictionary alloc]init];
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        listID = (char *)sqlite3_column_text(stmt, 0);
        musicID = (char *)sqlite3_column_text(stmt, 1);
        musicInfoInPlayList = @{@"listID":[NSString stringWithCString:listID encoding:NSUTF8StringEncoding], @"musicID":[NSString stringWithCString:musicID encoding:NSUTF8StringEncoding]};
        
        NSLog(@"listID= %s, musicID = %s", listID, musicID);
        
        [_musicListInPlayList addObject:musicInfoInPlayList];
    }
    sqlite3_finalize(stmt);
    return YES;
}

- (NSInteger)getNumberOfMusicInPlayList{
    return [_musicListInPlayList count];
}
- (BOOL)addPlayListWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    //리스트를 생성하는 부분이므로 테이블에 내용이 있으면 모두 제거하고
    //새로운 리스트를 생성
    [self deleteAll];
    _musicListInPlayList = [[NSMutableArray alloc]init];
    
    NSArray *musicIDList = [self getMusicWithMinBPM:minBPM getMusicWitMaxBPM:maxBPM];
    NSInteger count = [musicIDList count] -1;
    
    for(int index = 0 ; index < count ; index++){
        if([self addPlayListWithMusicID:[musicIDList[index] intValue]] == NO){
            NSLog(@"addPlayListWithMinBPM... Error!!");
            return NO;
        }
    }
    return YES;
}
- (NSArray *)getMusicWithMinBPM:(NSInteger)minBPM getMusicWitMaxBPM:(NSInteger)maxBPM{
    NSString *resolvingQuery;
    if(maxBPM == 0) //max 설정 안함
        resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC where BPM > %d", (int)minBPM];
    else
        resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC where BPM > %d AND BPM < %d", (int)minBPM, (int)maxBPM];
    
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [resolvingQuery UTF8String], -1, &stmt, NULL);
    
    NSAssert2(ret == SQLITE_OK, @"Error on resolving data", ret, sqlite3_errmsg(db));
    
    NSMutableArray *retArray = [[NSMutableArray alloc]init];
    char *musicID;
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        musicID = (char *)sqlite3_column_text(stmt, 0);
        
        [retArray addObject:[NSString stringWithCString:musicID encoding:NSUTF8StringEncoding]];
    }
    
    sqlite3_finalize(stmt);
    return retArray;
}

@end
