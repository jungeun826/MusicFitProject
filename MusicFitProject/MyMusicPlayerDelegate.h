//
//  MusicPlayerDelegate.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 7..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MusicPlayerDelegate <NSObject>
//sender가 넘겨준 정보를 가지고 현재 플레이 할 음악을 변경함.
- (void)changeMusic:(id)sender;
- (void)nextMusic;
- (void)preMusic;
@end
