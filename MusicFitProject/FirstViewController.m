//
//  ViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 10..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "FirstViewController.h"
#import "PlayViewController.h"
#import "AppDelegate.h"
#import "SwipeViewController.h"
#import "SwipeController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicDBManager.h"

#define HIDDEN_X 400
#define TUTORIAL_IMAGENUM 4
#define MAX_WIDTH 320
#define MAX_HEIGHT 548
@interface FirstViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *BPMContainer;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *tutorialScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;

@end

@implementation FirstViewController{
    MusicDBManager *_musicDBManager;
    BOOL _repeat;
}
//FIXME:메인 페에지를 그림만 하나 있는 뷰 컨트롤러로 할 것인지 아니면 튜토리얼 위에 덮는 방식으로 가야할지 결정
//페이지가 움직일 때 해당하는 그림을 보여주기 위함
- (void) pageChangeValue:(id)sender {
    UIPageControl *pageControl = (UIPageControl *) sender;
    [self.tutorialScrollView setContentOffset:CGPointMake(pageControl.currentPage*MAX_WIDTH, 0) animated:YES];
}
//해당페이지의 그림을 미리 로드시켜 놓을때 쓰는 함수.
-(void)loadContentsPage:(int)pageNo{
    if(pageNo<0 ||pageNo < self.pageControl.currentPage || pageNo >= TUTORIAL_IMAGENUM)
        return;
    
    NSString *fileName = [NSString stringWithFormat:@"Tutorial_%d", pageNo];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(MAX_WIDTH* pageNo, 0, MAX_WIDTH, MAX_HEIGHT);
    [self.tutorialScrollView addSubview:imageView];
}
//스크롤뷰가 넘어갈 때 로드됨...?
//페이지 컨트롤러 표시를 바꾸기 위해 추가
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float width = scrollView.frame.size.width;
    float offsetX = scrollView.contentOffset.x;
    int pageNO = floor(offsetX / width);
    self.pageControl.currentPage = pageNO;
}

//튜토리얼 스킵 버튼을 누르면 실행되는 것
- (IBAction)skipTutorial:(id)sender {
    if(self.BPMContainer.hidden == YES)
        self.BPMContainer.hidden = NO;
    _repeat = YES;
    //분석 시작을 위해 것을 부름
    [self animationBPManalysis];
    int count = 0;
    do{
        if(count == 5)
            _repeat = NO;
        //분석이 완료되었다는 것을 알 수 있는 함수를 부른 후
        //그 함수가 리턴하는 값이 YES이면 탈출하도록 함
        // perform을 이용해 delay를 주어 반복 실행하도록 되나........?
        //애니매이션?
    }while(!_repeat);
    //탈출하면 분석이 진행된 것이므로 사라지는 애니매이션과 같이 플레이 뷰로 옮기도록 함
    [self performSelector:@selector(movePlayView) withObject:nil afterDelay:0.3*7];
}
- (BOOL)loadFromUserDefaultTutorial{
    NSString *tutorialSetting = [[NSUserDefaults standardUserDefaults] valueForKey:@"tutorial_preference"];
    if([tutorialSetting isEqualToString:@"NO"])
        return NO;
    else
        return YES;
}
//튜토리얼에서 플레이 화면으로 넘어갈 때 실행되어야 하는 것.
-(void)movePlayView{
//    PlayViewController *playerVC =(PlayViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"player"];
//    
    AppDelegate *app = [[UIApplication sharedApplication]delegate];
//    NSLog(@"changed root");
//    app.window.rootViewController = playerVC;
    UIStoryboard *currentStoryboard = self.storyboard;
    
    UIViewController *initialViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"swipe"];
    SwipeViewController *swipeVC = [[SwipeViewController alloc] initWithFrame:initialViewController.view.frame];
    
    UIViewController *modeViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"mode"];
    modeViewController.row = 0;
    modeViewController.col = 0;
    
    UIViewController *playerViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"player"];
    playerViewController.row = 0;
    playerViewController.col = 1;
    
    UIViewController *playListViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"playList"];
    playListViewController.row = 0;
    playListViewController.col = 2;
    
    UIViewController *myViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"my"];
    myViewController.row = 0;
    myViewController.col = 3;
    
    NSArray *controllers = @[ modeViewController, playerViewController,playListViewController, myViewController];
    [swipeVC setControllers:controllers];
    
    app.window.rootViewController = swipeVC;
    [swipeVC moveRightAnimated:NO];
}
//메인 화면이 등장할 때 스크롤뷰가 움직이는 것에 대한 설정부분.
- (void)settingScrollView{
    self.tutorialScrollView.pagingEnabled = YES;
    self.tutorialScrollView.contentSize = CGSizeMake(MAX_WIDTH*TUTORIAL_IMAGENUM, MAX_HEIGHT);
}
//FIXME: 튜토리얼 다시 안보기 설정시 분기를 이용해 메인/튜토리얼 로 넘어가게 하기.
- (void)animationMainImage{
    if([self loadFromUserDefaultTutorial]==NO){
        [self movePlayView];
    }else{
        [self settingScrollView];
        [UIView animateWithDuration:1.0 animations:^{
            self.mainImageView.alpha = 0;
            self.mainImageView.backgroundColor = [UIColor clearColor];
            }completion:^(BOOL finished){
            [self.mainImageView removeFromSuperview];
        }];
    }
}
//무한루프를 돌면서 분석중임을 알려주는 애니매이션
- (void)animationBPManalysis{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.progressImageView setTransform:CGAffineTransformRotate(self.progressImageView.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (_repeat) {
            [self animationBPManalysis];
        }
    }];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//페이지 로드시
//메인 페이지를 어느정도 보여 준 후 튜토리얼로 넘어갈 수 있도록 함.
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self performSelector:@selector(animationMainImage) withObject:nil afterDelay:2];
    
    [self.pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    for(int index = 0; index < TUTORIAL_IMAGENUM ; index++)
        [self loadContentsPage:index];
    
    _musicDBManager = [MusicDBManager sharedMusicDBManager];
    [self getITunseSyncMusic];
}
- (void)getITunseSyncMusic{
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    
    NSInteger count = [itemsFromGenericQuery count] -1;
    
    for(int index = 0 ; index < count ; index++){
        
        MPMediaItem *music = [itemsFromGenericQuery objectAtIndex:index];
        
        NSString *stringURL = [[music valueForProperty:MPMediaItemPropertyAssetURL] absoluteString];
        NSString *location = [stringURL substringFromIndex:32];
        
        if([_musicDBManager isExistWithlocation:location])
            continue;
        
        
        NSString *title = [NSString stringWithFormat:@"%@",[music valueForProperty:MPMediaItemPropertyTitle]];
        title =[title stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
        NSString *artist = [NSString stringWithFormat:@"%@",[music valueForProperty:                        MPMediaItemPropertyArtist]];
        artist =[artist stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
        
        NSInteger BPM = [[music valueForProperty:MPMediaItemPropertyBeatsPerMinute] intValue];
        
        //FIXME:무조건 isMusic을 true로 넣는다 고쳐야함.
        [_musicDBManager addMusicWithBPM:BPM title:title artist:artist location:location isMusic:YES];
    }
}
@end
