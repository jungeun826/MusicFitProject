//
//  ViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 10..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//
#define AUBIO_UNSTABLE 1

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "FirstViewController.h"
#import "BPMAnalysis.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImgView;
@property (weak, nonatomic) IBOutlet UIView *progressView;

@end

@implementation FirstViewController{
    BOOL _repeat;
}
- (BOOL)loadFromUserDefaultTutorial{
    [[NSUserDefaults standardUserDefaults] synchronize];
    BOOL tutorialShow = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tutorial_preference"] boolValue];
    
//    [[[NSUserDefaults standardUserDefaults] objectForKey:@"switchValue"] boolValue];

    return tutorialShow;
}

//FIXME: 튜토리얼 다시 안보기 설정시 분기를 이용해 메인/튜토리얼 로 넘어가게 하기.
- (void)movePlayerOrTutorial{
    BOOL tutorialShow = [self loadFromUserDefaultTutorial];
    if(tutorialShow==NO){
        dispatch_async(dispatch_get_main_queue(), ^ {
            [UIView animateWithDuration:0.3 delay:1.5 options:UIViewAnimationCurveLinear animations:^{
                self.progressView.alpha = 1.0;
            }completion:nil];
            
            [self.progressImgView startAnimating];
        });
        //NO : 안볼래요를 누른 경우
        [self performSelector:@selector(actBPMAnalysis) withObject:nil afterDelay:1.0];
    }else{
        [self animationMainImageTotutorial];
    }
}
- (void)animationMainImageTotutorial{
    [UIView animateWithDuration:1.0 animations:^{
        self.mainImageView.alpha = 0;
        self.mainImageView.backgroundColor = [UIColor clearColor];
        //        [self getITunseSyncMusic];
    }completion:^(BOOL finished) {
        AppDelegate *app = [[UIApplication sharedApplication]delegate];
        FirstViewController *initVC = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
        app.window.rootViewController = initVC;
    }];
//    [self performSelector:@selector(movePlayerOrTutorial) withObject:nil afterDelay:0.2];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//페이지 로드시
//메인 페이지를 어느정도 보여 준 후 튜토리얼로 넘어갈 수 있도록 함.
- (void)viewDidLoad{
    [super viewDidLoad];
    self.progressView.alpha = 0.0;
    
    self.progressImgView.animationImages =@[[UIImage imageNamed:@"progressive1.png"],[UIImage imageNamed:@"progressive2.png"],[UIImage imageNamed:@"progressive3.png"],[UIImage imageNamed:@"progressive4.png"],[UIImage imageNamed:@"progressive5.png"],[UIImage imageNamed:@"progressive6.png"],[UIImage imageNamed:@"progressive7.png"],[UIImage imageNamed:@"progressive8.png"]];
    self.progressImgView.animationDuration=0.7;
    self.progressImgView.animationRepeatCount=INFINITY;
    
    [self performSelector:@selector(movePlayerOrTutorial) withObject:nil afterDelay:0.0];
}
- (void)actBPMAnalysis{
    BPMAnalysis *bpmAnalysis = [[BPMAnalysis alloc]init];
    [bpmAnalysis getiTunseMusic];
    
//    [self.progressImgView stopAnimating];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.progressView.alpha = 0.0;
    }completion:^(BOOL finished) {
        if(finished){
            AppDelegate *app = [[UIApplication sharedApplication]delegate];
            PlayerViewController *initVC = [self.storyboard instantiateViewControllerWithIdentifier:@"player"];
            [initVC setSwipeController];
            app.window.rootViewController = initVC;
            //        [self getITunseSyncMusic];
        }
    }];
}
@end
