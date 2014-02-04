//
//  MODE_Manager.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DBManager.h"
#import "Mode.h"

@interface ModeDBManager : DBManager
+ (id)sharedModeDBManager;
- (BOOL)insertModeWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM;
- (Mode *)getModeWithIndex:(NSInteger)index;
- (BOOL)deleteModeWithModeID:(NSInteger)index;
- (BOOL)syncMode;
- (NSInteger)getNumberOfMode;
@end
