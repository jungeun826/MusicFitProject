//
//  MODE.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "Mode.h"

@implementation Mode
-(id)initWithMode_id:(NSInteger)mode_id minBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    self = [super init];
    if(self){
        self.mode_id = mode_id;
        self.minBPM = minBPM;
        self.maxBPM = maxBPM;
    }
    return self;
}
-(NSString *)getStringMaxBPM{
    NSString *maxBPM = [NSString stringWithFormat:@"%d", self.maxBPM];
    return maxBPM;
}
-(NSString *)getStringMinBPM{
    NSString *minBPM = [NSString stringWithFormat:@"%d", self.minBPM];
    return minBPM;
}
@end
