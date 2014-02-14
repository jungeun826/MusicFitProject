//
//  ViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 10..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DBManager.h"
#import "PlayerViewController.h"
#import "FirstViewController.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@end

@implementation FirstViewController{
    DBManager *_DBManager;
    BOOL _repeat;
}
- (BOOL)loadFromUserDefaultTutorial{
    BOOL tutorialSetting = [[NSUserDefaults standardUserDefaults] boolForKey:@"tutorial_preference"];
    return tutorialSetting;
}

//FIXME: 튜토리얼 다시 안보기 설정시 분기를 이용해 메인/튜토리얼 로 넘어가게 하기.
- (void)movePlayerOrTutorial{
     AppDelegate *app = [[UIApplication sharedApplication]delegate];
    if([self loadFromUserDefaultTutorial]==NO){
        //NO : 안볼래요를 누른 경우
        PlayerViewController *initVC = [self.storyboard instantiateViewControllerWithIdentifier:@"player"];
        [initVC setSwipeController];
        app.window.rootViewController = initVC;
    }else{
        FirstViewController *initVC = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
        app.window.rootViewController = initVC;
    }
}
- (void)animationMainImage{
    [UIView animateWithDuration:1.0 animations:^{
        self.mainImageView.alpha = 0;
        self.mainImageView.backgroundColor = [UIColor clearColor];
//        [self getITunseSyncMusic];
    }completion:nil];
    [self performSelector:@selector(movePlayerOrTutorial) withObject:nil afterDelay:0.2];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//페이지 로드시
//메인 페이지를 어느정도 보여 준 후 튜토리얼로 넘어갈 수 있도록 함.
- (void)viewDidLoad{
    [super viewDidLoad];
    [NSThread detachNewThreadSelector:@selector(thread) toTarget:self withObject:nil];
    [self performSelector:@selector(animationMainImage) withObject:nil afterDelay:1.0];
}
- (void)thread{
    DBManager *dbManager = [DBManager sharedDBManager];
    
    [dbManager initStaticMode];
}
@end
