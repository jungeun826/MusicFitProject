//
//  PlayListDBManager.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DBManager.h"

@interface PlayListDBManager : DBManager
+ (id)sharedPlayListDBManager;
- (BOOL)addPlayListWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM;
- (BOOL)addPlayListWithMusicID:(NSInteger)musicID;
- (NSInteger)getMusicInfoInPlayListWithIndex:(NSInteger)index;
- (BOOL)deletePlayListWithPlayListID:(NSInteger)playListID;
- (BOOL)syncPlayList;
- (NSInteger)getNumberOfMusicInPlayList;
//- (BOOL)isExistWithlocation:(NSString *)location;
@end
