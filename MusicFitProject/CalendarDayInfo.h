//
//  CalendarDayInfo.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 15..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarDayInfo : NSObject

@property (strong, nonatomic,readonly) NSDate *exerStartDate;
@property (nonatomic,readonly) NSInteger modeID;
@property (nonatomic, readonly) NSInteger exerTime;
- (id)initWithDate:(NSDate *)startDate modeID:(NSInteger)modeID exerTime:(NSInteger)exerTime;
- (NSString *)getStartTime;
- (NSString *)getExerTime;
- (NSInteger)getDay;
@end

