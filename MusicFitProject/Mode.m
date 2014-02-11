//
//  MODE.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "Mode.h"
@interface Mode()



@end
@implementation Mode
-(id)initWithModeID:(NSInteger)modeID minBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM title:(NSString *)title{
    self = [super init];
    if(self){
        self.modeID = modeID;
        self.minBPM = minBPM;
        self.maxBPM = maxBPM;
        self.title = title;
    }
    return self;
}
-(NSString *)getStringMaxBPM{
    NSString *maxBPM = [NSString stringWithFormat:@"%d", (int)self.maxBPM];
    return maxBPM;
}
-(NSString *)getStringMinBPM{
    NSString *minBPM = [NSString stringWithFormat:@"%d", (int)self.minBPM];
    return minBPM;
}
@end
