//
//  AppDelegate.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 10..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "AppDelegate.h"
#import "DBManager.h"
#import <AVFoundation/AVFoundation.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
//    
//    if (iOSDeviceScreenSize.height == 480) //화면세로길이가 480 (3gs,4, 4s)
//    {
//        // UIStoryboard 생성
//        UIStoryboard *iPhone35Storyboard = [UIStoryboard storyboardWithName:@"Main3.5inch" bundle:nil];
//        // 생성한 UIStoryboard에서  initial view controller를 가져온다.
//        UIViewController *initialViewController = [iPhone35Storyboard instantiateInitialViewController];
//        
//        // 화면크기로 윈도우 생성
//        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        
//        // window의 rootViewController를 스토리보드의 initial view controller로 설정
//        self.window.rootViewController  = initialViewController;
//        
//        // 윈도우 보이기
//        [self.window makeKeyAndVisible];
//    }
//    
//    if (iOSDeviceScreenSize.height == 568) //화면세로길이가 568 (5)
//    {
//        //동일
//        UIStoryboard *iPhone4Storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        
//        UIViewController *initialViewController = [iPhone4Storyboard instantiateInitialViewController];
//        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        self.window.rootViewController  = initialViewController;
//        [self.window makeKeyAndVisible];
//    }
    
//    UIStoryboard *storyboard = nil;
//    UIViewController *initialViewController = nil;
//    
//    if(IS_4_INCH_DEVICE)
//        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    else
//        storyboard = [UIStoryboard storyboardWithName:@"Main3.5inch" bundle:nil];
//    
//    initialViewController = [storyboard instantiateInitialViewController];
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.rootViewController = initialViewController;
//    
//    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application{
//    [viewController alertNotification] setHidden:YES];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
//    [viewController alertNotification] setHidden:YES];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DBManager *temp = [DBManager sharedDBManager];
    [temp closeDB];
}
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived" object:event];
    
    _player = [MusicFitPlayer sharedPlayer];
    _timer = [TimerLabel sharedTimer];
    
//    //    switch (event.subtype) {
//case UIEventSubtypeRemoteControlPlay:
//    if (_player.status != MusicFitPlayerStatusPlaying)
//        [_player play];
//    break;
//    // You get the idea.
//case UIEventSubtypeRemoteControlPause:
//    if (_player.status == MusicFitPlayerStatusPlaying)
//        [
//         default:
//         break;
//         }
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            if (_player.status == MusicFitPlayerStatusPlaying){
                [_player pause];
                if([_timer running] && [_timer fire]){
                    [_timer pause];
                    NSLog(@"timer pause");
                }
            } else {
                [_player play];
                if(![_timer running]&& [_timer fire]){
                    [_timer start];
                    NSLog(@"timer start");
                }
            }
            break;
        case UIEventSubtypeRemoteControlPlay:
            if (_player.status != MusicFitPlayerStatusPlaying){
                [_player play];
                if(![_timer running]&& [_timer fire])
                    [_timer start];
                NSLog(@"timer start");
            }
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            if(_player.status == MusicFitPlayerStatusPlaying){
                [_player nextPlay];
            }
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            if(_player.status == MusicFitPlayerStatusPlaying)
                [_player prevPlay];
            // You get the idea.
            break;
        case UIEventSubtypeRemoteControlStop:
        case UIEventSubtypeRemoteControlPause:
            if (_player.status == MusicFitPlayerStatusPlaying){
                [_player pause];
                if([_timer running]&& [_timer fire])
                    [_timer pause];
                NSLog(@"timer pause");
            }            break;
        default:
            break;
    }
    
}
-(void)remoteControlEventNotification:(NSNotification *)note{
    UIEvent *event = note.object;
    if (event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (_player.status == MusicFitPlayerStatusPlaying){
                    [_player pause];
                } else {
                    [_player play];
                }
                break;
                // You get the idea.
            default:
                break;
        }
    }
}
@end
