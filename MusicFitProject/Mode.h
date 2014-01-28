//
//  MODE.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mode : NSObject
@property NSInteger maxBPM;
@property NSInteger minBPM;
@property NSInteger mode_id;

-(id)initWithMode_id:(NSInteger)mode_id minBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM;
-(NSString *)getStringMinBPM;
-(NSString *)getStringMaxBPM;
@end
