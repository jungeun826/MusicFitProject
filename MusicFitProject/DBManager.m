//
//  DBManager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager{
}
static DBManager *_instance = nil;
+(id)sharedDBManager{
    if (nil == _instance){
        _instance = [[DBManager alloc] init];
        [_instance createTable];
    }
    return _instance;
}

- (void)setDB:(sqlite3 *)getDB{
    db = getDB;
}
- (void)createTable{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    
    NSString *_databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"db.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            int ret;
            //Mode DB create
            char *createQuery_MODE = "CREATE TABLE IF NOT EXISTS MODE (modeID INTEGER PRIMARY KEY, MIN_BPM INTEGER, MAX_BPM INTEGER DEFAULT 0)";
            char *errorMsg ;
            
            ret = sqlite3_exec(db, createQuery_MODE, NULL, NULL, &errorMsg);
            if( ret != SQLITE_OK){//Mode DB create fail
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
//    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *dbFilePath = [docPath stringByAppendingPathComponent:@"db.sqlite"];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    BOOL existFileFlag = [fileManager fileExistsAtPath:dbFilePath];
//    NSString *path2=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"db.sqlite"];
//    existFileFlag =[fileManager copyItemAtPath:path2 toPath:dbFilePath error:nil];

//    if(existFileFlag == NO){
//       
//        
//        int ret;
//        //Mode DB create
//        char *createQuery_MODE = "CREATE TABLE IF NOT EXISTS MODE (modeID INTEGER PRIMARY KEY, MIN_BPM INTEGER, MAX_BPM INTEGER DEFAULT 0)";
//        char *errorMsg ;
//        
//        ret = sqlite3_exec(db, createQuery_MODE, NULL, NULL, &errorMsg);
//        if( ret != SQLITE_OK){//Mode DB create fail
//            [fileManager removeItemAtPath:path2 error:nil];
//            NSLog(@"create MODE TABLE fail : %s", errorMsg);
//            return;
//        }
//        
//        //Music DB create
//        char *createQuery_MUSIC = "CREATE  TABLE  IF NOT EXISTS MUSIC (Music_ID INTEGER PRIMARY KEY, BPM INTEGER DEFAULT 0, Title VARCHAR, Artist VARCHAR, Location VARCHAR, IsMusic BOOL DEFAULT YES)";
//        
//        ret = sqlite3_exec(db, createQuery_MUSIC, NULL, NULL, &errorMsg);
//        if( ret != SQLITE_OK){//Music DB create fail
//            [fileManager removeItemAtPath:dbFilePath error:nil];
//            NSLog(@"create MUSIC TABLE fail : %s", errorMsg);
//            return;
//        }
//        
//        //PlayList DB create
//        char *createQuery_PLAYLIST = "CREATE  TABLE PLAYLIST (listID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , musicID INTEGER NOT NULL)";
//        
//        ret = sqlite3_exec(db, createQuery_PLAYLIST, NULL, NULL, &errorMsg);
//        if( ret != SQLITE_OK){//Music DB create fail
//            [fileManager removeItemAtPath:dbFilePath error:nil];
//            NSLog(@"create PLAYLIST TABLE fail : %s", errorMsg);
//            return;
//        }
//    }
    [self openDB];
}

- (BOOL)openDB{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbFilePath = [docPath stringByAppendingPathComponent:@"db.sqlite"];
    
    int ret = sqlite3_open([dbFilePath UTF8String], &db);
    //int ret = sqlite3_open([_databasePath UTF8String], &db);
    if ( ret !=SQLITE_OK ){
        NSLog(@"open fail");
        return NO;
    }
    
    return YES;
}
//- (BOOL) closeDB{
//    //sqlite3_clear_bindings(<#sqlite3_stmt *#>)
//    if (db){
//        NSLog(@"closing....");
//        
//        int rc = sqlite3_close(db);
//        NSLog(@"close rc=%d", rc);
//        
//        if (rc == SQLITE_BUSY){
//            NSLog(@"SQLITE_BUSY: not all statements cleanly finalized");
//            
//            sqlite3_stmt *stmt;
//            while ((stmt = sqlite3_next_stmt(db, 0x00)) != 0){
//                NSLog(@"finalizing stmt");
//                sqlite3_finalize(stmt);
//            }
//            
//            rc = sqlite3_close(db);
//        }
//        
//        if (rc != SQLITE_OK){
//            NSLog(@"close fail.  rc=%d", rc);
//            return NO;
//        }
//    }
//    return YES;
//}
- (BOOL) INSERT:(NSString *)insertQuery{
//    [self openDB];
//
//    NSLog(@"insertQuery: %@", insertQuery);
//    
//    char *errorMsg;
//    int ret = sqlite3_exec(db,[insertQuery UTF8String], NULL, NULL, &errorMsg);
//    
//    if(ret != SQLITE_OK){
//        NSLog(@"Error insertQuery : %s", errorMsg);
//        return NO;
//    }
//    sqlite3_last_insert_rowid(db);
    sqlite3_stmt *stmt=nil;
    
    const char *insert_stmt = [insertQuery UTF8String];
    sqlite3_prepare_v2(db, insert_stmt,
                       -1, &stmt, NULL);
    int ret = sqlite3_step(stmt);
    if (ret != SQLITE_DONE){
        NSLog(@"InsertQuery Error : %s", sqlite3_errmsg(db));
        return NO;
    }
    
    sqlite3_finalize(stmt);
    
//    [self closeDB];
    return YES;
}
- (BOOL) DELETE:(NSString *)deleteQuery{
//    [self openDB];
    char *errorMsg;
    int ret = sqlite3_exec(db, [deleteQuery UTF8String], NULL, NULL, &errorMsg);
    if(ret != SQLITE_OK){
        NSLog(@"Error on DeleteQuery : %s", errorMsg);
        return NO;
    }
//    [self closeDB];
    return YES;
}
- (sqlite3 *)dbReturn{
    return db;
}
@end
