//
//  MODE_Manager.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ModeDBManager.h"
@implementation ModeDBManager{
    NSMutableArray *_modeList;
}
static ModeDBManager *_instance = nil;
+ (id)sharedModeDBManager{
    if (nil == _instance) {
        _instance = [[ModeDBManager alloc] init];
        _instance->_modeList = [[NSMutableArray alloc]init];
    }
    return _instance;
}
- (BOOL)insertModeWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO MODE (minBPM , maxBPM) VALUES (%d, %d)", (int)minBPM, (int)maxBPM];
    if(![self INSERT:insertQuery]){
        NSLog(@"Error in Mode");
        return NO;
    }
    return YES;
}
- (BOOL)deleteModeWithModeID:(NSInteger)modeID{
    NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM MODE WHERE mode_id = %d",(int)modeID];
    
    return [self DELETE:deleteQuery];
}
- (BOOL)syncMode{
    _modeList = [[NSMutableArray alloc]init];
    NSString *resolvingQuery = [NSString stringWithFormat:@"SELECT * FROM MODE"];
    sqlite3_stmt *stmt;
    
    NSInteger mode_id;
    NSInteger maxBPM;
    NSInteger minBPM;

//    [self openDB];
    
    int ret = sqlite3_prepare_v2(db, [resolvingQuery UTF8String], -1, &stmt, NULL);
    
    __autoreleasing NSString *errMsg;
    errMsg = [NSString stringWithFormat:@"Error on syncMode in MODE : %s", sqlite3_errmsg(db)];
    NSAssert2(ret == SQLITE_OK, errMsg, ret, NULL);
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        mode_id = sqlite3_column_int(stmt, 0);
        minBPM = sqlite3_column_int(stmt, 1);
        maxBPM = sqlite3_column_int(stmt, 2);
        
        NSLog(@"mode id = %d , minBPM = %d, maxBPM = %d ", (int)mode_id, (int)minBPM, (int)maxBPM);
        Mode *mode = [[Mode alloc]initWithMode_id:mode_id minBPM:minBPM maxBPM:maxBPM];
        
        [_modeList addObject:mode];
    }
    sqlite3_finalize(stmt);
    
//    [self closeDB];
    return YES;
}
- (NSInteger)getNumberOfMode{
    return [_modeList count];
}

- (Mode *)getModeWithIndex:(NSInteger)index{
    Mode *mode = _modeList[index];
    return mode;
}
@end
