//
//  MODE_Manager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ModeManager.h"
@implementation ModeManager{
    NSMutableArray *_modeList;
}
static ModeManager *_instance = nil;
+ (id)sharedModeManager{
    if (nil == _instance) {
        _instance = [[ModeManager alloc] init];
        _instance->_modeList = [[NSMutableArray alloc]init];
        [_instance openDB];
    }
    return _instance;
}

- (BOOL)addModeWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO MODE (MIN_BPM , MAX_BPM) VALUES (%d, %d)", (int)minBPM, (int)maxBPM];
    
    NSLog(@"insertQuery : %@", insertQuery);
    char *errorMsg;
    int ret = sqlite3_exec(db, [insertQuery UTF8String], nil, nil, &errorMsg);
    
    if(ret != SQLITE_OK){
        NSLog(@"Error on InsertQuery : %s", errorMsg);
        return NO;
    }
    
    sqlite3_last_insert_rowid(db);
    return YES;
}
- (Mode *)getModeWithIndex:(NSInteger)index{
    Mode *mode = _modeList[index];
    return mode;
}
- (BOOL)deleteModeWithModeID:(NSInteger)index{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM MODE WHERE mode_id = %d",(int)index];
    NSLog(@"delete query : %@", deleteQuery);
    
    char *errorMsg;
    int ret = sqlite3_exec(db, [deleteQuery UTF8String], NULL, NULL, &errorMsg);
    if(ret != SQLITE_OK){
        NSLog(@"Error on DeleteQuery : %s", errorMsg);
        return NO;
    }
    return YES;
}
- (BOOL)syncMode{
    _modeList = [[NSMutableArray alloc]init];
    NSString *resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM MODE"];
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [resolvingQuery UTF8String], -1, &stmt, NULL);
    
    NSAssert2(ret == SQLITE_OK, @"Error on resolving data", ret, sqlite3_errmsg(db));
    
    NSInteger mode_id;
    NSInteger maxBPM;
    NSInteger minBPM;
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        mode_id = sqlite3_column_int(stmt, 0);
        minBPM = sqlite3_column_int(stmt, 1);
        maxBPM = sqlite3_column_int(stmt, 2);
        
        NSLog(@"mode id = %d , minBPM = %d, maxBPM = %d ", (int)mode_id, (int)minBPM, (int)maxBPM);
        Mode *mode = [[Mode alloc]initWithMode_id:mode_id minBPM:minBPM maxBPM:maxBPM];
        
        [_modeList addObject:mode];
    }
    sqlite3_finalize(stmt);
    return YES;
}
- (NSInteger)getNumberOfMode{
    return [_modeList count];
}
@end
