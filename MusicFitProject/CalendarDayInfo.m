//
//  CalendarDayInfo.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 15..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "CalendarDayInfo.h"

@implementation CalendarDayInfo

- (id)initWithDate:(NSDate *)startDate modeID:(NSInteger)modeID exerTime:(NSInteger)exerTime{
    self = [super init];
    if(self){
        _exerStartDate = startDate;
        _modeID = modeID;
        _exerTime = exerTime;
    }

    return self;
}
- (NSString *)getStartTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"KST"]];
    dateFormatter.dateFormat = @"HH:mm";
    
    NSString *startTimeString = [dateFormatter stringFromDate:self.exerStartDate];
    
    return startTimeString;
}
- (NSString *)getExerTime{
    NSInteger minute = self.exerTime%60;
    NSInteger hour = self.exerTime/60;
    NSString *exerTimeString = [NSString stringWithFormat:@"%2d:%2d", (int)hour, (int)minute];
    return exerTimeString;
}
- (NSInteger)getDay{
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self.exerStartDate];
    
    return [day day];
}
@end
