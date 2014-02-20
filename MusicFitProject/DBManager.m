//
//  DBManager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DBManager.h"
#import "MusicFitPlayer.h"
#import "CalendarDayInfo.h"

#define KEY_LISTID @"listID"
#define KEY_MUSICID @"musicID"
@implementation DBManager{
    NSMutableArray *_curPlayMusicList;
    NSMutableArray *_modeList;
    NSMutableArray *_musicList;
    NSInteger _curModeID;
}
static DBManager *_instance = nil;
+(id)sharedDBManager{
    if (nil == _instance){
        _instance = [[DBManager alloc] init];
       
    }
    return _instance;
}
- (id)init{
    self = [super init];
    if(self){
        _curPlayMusicList = [[NSMutableArray alloc]init];
        _modeList = [[NSMutableArray alloc]init];
        _musicList = [[NSMutableArray alloc]init];
    
        [self createTable];
        _curModeID = [[[NSUserDefaults standardUserDefaults] stringForKey:@"mode_preference"] intValue];
    }
    return self;
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
            char *createQuery_MODE = "CREATE TABLE IF NOT EXISTS MODE (modeID INTEGER PRIMARY KEY, minBPM INTEGER, maxBPM INTEGER DEFAULT 0, Title VARCHAR)";
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
            
            //List DB create
            char *createQuery_List = "CREATE TABLE LIST (listID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, musicID INTEGER NOT NULL, modeID INTEGER NOT NULL)";
            
            ret = sqlite3_exec(db, createQuery_List, NULL, NULL, &errorMsg);
            if( ret != SQLITE_OK){//Music DB create fail
                //                [fileManager removeItemAtPath:dbFilePath error:nil];
                NSLog(@"create List TABLE fail : %s", errorMsg);
                return;
            }
            
            char *createQuery_Calendar = "CREATE TABLE CALENDAR (calendarID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, modeID INTEGER NOT NULL,  ExerTime INTEGER NOT NULL, startDate DATETIME NOT NULL)";
            
            ret = sqlite3_exec(db, createQuery_Calendar, NULL, NULL, &errorMsg);
            if( ret != SQLITE_OK){//Music DB create fail
                //                [fileManager removeItemAtPath:dbFilePath error:nil];
                NSLog(@"create CALENDAR TABLE fail : %s", errorMsg);
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
            NSLog(@"close fail.  rc=%d : %s", rc, sqlite3_errmsg(db));
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



//FIXME: List관련 부분 modeID 추가 필요
- (BOOL)insertListWithArray:(NSArray *)insertArr{
    //indexPath
    int count = (int)[insertArr count];
    if(count == 0){
        NSLog(@"notSelect insertList (addSong)");
        return YES;
    }
    
    sqlite3_stmt *insertStmt;
    char *insetQuery = "INSERT INTO LIST (musicID, modeID) VALUES (?, ?) ";
    [self openDB];
    int ret = sqlite3_prepare_v2(db, insetQuery, -1, &insertStmt, NULL);
    if(ret != SQLITE_OK){
        NSLog(@"error add array: %s", sqlite3_errmsg(db));
        return NO;
    }
    
    for(int index = 0 ; index < count ; index++) {
        
        NSIndexPath *selectIndexPath = insertArr[index];
        NSInteger listIndex = selectIndexPath.row;
        
        NSInteger musicID = [_musicList[listIndex] musicID];
        
        ret = sqlite3_bind_int(insertStmt, 1, (int)musicID);
        ret = sqlite3_bind_int(insertStmt, 2, (int)_curModeID);
        
        ret = sqlite3_step(insertStmt);
        
        ret = sqlite3_reset(insertStmt);
    }
    sqlite3_finalize(insertStmt);
    [self syncList];
    [self closeDB];
    return YES;
}
- (BOOL)deleteListWithArray:(NSArray *)deleteArr{
    //indexPath
    NSInteger count = [deleteArr count];
    sqlite3_stmt *deleteStmt;
    char *deleteQuery = "DELETE FROM LIST WHERE listID = ? ";
    if(count == 0){
        NSLog(@"notSelect deleteList(deleteSong)");
        return YES;
    }

    [self openDB];
    int ret = sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStmt, NULL);
    if(ret != SQLITE_OK){
        NSLog(@"error delete array: %s", sqlite3_errmsg(db));
        [self closeDB];
        return NO;
    }
    MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
    NSInteger curPlayIndex = player.curPlayIndex;
    
    for(int index = 0 ; index < count ; index++) {
        
        NSIndexPath *selectIndexPath = deleteArr[index];
        if(selectIndexPath.section != 0)
            continue;
        
        NSInteger listIndex = selectIndexPath.row;
        if(listIndex < curPlayIndex)
            (player.curPlayIndex)--;
        if(listIndex == curPlayIndex)
            player.playingItemDeleted = YES;
        
        int listID = [_curPlayMusicList[listIndex][@"listID"] intValue];
        
        ret = sqlite3_bind_int(deleteStmt, 1, listID);
        
        ret = sqlite3_step(deleteStmt);
        
        ret = sqlite3_reset(deleteStmt);
    }
    sqlite3_finalize(deleteStmt);
    [self syncList];
    return YES;
}
- (BOOL)deleteListWithModeID:(NSInteger)modeID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM List WHERE modeID = %d",(int)modeID];
    
    [self openDB];
    if(![self DELETE:deleteQuery]){
        NSLog(@"Error in List");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}

- (BOOL)syncList{
    _curPlayMusicList = [[NSMutableArray alloc]init];
    int listID;
    int musicID;
    NSDictionary *ListTableInfo = [[NSDictionary alloc]init];
    //FIXME: select문 where mode id추가
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM List where modeID = %d ORDER BY listID asc",(int)_curModeID];
    sqlite3_stmt *allSelectStmt = nil;
    
    
    [self openDB];
    allSelectStmt = [self SELECT:allSelectQuery];
    if(allSelectQuery == nil){
        
    }
    while (sqlite3_step(allSelectStmt) == SQLITE_ROW) {
        listID = sqlite3_column_int(allSelectStmt, 0);
        musicID = sqlite3_column_int(allSelectStmt, 1);
        ListTableInfo = @{@"listID":[NSString stringWithFormat:@"%d",listID ], @"musicID":[NSString stringWithFormat:@"%d", musicID]};
        
//        NSLog(@"listID= %d, musicID = %d", listID, musicID);
        
        [_curPlayMusicList addObject:ListTableInfo];
    }
    sqlite3_finalize(allSelectStmt);
    
    [self closeDB];
    return YES;
}
//table생성시 필요
- (NSInteger)getNumberOfMusicInList{
    return [_curPlayMusicList count];
}
//index에 해당하는 keyValue(mudicID or listID)를 return
- (NSInteger)getKeyValueInListWithKey:(NSString *)key index:(NSInteger)index{
    NSInteger keyValue ;
    if([_curPlayMusicList count] == 0)
        keyValue = -1;
    else{
        //해당하는 musicID에 대한 Music을 반환
        keyValue = [_curPlayMusicList[index][key] intValue];
    }
    return keyValue;
}

- (void)setUserDefualtMode{
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    [userDefualt setInteger:_curModeID forKey:@"mode_preference"];
    [userDefualt synchronize];
}

- (BOOL)syncModeListWithIndex:(NSInteger)index{
    
    _curPlayMusicList = [[NSMutableArray alloc]init];
    _curModeID = [self getModeIDInMODEWithIndex:index];
    [self setUserDefualtMode];
    
    NSLog(@"선택 modeID : %d", (int)_curModeID);
    NSString *modeListSelectQuery = [NSString stringWithFormat:@"SELECT ListID, musicID FROM LIST where modeID= %d", (int)_curModeID];

    sqlite3_stmt *stmt;

    int musicID;
    int listID;
    NSDictionary *ListTableInfo;
    [self openDB];
    
    stmt = [self SELECT:modeListSelectQuery];
    

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        listID = sqlite3_column_int(stmt, 0);
        musicID = sqlite3_column_int(stmt, 1);
        ListTableInfo = @{@"listID":[NSString stringWithFormat:@"%d",listID ], @"musicID":[NSString stringWithFormat:@"%d", musicID]};
        
//        NSLog(@"listID= %d, musicID = %d", listID, musicID);
        
        [_curPlayMusicList addObject:ListTableInfo];
    }
    sqlite3_finalize(stmt);
    [self closeDB];
    return YES;
}

- (NSInteger)getModeIDInMODEWithIndex:(NSInteger)index{
    return ((Mode *)_modeList[index]).modeID;
}











- (void)initStaticMode{
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT modeID FROM MODE where modeID in (1,2,3,4)"];
    sqlite3_stmt *stmt;

    [self openDB];
    
    int index = 0;
    stmt = [self SELECT:allSelectQuery];
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        index++;
    }
    
    sqlite3_finalize(stmt);
    [self closeDB];
    if(index == 4){
        NSInteger lastestMode = [[[NSUserDefaults standardUserDefaults] stringForKey:@"mode_preference"] intValue];
        
        _curModeID = lastestMode;
        [self syncList];
        return;
    }
    
    if(index != 4){
        //먼저 모든 리스트제거
        _curModeID = 1;
        if([self insertModeWithMinBPM:120 maxBPM:0 title:@"걷기"] == NO){
            [self closeDB];
            return ;
        }
                _curModeID = 2;
        if( [self insertModeWithMinBPM:160 maxBPM:0 title:@"러닝"] == NO){
            [self closeDB];
            return ;
        }
                _curModeID = 3;
        if([self insertModeWithMinBPM:140 maxBPM:0 title:@"조깅,트레드밀"] == NO){
            [self closeDB];
            return ;
        }
                _curModeID = 4;
        if([self insertModeWithMinBPM:130 maxBPM:0 title:@"사이클링"] == NO){
            [self closeDB];
            return ;
        }
        _curModeID = 1;
        [self setUserDefualtMode];
        [self syncList];
    }
}

- (BOOL)insertModeWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM title:(NSString *)title{
    NSString *modeInsertQuery = [NSString stringWithFormat:@"INSERT INTO MODE (minBPM , maxBPM, Title) VALUES (%d, %d, '%@')", (int)minBPM, (int)maxBPM, title];
    [self openDB];
    

    sqlite3_stmt *insertStmt=nil;
    
    const char *insert_stmt = [modeInsertQuery UTF8String];
    sqlite3_prepare_v2(db, insert_stmt,
                       -1, &insertStmt, NULL);
    int ret = sqlite3_step(insertStmt);
    if (ret != SQLITE_DONE){
        NSLog(@"InsertQuery Error : %s", sqlite3_errmsg(db));
        [self closeDB];
        return NO;
    }
    
    sqlite3_finalize(insertStmt);
    //modeInsert 종료
    
    //mode sync
    int index = (int)sqlite3_last_insert_rowid(db)-1;
    
    _modeList = [[NSMutableArray alloc]init];
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM MODE ORDER BY modeID"];
    sqlite3_stmt *stmt;
    
    NSInteger syncModeID;
    NSInteger syncMaxBPM;
    NSInteger syncMinBPM;
    char *syncTitle = nil;
    NSString *syncTitleString;
    [self openDB];
    
    stmt = [self SELECT:allSelectQuery];
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        syncModeID = sqlite3_column_int(stmt, 0);
        syncMinBPM = sqlite3_column_int(stmt, 1);
        syncMaxBPM = sqlite3_column_int(stmt, 2);
        syncTitle = (char *)sqlite3_column_text(stmt, 3);
        if(syncTitle != NULL)
            syncTitleString = [NSString stringWithCString:syncTitle encoding:NSUTF8StringEncoding];
        else
            syncTitleString = @"";
        //        NSLog(@"modeID = %d , minBPM = %d, maxBPM = %d ", (int)modeID, (int)minBPM, (int)maxBPM);
        Mode *mode = [[Mode alloc]initWithModeID:syncModeID minBPM:syncMinBPM maxBPM:syncMaxBPM title:syncTitleString];
        
        [_modeList addObject:mode];
    }
    sqlite3_finalize(stmt);
    //mode sync종료
    
    
    //현재 modeCreate
    Mode *mode = _modeList[index];
    _curModeID = mode.modeID;
    
    //List create 부분
    //insert INTO List (musicID, modeID) select musicID  , @MODEID  From MUSIC
    NSString *listInsertQuery;
    if(maxBPM == 0) //max 설정 안함
        listInsertQuery = [NSString stringWithFormat:@"INSERT INTO List (musicID, modeID) SELECT musicID, %d FROM MUSIC where BPM >= %d ORDER BY title ASC", (int)_curModeID,(int)minBPM];
    else
        listInsertQuery = [NSString stringWithFormat:@"INSERT INTO List (musicID, modeID) SELECT musicID,%d FROM MUSIC where BPM > %d AND BPM < %d ORDER BY title ASC", (int)_curModeID,(int)minBPM, (int)maxBPM];
    
    if(![self INSERT:listInsertQuery]){
        NSLog(@"Error insertModeWithMinBPM - create List part... ");
        [self closeDB];
        return NO;
    }
    //리스트 생성 끝
    
    
////    //현재 리스트로 저장
//    allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM List"];
//    sqlite3_stmt *selectStmt = nil;
//    selectStmt = [self SELECT:allSelectQuery];
//    if(selectStmt == nil){
//        NSLog(@"Error createMusicIDArrayWithBPM... in List ");
//        sqlite3_finalize(selectStmt);
//        [self closeDB];
//        return NO;
//    }
//
//    int musicID;
//    int listID;
//    _curPlayMusicList = [[NSMutableArray alloc]init];
//    NSDictionary *ListTableInfo = [[NSDictionary alloc]init];
//    while (sqlite3_step(selectStmt) == SQLITE_ROW) {
//        listID = sqlite3_column_int(selectStmt, 0);
//        musicID = sqlite3_column_int(selectStmt, 1);
//        ListTableInfo = @{@"listID":[NSString stringWithFormat:@"%d",listID ], @"musicID":[NSString stringWithFormat:@"%d", musicID]};
////
//               NSLog(@"listID= %d, musicID = %d", listID, musicID);
////
//        [_curPlayMusicList addObject:ListTableInfo];
//    }
//    sqlite3_finalize(selectStmt);
    

    [self closeDB];
    return YES;
}
- (NSInteger)getCurModeID{
    return _curModeID;
}
- (BOOL)deleteModeWithModeID:(NSInteger)modeID{
    NSString *modeDeleteQuery = [NSString stringWithFormat:@"DELETE FROM MODE WHERE modeID = %d",(int)modeID];
    NSString *listDeleteQuery = [NSString stringWithFormat:@"DELETE FROM LIST WHERE modeID = %d",(int)modeID];
    [self openDB];
    if(![self DELETE:modeDeleteQuery]){
        NSLog(@"Error in Mode");
        [self closeDB];
        return NO;
    }
    if(![self DELETE:listDeleteQuery]){
        NSLog(@"Error in List");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    
    [self syncMode];
    
    return YES;
}

- (BOOL)syncMode{
    _modeList = [[NSMutableArray alloc]init];
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM MODE ORDER BY modeID"];
    sqlite3_stmt *stmt;
    
    NSInteger modeID;
    NSInteger maxBPM;
    NSInteger minBPM;
    char *title = nil;
    NSString *titleString;
   [self openDB];
    
    stmt = [self SELECT:allSelectQuery];
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        modeID = sqlite3_column_int(stmt, 0);
        minBPM = sqlite3_column_int(stmt, 1);
        maxBPM = sqlite3_column_int(stmt, 2);
        title = (char *)sqlite3_column_text(stmt, 3);
        if(title != NULL)
            titleString = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
        else
            titleString = @"";
//        NSLog(@"modeID = %d , minBPM = %d, maxBPM = %d ", (int)modeID, (int)minBPM, (int)maxBPM);
        Mode *mode = [[Mode alloc]initWithModeID:modeID minBPM:minBPM maxBPM:maxBPM title:titleString];
        
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


- (NSInteger)getCurModeIDIndex{
    Mode *mode;
    for(int index = 0 ;index < [_modeList count] ; index++){
        mode = _modeList[index];
        if(mode.modeID == _curModeID){
            NSLog(@"lastIndex : %d", index);
            return index;
        }
    }
    return -1;
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

- (BOOL)insertMusicWithMusicArr:(NSArray *)musicArr{
    
    int count = (int)[musicArr count];
    
    sqlite3_stmt *insertStmt;
    char *insetQuery = "INSERT INTO MUSIC (BPM, Title, Artist, Location, IsMusic) VALUES (?,?,?,?,?)";
    
    [self openDB];
    int ret = sqlite3_prepare_v2(db, insetQuery, -1, &insertStmt, NULL);
    if(ret != SQLITE_OK){
        NSLog(@"error add array: %s", sqlite3_errmsg(db));
        return NO;
    }
    
    for(int index = 0 ; index < count ; index++) {
        Music *insertMusic = musicArr[index];
        
        ret = sqlite3_bind_int(insertStmt, 1, insertMusic.BPM);
        ret = sqlite3_bind_text(insertStmt, 2, [insertMusic.title UTF8String], -1, nil);
        ret = sqlite3_bind_text(insertStmt, 3, [insertMusic.artist UTF8String], -1, nil);
        ret = sqlite3_bind_text(insertStmt, 4, [insertMusic.location UTF8String], -1, nil);
        ret = sqlite3_bind_int(insertStmt, 5, insertMusic.isMusic);
        ret = sqlite3_step(insertStmt);
        
        ret = sqlite3_reset(insertStmt);
    }
    sqlite3_finalize(insertStmt);
    [self syncList];
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
    NSString *allSelectQuery = [NSString stringWithFormat:@"SELECT * FROM MUSIC ORDER BY title ASC"];
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
- (NSMutableArray *)getListArray{
    if([_curPlayMusicList count]==0)
        return nil;
    return _curPlayMusicList;
}




















- (BOOL)insertCalendarWithExerTime:(NSInteger)exerTime startdate:(NSDate *)startDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"KST"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSString *todayDate = [dateFormatter stringFromDate:startDate];
//    sqlite3_bind_text(saveStmt, 1, [dateString UTF8String] , -1, SQLITE_TRANSIENT);
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO CALENDAR (modeID, ExerTime, startDate) VALUES (%d,%d,'%@')", _curModeID, exerTime, todayDate];
    [self openDB];
    if(![self INSERT:insertQuery]){
        NSLog(@"Error in MUSIC");
        [self closeDB];
        return NO;
    }
    [self closeDB];
    return YES;
}
- (NSDictionary *)getCalendarMonthDicWithMonth:(NSDateComponents *)month{
    NSDictionary *monthInfo;
    sqlite3_stmt *selectStmt;
    
    char *selectQuery = "SELECT ExerTime FROM CALENDAR where startDate>= (?) AND startDate < (?)";
    [self openDB];
    int ret = sqlite3_prepare_v2(db, selectQuery, -1, &selectStmt, NULL);
    if(ret != SQLITE_OK){
        NSLog(@"error add array: %s", sqlite3_errmsg(db));
        return NO;
    }
    
    [month setDay:1];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"KST"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    
    NSString *todayDate = [dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:month]];
    
    NSString *nextDayDate = todayDate;
    int exerCount = 0;
    int exerMinuteCount = 0;
    BOOL alreadyCount = NO;
    for(int index = 1 ; index <= 31 ; index++) {
        todayDate = nextDayDate;
        [month setDay:index+1];
        nextDayDate =  [dateFormatter stringFromDate:[month date]];
        
        ret = sqlite3_bind_text(selectStmt, 1, [todayDate UTF8String], -1,nil);
        ret = sqlite3_bind_text(selectStmt, 2, [nextDayDate UTF8String], -1,nil);
        
        while(sqlite3_step(selectStmt) == SQLITE_ROW){
            if(!alreadyCount){
                exerCount++;
                alreadyCount = YES;
            }
            exerMinuteCount += sqlite3_column_int(selectStmt, 2);
        }
        alreadyCount = NO;
        ret = sqlite3_reset(selectStmt);
    }
    sqlite3_finalize(selectStmt);
    [self closeDB];
    NSLog(@"month : count %d time  %d", exerCount , exerMinuteCount);
    monthInfo = @{@"totalExerCount": [NSNumber numberWithInt:exerCount], @"totalExerMinute":[NSNumber numberWithInt:exerMinuteCount]};
    
    return monthInfo;
}

- (NSArray *)getCalendarMonthInfoWithMonth:(NSDateComponents *)month{
    NSMutableArray *dayArrForMonth = [[NSMutableArray alloc] init];
    sqlite3_stmt *selectStmt;
    
    //하루에 정보 하나씩만 가지고 온다.
    char *selectQuery = "SELECT modeID FROM CALENDAR where startDate>= (?) AND startDate < (?) ORDER BY calendarID DESC Limit 1";
    [self openDB];
    int ret = sqlite3_prepare_v2(db, selectQuery, -1, &selectStmt, NULL);
    if(ret != SQLITE_OK){
        NSLog(@"error add array: %s", sqlite3_errmsg(db));
        return NO;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"KST"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    [month setDay:1];

    
    NSString *todayDate;
    NSString *nextDayDate ;
    int modeID = 0;
    for(int index = 1 ; index <= 31 ; index++) {
        todayDate = [dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:month]];
        [month setDay:index+1];
        nextDayDate = [dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:month]];
        
        ret = sqlite3_bind_text(selectStmt, 1, [todayDate UTF8String], -1,nil);
        ret = sqlite3_bind_text(selectStmt, 2, [nextDayDate UTF8String], -1,nil);
        
        if(sqlite3_step(selectStmt) == SQLITE_ROW){
            modeID = sqlite3_column_int(selectStmt, 0);
        }else{
            modeID = 0;
        }
        [dayArrForMonth addObject:[NSNumber numberWithInt:modeID]];
        ret = sqlite3_reset(selectStmt);
    }
    sqlite3_finalize(selectStmt);
    [self closeDB];
    
    return dayArrForMonth;
}

- (NSArray *)getCalendarDayInfoWithDay:(NSDateComponents *)day{
    sqlite3_stmt *selectStmt;
//    where
    char *selectQuery = "SELECT * FROM CALENDAR where startDate >= (?) AND startDate < (?)";
    [self openDB];
    int ret = sqlite3_prepare_v2(db, selectQuery, -1, &selectStmt, NULL);
    if(ret != SQLITE_OK){
        NSLog(@"error add array: %s", sqlite3_errmsg(db));
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"KST"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    

    [day setHour:0];
    [day setMinute:0];
    NSString *todayDate = [dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:day]];
    [day setDay:[day day]+1];
    NSString *nextDayDate = [dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:day]];
    
  
        ret = sqlite3_bind_text(selectStmt, 1, [todayDate UTF8String], -1,nil);
        ret = sqlite3_bind_text(selectStmt, 2, [nextDayDate UTF8String], -1,nil);
    NSMutableArray *dayArr = [[NSMutableArray alloc]init];
    CalendarDayInfo *dayInfo;
    while(sqlite3_step(selectStmt) == SQLITE_ROW){
            //array로 얻어오기
            int modeID = sqlite3_column_int(selectStmt, 1);
            int exerTime = sqlite3_column_int(selectStmt, 2);
        NSString *date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStmt, 3)];
        NSDate *startDate = [[NSDate alloc]init];
        startDate = [dateFormatter dateFromString:date];
            dayInfo = [[CalendarDayInfo alloc] initWithDate:startDate modeID:modeID exerTime:exerTime];
        
        NSLog(@"SELECT DAYINFO DATA!!!!!!!! date:%@, modeID : %d, exerTime: %d",date, modeID, exerTime);
            [dayArr addObject:dayInfo];
    }
    
    sqlite3_finalize(selectStmt);
    [self closeDB];
    
    return dayArr;
}

@end
