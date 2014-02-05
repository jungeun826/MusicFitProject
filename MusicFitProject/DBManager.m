//
//  DBManager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager
static DBManager *_instance = nil;
- (BOOL)openDB{
    if (nil == _instance) {
        _instance = [[DBManager alloc] init];
        [_instance openDB];
    }
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbFilePath = [docPath stringByAppendingPathComponent:@"db.sqlite"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existFileFlag = [fileManager fileExistsAtPath:dbFilePath];
    
    int ret = sqlite3_open([dbFilePath UTF8String], &db);
    
    if ( ret !=SQLITE_OK )
        return NO;
    
    if(existFileFlag == NO){
        //Mode DB create
        char *createQuery_MODE = "CREATE TABLE IF NOT EXISTS MODE (modeID INTEGER PRIMARY KEY, MIN_BPM INTEGER, MAX_BPM INTEGER DEFAULT 0함)";
        char *errorMsg ;
        
        ret = sqlite3_exec(db, createQuery_MODE, NULL, NULL, &errorMsg);
        if( ret != SQLITE_OK){//Mode DB create fail
            [fileManager removeItemAtPath:dbFilePath error:nil];
            NSLog(@"create MODE TABLE fail : %s", errorMsg);
            return NO;
        }
        
        //Music DB create
        char *createQuery_MUSIC = "CREATE  TABLE  IF NOT EXISTS MUSIC (Music_ID INTEGER PRIMARY KEY, BPM INTEGER DEFAULT 0, Title VARCHAR, Artist VARCHAR, Location VARCHAR, IsMusic BOOL DEFAULT YES)";
        
        ret = sqlite3_exec(db, createQuery_MUSIC, NULL, NULL, &errorMsg);
        if( ret != SQLITE_OK){//Music DB create fail
            [fileManager removeItemAtPath:dbFilePath error:nil];
            NSLog(@"create MUSIC TABLE fail : %s", errorMsg);
            return NO;
        }
        
        //PlayList DB create
        char *createQuery_PLAYLIST = "CREATE  TABLE PLAYLIST (listID INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , musicID INTEGER NOT NULL)";
        
        ret = sqlite3_exec(db, createQuery_PLAYLIST, NULL, NULL, &errorMsg);
        if( ret != SQLITE_OK){//Music DB create fail
            [fileManager removeItemAtPath:dbFilePath error:nil];
            NSLog(@"create PLAYLIST TABLE fail : %s", errorMsg);
            return NO;
        }
    }
    return YES;
}
@end
