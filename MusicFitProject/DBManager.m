//
//  DBManager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager{
    NSMutableArray *_musicListInPlayList;
    NSMutableArray *_modeList;
    NSMutableArray *_musicList;
}
static DBManager *_instance = nil;
+(id)sharedDBManager{
    if (nil == _instance){
        _instance = [[DBManager alloc] init];
        _instance->_musicListInPlayList = [[NSMutableArray alloc]init];
        _instance->_modeList = [[NSMutableArray alloc]init];
        _instance->_musicList = [[NSMutableArray alloc]init];
        
        [_instance createTable];
    }
    return _instance;
}

- (void)createTable{
    NSString *docPath;
    
    // Get the documents directory
    docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Build the path to the database file
    
    NSString *DBPath = [[NSString alloc]initWithString: [docPath stringByAppendingPathComponent:@"db.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: DBPath ] == NO){
        const char *dbpath = [DBPath UTF8String];
        
        if (sqlite3_open(dbpath,&db) == SQLITE_OK){
            int ret;
            //Mode DB create
            char *createQuery_MODE = "CREATE TABLE IF NOT EXISTS MODE (modeID INTEGER PRIMARY KEY, minBPM INTEGER, maxBPM INTEGER DEFAULT 0)";
            char *errorMsg ;
            
            ret = sqlite3_exec(db, createQuery_MODE, NULL, NULL, &errorMsg);
            if( ret != SQLITE_OK){
                //Mode DB create fail
//                [fileManager removeItemAtPath:path2 error:nil];
                NSLog(@"create MODE TABLE fail : %s", errorMsg);
                return;
            }
            
            //Music DB create
            char *createQuery_MUSIC = "CREATE TABLE IF NOT EXISTS MUSIC (musicID INTEGER PRIMARY KEY, BPM INTEGER DEFAULT 0, Title VARCHAR, Artist VARCHAR, Location VARCHAR, IsMusic BOOL DEFAULT YES)";
            
            ret = sqlite3_exec(db, createQuery_MUSIC, NULL, NULL, &errorMsg);
            if( ret != SQLITE_OK){//Music DB create fail
//                [fileManager removeItemAtPath:dbFilePath error:nil];
                NSLog(@"create MUSIC TABLE fail : %s", errorMsg);
                return;
            }
            
            //PlayList DB create
            char *createQuery_PLAYLIST = "CREATE TABLE PLAYLIST (listID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, musicID INTEGER NOT NULL)";
            
            ret = sqlite3_exec(db, createQuery_PLAYLIST, NULL, NULL, &errorMsg);
            if( ret != SQLITE_OK){//Music DB create fail
//                [fileManager removeItemAtPath:dbFilePath error:nil];
                NSLog(@"create PLAYLIST TABLE fail : %s", errorMsg);
                return;
            }
            
            sqlite3_close(db);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (BOOL)openDB{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbFilePath = [docPath stringByAppendingPathComponent:@"db.sqlite"];
    
    int ret = sqlite3_open([dbFilePath UTF8String], &db);
    if ( ret !=SQLITE_OK ){
        NSLog(@"open fail");
        return NO;
    }
    return YES;
}
- (BOOL) closeDB{
    if (db){
        int rc = sqlite3_close(db);
//        NSLog(@"close rc=%d", rc);
        
        if (rc == SQLITE_BUSY){
            NSLog(@"SQLITE_BUSY: not all statements cleanly finalized");
            
            sqlite3_stmt *stmt;
            while ((stmt = sqlite3_next_stmt(db, 0x00)) != 0){
//                NSLog(@"finalizing stmt");
                sqlite3_finalize(stmt);
            }
            
            rc = sqlite3_close(db);
        }
        
        if (rc != SQLITE_OK){
            NSLog(@"close fail.  rc=%d", rc);
            return NO;
        }
    }
    return YES;
}
- (BOOL) INSERT:(NSString *)insertQuery{
    sqlite3_stmt *stmt=nil;
    
    const char *insert_stmt = [insertQuery UTF8String];
    sqlite3_prepare_v2(db, insert_stmt,
                       -1, &stmt, NULL);
    int ret = sqlite3_step(stmt);
    if (ret != SQLITE_DONE){
        NSLog(@"InsertQuery Error : %s", sqlite3_errmsg(db));
        return NO;
    }else
//        NSLog(@"insert Query : %@", insertQuery);
    
    sqlite3_finalize(stmt);
    
    return YES;
}
- (BOOL) DELETE:(NSString *)deleteQuery{
    sqlite3_stmt *stmt=nil;
    const char *deleteStmt = [deleteQuery UTF8String];
    sqlite3_prepare_v2(db, deleteStmt,
                       -1, &stmt, NULL);
    int ret = sqlite3_step(stmt);
    if (ret != SQLITE_DONE){
        NSLog(@"DeleteQuery Error : %s", sqlite3_errmsg(db));
        return NO;
    }else
//        NSLog(@"delete Query : %@", deleteQuery);
    
    sqlite3_finalize(stmt);
    return YES;
}
- (sqlite3 *)dbReturn{
    return db;
}
- (sqlite3_stmt *) SELECT:(NSString *)selectQuery{
    sqlite3_stmt *stmt=nil;
    //    SELECT * FROM ( A테이블 left join B테이블 on  A테이블.칼럼 = B테이블.칼럼 )
    int ret = sqlite3_prepare_v2(db, [selectQuery UTF8String], -1, &stmt, NULL);
    
    if(ret != SQLITE_OK){
        NSLog(@"Error on selectQuery: %s",sqlite3_errmsg(db));
        return nil;
    }else
//        NSLog(@"select Query: %@", selectQuery);
    return stmt;
}







- (BOOL)insertPlayListWithMusicID:(NSInteger)musicID{
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO PLAYLIST (musicID) VALUES (%d)",(int)musicID];
    
    [self openDB];
    if(![self INSERT:insertQuery]){
        NSLog(@"Error in PlayList");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}
- (BOOL)deletePlayListWithPlayListID:(NSInteger)playListID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM PLAYLIST WHERE PlayListID = %d",(int)playListID];
    
    [self openDB];
    if(![self DELETE:deleteQuery]){
        NSLog(@"Error in PLAYLIST");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}
//- (BOOL)deleteAll{
//    if([_musicListInPlayList count] == 0)
//        return YES;
//    
//    NSString *allDeleteQuery = @"DELETE FROM PLAYLIST";
//    [self openDB];
//    if(![self DELETE:allDeleteQuery]){
//        NSLog(@"Error in PLAYLIST");
//        [self closeDB];
//        return NO;
//    }
//    [self closeDB];
//    return YES;
//}
- (BOOL)syncPlayList{
    _musicListInPlayList = [[NSMutableArray alloc]init];
    int listID;
    int musicID;
    NSDictionary *playListTableInfo = [[NSDictionary alloc]init];
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM PLAYLIST ORDER BY listID asc"];
    sqlite3_stmt *allSelectStmt = nil;
    
    
    [self openDB];
    allSelectStmt = [self SELECT:allSelectQuery];
    if(allSelectQuery == nil){
        
    }
    while (sqlite3_step(allSelectStmt) == SQLITE_ROW) {
        listID = sqlite3_column_int(allSelectStmt, 0);
        musicID = sqlite3_column_int(allSelectStmt, 1);
        playListTableInfo = @{@"listID":[NSString stringWithFormat:@"%d",listID ], @"musicID":[NSString stringWithFormat:@"%d", musicID]};
        
//        NSLog(@"listID= %d, musicID = %d", listID, musicID);
        
        [_musicListInPlayList addObject:playListTableInfo];
    }
    sqlite3_finalize(allSelectStmt);
    
    [self closeDB];
    return YES;
}
//music테이블에 있는 bpm에 대한 값을 이용해 걸러낸 후 해당하는 musicID를 저장.
//후에 그 뮤직아이디를 리스트 아이디와 같이 저장.
- (BOOL)createPlayListWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{

    NSString *allDeleteQuery = @"DELETE FROM PLAYLIST";
    [self openDB];
    if(![self DELETE:allDeleteQuery]){
        NSLog(@"Error in PLAYLIST");
        [self closeDB];
        return NO;
    }
    
    NSString *insertQuery;
    if(maxBPM == 0) //max 설정 안함
        insertQuery = [NSString stringWithFormat:@"INSERT INTO PLAYLIST (musicID) SELECT musicID FROM MUSIC where BPM > %d ORDER BY title ASC", (int)minBPM];
    else
        insertQuery = [NSString stringWithFormat:@"INSERT INTO PLAYLIST (musicID) SELECT musicID FROM MUSIC where BPM > %d AND BPM < %d ORDER BY title ASC", (int)minBPM, (int)maxBPM];
    
    if(![self INSERT:insertQuery]){
        NSLog(@"Error createMusicIDArrayWithBPM... in PLAYLIST ");
        [self closeDB];
        return NO;
    }
    
    NSString *allSelectQuery = @"SELECT * FROM PLAYLIST";
    sqlite3_stmt *selectStmt = nil;
    selectStmt = [self SELECT:allSelectQuery];
    if(selectStmt == nil){
        NSLog(@"Error createMusicIDArrayWithBPM... in PLAYLIST ");
        sqlite3_finalize(selectStmt);
        [self closeDB];
        return NO;
    }
    
    int musicID;
    int listID;
    _musicListInPlayList = [[NSMutableArray alloc]init];
    NSDictionary *playListTableInfo = [[NSDictionary alloc]init];
    while (sqlite3_step(selectStmt) == SQLITE_ROW) {
        listID = sqlite3_column_int(selectStmt, 0);
        musicID = sqlite3_column_int(selectStmt, 1);
        playListTableInfo = @{@"listID":[NSString stringWithFormat:@"%d",listID ], @"musicID":[NSString stringWithFormat:@"%d", musicID]};
        
//        NSLog(@"listID= %d, musicID = %d", listID, musicID);
        
        [_musicListInPlayList addObject:playListTableInfo];
    }
    sqlite3_finalize(selectStmt);
    
    [self closeDB];
    return YES;
}
//- (BOOL)createPlayListWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
//    NSArray *tempArr = [self createMusicIDArrayWithMinBPM:minBPM maxBPM:maxBPM];
//    
//    int count = (int)[tempArr count];
//    int musicID;
//    
//    
//    for(int index = 0 ; index < count ; index++){
//        musicID = [tempArr[index] intValue];
//        NSString *insertQuery = [NSString stringWithFormat:@"",(int)musicID];
//        [self INSERT:insertQuery];
//    }
//    
//    return YES;
//}

- (NSInteger)getNumberOfMusicInPlayList{
    return [_musicListInPlayList count];
}

- (NSInteger)getMusicInfoInPlayListWithIndex:(NSInteger)index{
    NSInteger musicID ;
    if([_musicListInPlayList count] == 0)
        musicID = -1;
    else{
        //해당하는 musicID에 대한 Music을 반환
        musicID = [_musicListInPlayList[index][@"musicID"] intValue];
    }
    
//    [self openDB];
//    NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC where musicID = %d", musicID];
//    sqlite3_stmt *stmt = NULL;
//    stmt = [self SELECT:selectQuery];
//    
//    
//    
//    [self closeDB];
    return musicID;
}










- (BOOL)insertModeWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO MODE (minBPM , maxBPM) VALUES (%d, %d)", (int)minBPM, (int)maxBPM];
    [self openDB];
    if(![self INSERT:insertQuery]){
        NSLog(@"Error in Mode");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}
- (BOOL)deleteModeWithModeID:(NSInteger)modeID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM MODE WHERE modeID = %d",(int)modeID];
    [self closeDB];
    if(![self DELETE:deleteQuery]){
        NSLog(@"Error in Mode");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}
- (BOOL)syncMode{
    _modeList = [[NSMutableArray alloc]init];
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM MODE"];
    sqlite3_stmt *stmt;
    
    NSInteger modeID;
    NSInteger maxBPM;
    NSInteger minBPM;
    
    [self openDB];
    
    stmt = [self SELECT:allSelectQuery];
    
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        modeID = sqlite3_column_int(stmt, 0);
        minBPM = sqlite3_column_int(stmt, 1);
        maxBPM = sqlite3_column_int(stmt, 2);
        
//        NSLog(@"modeID = %d , minBPM = %d, maxBPM = %d ", (int)modeID, (int)minBPM, (int)maxBPM);
        Mode *mode = [[Mode alloc]initWithModeID:modeID minBPM:minBPM maxBPM:maxBPM];
        
        [_modeList addObject:mode];
    }
    sqlite3_finalize(stmt);
    
    [self closeDB];
    return YES;
}
- (NSInteger)getNumberOfMode{
    return [_modeList count];
}

- (Mode *)getModeWithIndex:(NSInteger)index{
    Mode *mode = _modeList[index];
    return mode;
}














- (BOOL)insertMusicWithBPM:(NSInteger)bpm title:(NSString *)title artist:(NSString *)artist location:(NSString *)location isMusic:(BOOL)isMusic{
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO MUSIC (BPM, Title, Artist, Location, IsMusic) VALUES (%d,'%@','%@','%@',%d)", (int)bpm, title, artist, location, isMusic];
    [self openDB];
    if(![self INSERT:insertQuery]){
        NSLog(@"Error in MUSIC");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}
- (BOOL)deleteMusicWithMusicID:(NSInteger)musicID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM MUSIC WHERE musicID = %d",(int)musicID];
    [self openDB];
    if(![self DELETE:deleteQuery]){
        NSLog(@"Error in MUSIC");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}
- (BOOL)syncMusic{
    _musicList = [[NSMutableArray alloc]init];
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC"];
    sqlite3_stmt *stmt = nil;
   
    [self openDB];
    stmt = [self SELECT:allSelectQuery];
    if(stmt == nil){
        NSLog(@"Error on syncMusic");
        [self closeDB];
        return NO;
    }
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
        
//        NSLog(@"musicID = %d , BPM = %d, title = %@, artist = %@, location = %@, isMusic = %s ", (int)musicID, (int)BPM, titleString, artistString, locationString, isMusic == 0 ? "NO" : "YES");
        
        Music *music = [[Music alloc]initWithMusicID:musicID BPM:BPM title:titleString artist:artistString location:locationString isMusic:isMusic];
        
        [_musicList addObject:music];
    }
    sqlite3_finalize(stmt);
    
    [self closeDB];
    return YES;
}
//FIXME:만약 isExist를 많이 쓴다면  DBManager로 옮길것
- (BOOL)isExistWithlocation:(NSString *)location{
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT location FROM MUSIC where location='%@'", location];
    sqlite3_stmt *stmt = nil;
    
    [self openDB];
    stmt = [self SELECT:selectQuery];
    if(stmt == nil){
        NSLog(@"Error on isExistWithLocation in MUSIC");
        [self closeDB];
        return NO;
    }
    
    if(sqlite3_step(stmt) != SQLITE_ROW) {
        sqlite3_finalize(stmt);
        [self closeDB];
        return NO;
    }
    
    sqlite3_finalize(stmt);
    [self closeDB];
    return YES;
}
- (NSInteger)getNumberOfMusic{
    return [_musicList count];
}
- (Music *)getMusicWithIndex:(NSInteger)index{
    Music *music = _musicList[index];
    return music;
}
- (Music *)getMusicWithMusicID:(NSInteger)musicID{
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC WHERE musicID = %d LIMIT 1",(int)musicID];
    sqlite3_stmt *stmt = nil;
    
    [self openDB];
    stmt = [self SELECT:selectQuery];
    if(stmt == nil){
        NSLog(@"Error on getMusicWithMusicID in MUSIC");
        [self closeDB];
        return nil;
    }
    
    NSInteger BPM;
    char *title;
    char *artist;
    char *location;
    BOOL isMusic;
    
    if (sqlite3_step(stmt) != SQLITE_ROW){
        sqlite3_finalize(stmt);
        [self closeDB];

        return nil;
    }
    
    BPM = sqlite3_column_int(stmt, 1);
    title = (char *)sqlite3_column_text(stmt, 2);
    NSString *titleString = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
    artist = (char *)sqlite3_column_text(stmt, 3);
    NSString *artistString = [NSString stringWithCString:artist encoding:NSUTF8StringEncoding];
    location = (char *)sqlite3_column_text(stmt, 4);
    NSString *locationString = [NSString stringWithCString:location encoding:NSUTF8StringEncoding];
    isMusic = sqlite3_column_int(stmt, 5);
    
//    NSLog(@"musicID = %d , BPM = %d, title = %@, artist = %@, location = %@, isMusic = %s ", (int)musicID, (int)BPM, titleString, artistString, locationString, isMusic == 0 ? "NO" : "YES");
    
    Music *music = [[Music alloc]initWithMusicID:musicID BPM:BPM title:titleString artist:artistString location:locationString isMusic:isMusic];
    
    sqlite3_finalize(stmt);
    [self closeDB];
    return music;
}


- (NSMutableArray *)getPlayListArray{
    if([_musicListInPlayList count]==0)
        return nil;
    return _musicListInPlayList;
}
@end
