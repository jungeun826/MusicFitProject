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
#import "DBManager.h"

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
    DBManager *_DBManager;
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
    [self performSelector:@selector(movePlayView) withObject:nil afterDelay:0.3];
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
    
    UIViewController *playViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"play"];
    playViewController.row = 0;
    playViewController.col = 1;
    
    UIViewController *playListViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"playList"];
    playListViewController.row = 0;
    playListViewController.col = 2;
    
    UIViewController *myViewController = [currentStoryboard instantiateViewControllerWithIdentifier:@"my"];
    myViewController.row = 0;
    myViewController.col = 3;
    
    NSArray *controllers = @[ modeViewController, playViewController,playListViewController, myViewController];
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
    
    //메인 페이지가 2초 후에 애니매이션으로 사라지도록 하기 위해
    //performSelector를 사용함.
    [self performSelector:@selector(animationMainImage) withObject:nil afterDelay:2];
    
    //페이지 컨트롤러에 대한 이벤트를 추가함
    [self.pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    //미리 모든 페이지 로드해놓는다.
    for(int index = 0; index < TUTORIAL_IMAGENUM ; index++)
        [self loadContentsPage:index];
    
    //FIXME : 음악 로드 시점에 대해 명확해지면 고쳐야함.
    //지금은 처음 시작시 모든 음악에 대한 정보를 가지고 오는 것으로 하였으므로 이 부분에
    //music관련 디비 매니저가 필요함.
    _DBManager = [DBManager sharedDBManager];
   

    //아이튠즈에서 음악에 대한 정보를 가져와 DB화 하는 함수를 부름
    [self getITunseSyncMusic];
}
- (void)getITunseSyncMusic{
    //아이튠즈 미디어들을 모두 가져와 초기화함
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    //아이튠즈 미디어들을 어레이에 넣어 접근을 용이하게 함
    NSArray *itemsFromGenericQuery = [everything items];
    //
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
        [_musicDBManager insertMusicWithBPM:BPM title:title artist:artist location:location isMusic:YES];
    }
    /*
     가슴 시린 이야기 (Feat. 용준형 of BEAST), 휘성, 8605142450541980905
     가질 수 없는 너, 하이니, 8605142450541980900
     거짓말 거짓말 거짓말, 이적, 8605142450541980878
     겨울 고백, 성시경, 박효신, 서인국, 빅스, 여동생, 8605142450541980860
     그대가 분다, 엠씨 더 맥스, 8605142450541980874
     그대와 함께, B1A4, 8605142450541980910
     그때 우리, 엠씨 더 맥스, 8605142450541980872
     그런 줄 알았어, 지아(Zia), 8605142450541980884
     그렇게 당해놓고 (Feat. 마부스 Of 일렉트로보이즈), 임창정, 8605142450541980879
     그리워해요, 투애니원(2NE1), 8605142450541980894
     금요일에 만나요 (Feat. 장이정 Of HISTORY), 아이유, 8605142450541980866
     꾸리스마스, 크레용팝, 8605142450541980890
     나란놈이란, 임창정, 8605142450541980880
     날 위한 이별, 디아, 8605142450541980838
     내 생각날 거야 (Narr. 이시영), 거미, 8605142450541980825
     내일은 없어, 트러블메이커, 8605142450541980895
     너 밖에 몰라 (One Way Love), 효린, 8605142450541980903
     너를, 브라운 아이드 소울(Brown Eyed Soul), 8605142450541980854
     너만 보여 (Feat. 범키), 톱밥, 8605142450541980892
     너만을 느끼며, 정우 & 유연석 & 손호준, 8605142450541980881
     너에게, 성시경, 8605142450541980859
     너에게만, 범키, 버벌진트, 8605142450541980853
     노래가 늘었어, 에일리, 8605142450541980869
     눈물이 맘을 훔쳐서, 에일리, 8605142450541980870
     답이 없었어, 홍대광, 8605142450541980902
     둘도 없는 바보, 레드애플(Led apple), 8605142450541980840
     링가 링가 (RINGA LINGA), 태양, 8605142450541980891
     만약에 말야 (전우성 Solo), 노을, 8605142450541980833
     몹쓸 노래 (Feat. 칸토), 럼블 피쉬, 8605142450541980839
     미스터리 (Feat. San E), 박지윤, 8605142450541980848
     바람이 분다 (영화 '신이 보낸 사람' 삽입곡), 포맨(4men), 8605142450541980896
     */
//    NSArray *tempMP3 = @[@{@"title":@"가슴 시린 이야기 (Feat. 용준형 of BEAST)",@"artist":@"휘성",@"location":@"8605142450541980905"},@{@"title":@"가질 수 없는 너",@"artist":@"하이니",@"location":@"8605142450541980900"},                         @{@"title":@"금요일에 만나요 (Feat. 장이정 Of HISTORY)",@"artist":@"아이유",@"location":@"8605142450541980866"}];
//    NSString *location ;
//    NSString *title ;
//    NSString *artist ;
//    NSInteger BPM;
//    int count = (int)[tempMP3 count];
//    for(int index = 0 ; index < count ; index++){
//        location= tempMP3[index][@"location"];
//        
//        if([_musicDBManager isExistWithlocation:location])
//            continue;
//        
//        title = tempMP3[index][@"title"];
//        artist = tempMP3[index][@"artist"];
//        
//        BPM = index*73 +30;
//        
//        //FIXME:무조건 isMusic을 true로 넣는다 고쳐야함.
//        [_musicDBManager insertMusicWithBPM:BPM title:title artist:artist location:location isMusic:YES];
//    }
}
@end
