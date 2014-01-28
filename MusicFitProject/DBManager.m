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
        char *createQuery_MODE = "CREATE TABLE IF NOT EXISTS MODE (mode_id INTEGER PRIMARY KEY, MIN_BPM INTEGER, MAX_BPM INTEGER)";
        char *errorMsg ;
        
        ret = sqlite3_exec(db, createQuery_MODE, NULL, NULL, &errorMsg);
        if( ret != SQLITE_OK){
            [fileManager removeItemAtPath:dbFilePath error:nil];
            NSLog(@"create MODE TABLE fail : %s", errorMsg);
            return NO;
        }
    }
    
    return YES;
}
@end
