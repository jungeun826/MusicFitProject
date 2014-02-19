//
//  DBManager.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "Mode.h"
#import "Music.h"

@interface DBManager : NSObject{
    sqlite3 *db;
}
+ (id)sharedDBManager;
- (BOOL) openDB;
- (BOOL) closeDB;
- (BOOL) INSERT:(NSString *)insertQuery;
- (BOOL) DELETE:(NSString *)deleteQuery;


//+ (id)sharedPlayListDBManager;

- (BOOL)insertListWithArray:(NSArray *)insertArr;
- (BOOL)deleteListWithArray:(NSArray *)deleteArr;

- (BOOL)syncList;
- (NSInteger)getNumberOfMusicInList;
- (NSInteger)getKeyValueInListWithKey:(NSString *)key index:(NSInteger)index;
- (BOOL)syncModeListWithIndex:(NSInteger)index;


//+ (id)sharedModeDBManager;
-(void)initStaticMode;
-(BOOL)insertModeWithMinBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM title:(NSString *)title;
- (NSInteger)getCurModeID;
- (Mode *)getModeWithIndex:(NSInteger)index;
- (BOOL)deleteModeWithIndex:(NSInteger)index;
- (BOOL)syncMode;
- (NSInteger)getNumberOfMode;
//+ (id)sharedMusicDBManager;
- (BOOL)insertMusicWithBPM:(NSInteger)bpm title:(NSString *)title artist:(NSString *)artist location:(NSString *)location isMusic:(BOOL)isMusic;
- (BOOL)insertMusicWithMusicArr:(NSArray *)musicArr;

- (Music *)getMusicWithIndex:(NSInteger)index;
- (Music *)getMusicWithMusicID:(NSInteger)musicID;
- (BOOL)deleteMusicWithMusicID:(NSInteger)musicID;
- (BOOL)syncMusic;
- (NSInteger)getNumberOfMusic;
- (BOOL)isExistWithlocation:(NSString *)location;
- (NSMutableArray *)getListArray;




- (BOOL)insertCalendarWithExerTime:(NSInteger)exerTime startdate:(NSDate *)startDate;
- (NSArray *)getCalendarDayInfoWithDay:(NSDateComponents *)day;
- (NSArray *)getCalendarMonthInfoWithMonth:(NSDateComponents *)month;
- (NSDictionary *)getCalendarMonthDicWithMonth:(NSDateComponents *)month;
@end
