//
//  PlayListDBManager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayListDBManager.h"
@interface PlayListDBManager()
- (NSArray *)createMusicIDArrayWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM;
- (BOOL)deleteAll;
@end;
@implementation PlayListDBManager{
    NSMutableArray *_musicListInPlayList;
}
static PlayListDBManager *_instance = nil;
+ (id)sharedPlayListDBManager{
    if(_instance == nil){
        _instance = [[PlayListDBManager alloc] init];
        _instance->_musicListInPlayList = [[NSMutableArray alloc]init];
    }
    return _instance;
}
- (BOOL)insertPlayListWithMusicID:(NSInteger)musicID{
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO PLAYLIST (musicID) VALUES (%d)",(int)musicID];
    
    if(![self INSERT:insertQuery]){
        NSLog(@"Error in PlayList");
        return NO;
    }
    return YES;
}
- (BOOL)deletePlayListWithPlayListID:(NSInteger)playListID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM PLAYLIST WHERE PlayListID = %d",(int)playListID];
    
    return [self DELETE:deleteQuery];
}
- (BOOL)deleteAll{
    if([_musicListInPlayList count] == 0)
        return YES;
    
    NSString *allDeleteQuery = @"DELETE FROM PLAYLIST";
    
    return [self DELETE:allDeleteQuery];
}
- (BOOL)syncPlayList{
    _musicListInPlayList = [[NSMutableArray alloc]init];
    int listID;
    int musicID;
    NSDictionary *musicInfoInPlayList = [[NSDictionary alloc]init];
    NSString *resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM PLAYLIST"];
    sqlite3_stmt *stmt;
    
    
//    [self openDB];
    int ret = sqlite3_prepare_v2(db, [resolvingQuery UTF8String], -1, &stmt, NULL);
    
    __autoreleasing NSString *errMsg;
    errMsg = [NSString stringWithFormat:@"Error on syncPlayList in PLAYLIST : %s", sqlite3_errmsg(db)];
    NSAssert2(ret == SQLITE_OK, errMsg, ret, NULL);

    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        listID = sqlite3_column_int(stmt, 0);
        musicID = sqlite3_column_int(stmt, 1);
        musicInfoInPlayList = @{@"listID":[NSString stringWithFormat:@"%d",listID ], @"musicID":[NSString stringWithFormat:@"%d", musicID]};
        
        NSLog(@"listID= %d, musicID = %d", listID, musicID);
        
        [_musicListInPlayList addObject:musicInfoInPlayList];
    }
    sqlite3_finalize(stmt);
//    [self closeDB];
    
    return YES;
}
//music테이블에 있는 bpm에 대한 값을 이용해 걸러낸 후 해당하는 musicID를 저장.
//후에 그 뮤직아이디를 리스트 아이디와 같이 저장.
- (NSArray *)createMusicIDArrayWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    [self deleteAll];
    
//    [self openDB];
    sqlite3_stmt *selectStmt = nil;
    NSMutableArray *retArr = [[NSMutableArray alloc]init];
    NSString *selectQuery;
    
    if(maxBPM == 0) //max 설정 안함
        selectQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC where BPM > %d", (int)minBPM];
    else
        selectQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC where BPM > %d AND BPM < %d", (int)minBPM, (int)maxBPM];
    NSLog(@"select Query: %@", selectQuery);
    
    
    int ret = sqlite3_prepare_v2(db, [selectQuery UTF8String], -1, &selectStmt, NULL);
    
    __autoreleasing NSString *errMsg;
    errMsg = [NSString stringWithFormat:@"Error on createMusicIDArrayWithBPM... in PLAYLIST : %s", sqlite3_errmsg(db)];
    NSAssert2(ret == SQLITE_OK, errMsg, ret, NULL);
    
    
    int musicID;
    while (sqlite3_step(selectStmt) == SQLITE_ROW) {
        musicID = sqlite3_column_int(selectStmt, 0);
        [retArr addObject:[NSString stringWithFormat:@"%d", musicID]];
    }
    sqlite3_finalize(selectStmt);
//    [self closeDB];
    
    return retArr;
}
- (BOOL)createPlayListWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    NSArray *tempArr = [self createMusicIDArrayWithMinBPM:minBPM maxBPM:maxBPM];
    
    int count = (int)[tempArr count];
    int musicID;
    
    
    for(int index = 0 ; index < count ; index++){
        musicID = [tempArr[index] intValue];
        NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO PLAYLIST (musicID) VALUES (%d)",(int)musicID];
        [self INSERT:insertQuery];
    }
    [self syncPlayList];
    return YES;
}

- (NSInteger)getNumberOfMusicInPlayList{
    return [_musicListInPlayList count];
}

- (NSInteger)getMusicInfoInPlayListWithIndex:(NSInteger)index{
    //해당하는 musicID에 대한 Music을 반환
    NSString *musicIDString = _musicListInPlayList[index][@"musicID"];
    
    return [musicIDString intValue];
}
@end
