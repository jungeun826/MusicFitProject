//
//  TutorialViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 11..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "TutorialViewController.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "PlayerViewController.h"
#import "BPMAnalysis.h"

#define HIDDEN_X 400
#define TUTORIAL_IMAGENUM 4
#define MAX_WIDTH 320
#define MAX_HEIGHT 470
@interface TutorialViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *BPMContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *tutorialScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *skipView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@end

@implementation TutorialViewController{
    BOOL _repeat;
}
//FIXME:메인 페에지를 그림만 하나 있는 뷰 컨트롤러로 할 것인지 아니면 튜토리얼 위에 덮는 방식으로 가야할지 결정
//페이지가 움직일 때 해당하는 그림을 보여주기 위함
- (void) pageChangeValue:(id)sender{
    UIPageControl *pageControl = (UIPageControl *) sender;
    [self.tutorialScrollView setContentOffset:CGPointMake(pageControl.currentPage*MAX_WIDTH, 0) animated:YES];
}
//해당페이지의 그림을 미리 로드시켜 놓을때 쓰는 함수.
-(void)loadContentsPage:(int)pageNo{
//    if(pageNo<0 ||pageNo < self.pageControl.currentPage || pageNo >= TUTORIAL_IMAGENUM)
//        return;
    
    NSString *fileName = [NSString stringWithFormat:@"tutorial_%d.png", pageNo+1];
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:@"png"];
    UIImage *image = [UIImage imageNamed:fileName];

    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(MAX_WIDTH* pageNo, 0, MAX_WIDTH, MAX_HEIGHT);
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = image;
    [self.tutorialScrollView addSubview:imageView];
}
//스크롤뷰가 넘어갈 때 로드됨...?
//페이지 컨트롤러 표시를 바꾸기 위해 추가
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float width = scrollView.frame.size.width;
    float offsetX = scrollView.contentOffset.x;
    int pageNO = floor(offsetX / width);
    
    if(pageNO == 3)
        self.skipView.hidden = NO;

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
    dispatch_async(dispatch_get_main_queue(), ^{
        BPMAnalysis *bpmAnalysis = [[BPMAnalysis alloc]init];
        _repeat = [bpmAnalysis getiTunseMusic];
    });
    do{
        if(count == 5)
            _repeat = NO;
        
    }while(!_repeat);
    //탈출하면 분석이 진행된 것이므로 사라지는 애니매이션과 같이 플레이 뷰로 옮기도록 함
    [self performSelector:@selector(movePlayView) withObject:nil afterDelay:0.3];
    [self syncUserDefaultTutorial];
}
- (void)syncUserDefaultTutorial{
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    [userDefualt setBool:NO forKey:@"tutorial_preference"];
    [userDefualt synchronize];
}
//튜토리얼에서 플레이 화면으로 넘어갈 때 실행되어야 하는 것.
-(void)movePlayView{
    AppDelegate *app = [[UIApplication sharedApplication]delegate];
    //    NSLog(@"changed root");
    //    app.window.rootViewController = playerVC;
    UIStoryboard *currentStoryboard = self.storyboard;
    
    PlayerViewController *initVC = [currentStoryboard instantiateViewControllerWithIdentifier:@"player"];
    [initVC setSwipeController];
    app.window.rootViewController = initVC;
}
//메인 화면이 등장할 때 스크롤뷰가 움직이는 것에 대한 설정부분.
- (void)settingScrollView{
    self.tutorialScrollView.pagingEnabled = YES;
    self.tutorialScrollView.contentSize = CGSizeMake(MAX_WIDTH*TUTORIAL_IMAGENUM, MAX_HEIGHT);
}

//무한루프를 돌면서 분석중임을 알려주는 애니매이션
- (void)animationBPManalysis{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
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
     self.skipView.hidden = YES;
       //페이지 컨트롤러에 대한 이벤트를 추가함
    [self.pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    //미리 모든 페이지 로드해놓는다.
    for(int index = 0; index < TUTORIAL_IMAGENUM ; index++)
                [self loadContentsPage:index];
    
    [self settingScrollView];
}
@end
