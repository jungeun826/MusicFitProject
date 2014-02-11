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
    _DBManager = [DBManager sharedDBManager];
    [self performSelector:@selector(animationMainImage) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(getITunseSyncMusic) withObject:nil afterDelay:0.2];

}
//아이튠즈에서 음악에 대한 정보를 가져와 DB화 하는 함수를 부름
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

        
        if([_DBManager isExistWithlocation:location])
            continue;
        
        
        NSString *title = [NSString stringWithFormat:@"%@",[music valueForProperty:MPMediaItemPropertyTitle]];
        title =[title stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
        NSString *artist = [NSString stringWithFormat:@"%@",[music valueForProperty:                        MPMediaItemPropertyArtist]];
        artist =[artist stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
        
        //유효 bpm범위 처리를 해야함.
//        NSInteger BPM = [[music valueForProperty:MPMediaItemPropertyBeatsPerMinute] intValue];
        
        //FIXME: bpm 분석 후 얻어오는 부분 추가시 위의 주석이랑 같이 처리
        NSInteger BPM = index*3 +2;
        
        //FIXME:무조건 isMusic을 true로 넣는다 고쳐야함.
        [_DBManager insertMusicWithBPM:BPM title:title artist:artist location:location isMusic:YES];
    }
    
    [_DBManager initStaticMode];
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
