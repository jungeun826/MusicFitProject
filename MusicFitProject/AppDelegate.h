//
//  AppDelegate.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 10..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicFitPlayer.h"
#import "TimerLabel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property MusicFitPlayer *player;
@property TimerLabel *timer;
@end
