//
//  ModeViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ModeViewController.h"
#import "DBManager.h"
#import "AddedModeCell.h"
#import "StaticModeCell.h"
#import "PlayViewController.h"
#import "AppDelegate.h"
#import "PlayListDBManager.h"
#import "PlayerViewController.h"

#define STATICCELL_NUM 4
#define STATIC_SECTION 0
#define ADDMODE_SECTION 1
#define CUSTOMIZE_SECTION 2
#define HIDDEN_Y 600
#define MARGIN_Y 100

@interface ModeViewController () <AddedModeDelegate, UIAlertViewDelegate>{
     UIScrollView *viewsContainer;
}
@property (weak, nonatomic) IBOutlet UIView *customModeView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *maxBPM;
@property (weak, nonatomic) IBOutlet UITextField *minBPM;
@property (weak, nonatomic) IBOutlet UITableView *modeTable;

- (IBAction)saveCustomMode:(id)sender;
- (IBAction)cancleCustomMode:(id)sender;
@end

@implementation ModeViewController{
    NSArray *_staticMode;
    DBManager *_DBManager;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"return key press");
    [textField resignFirstResponder];
    return YES;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0) //고정 모드 4개
        return STATICCELL_NUM;
    else if(section ==1)//추가된 모드
        return [_DBManager  getNumberOfMode];
    else//커스터마이징할 모드
        return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    StaticModeCell *staticCell;
    //addedCell;
   // UITableViewCell *cell;
    switch (indexPath.section){
        case STATIC_SECTION:{
            StaticModeCell *staticCell = [tableView dequeueReusableCellWithIdentifier:@"STATICMODE_CELL" forIndexPath:indexPath];
            NSString *mode =_staticMode[indexPath.row][@"modeTitle"];
            NSString *minBPM = _staticMode[indexPath.row][@"minBPM"];
            [staticCell setWithImageName:@"cycle.png" title: mode minBPM:minBPM];
            NSLog(@"%@,  %@",_staticMode[indexPath.row][@"modeTitle"], _staticMode[indexPath.row][@"minBPM"]);
            return staticCell;
        }
        case ADDMODE_SECTION:{
            AddedModeCell *addedCell = [tableView dequeueReusableCellWithIdentifier:@"ADDEDMODE_CELL"];
            Mode *mode = [_DBManager getModeWithIndex:indexPath.row];
            
            [addedCell setWithminBPM:[mode getStringMinBPM] maxBPM:[mode getStringMaxBPM]];
            addedCell.delegate = self;
            return addedCell;
        }
        default:{
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CUSTOMIZE_CELL"];
            return cell;
        }
    }
}
- (void)syncPlayer{
    [self.childViewControllers[0] playListSync];
}
- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //커스텀이 아닌 경우 해당 셀에 대한 mode정보를 얻어온 후 해당하는 범위의 bpm을 찾아 리스트를 생성한다.
    switch (indexPath.section){
        case STATIC_SECTION:{
            //mode의 bpm정보
           NSString *minBPM = _staticMode[indexPath.row][@"minBPM"];
            
            [_DBManager createPlayListWithMinBPM:[minBPM intValue] maxBPM:0];
            [self syncPlayer];
            break;
        }
        case ADDMODE_SECTION:{
            //mode의 bpm정보
            Mode *mode = [_DBManager getModeWithIndex:indexPath.row];
            [_DBManager createPlayListWithMinBPM:mode.minBPM maxBPM:mode.maxBPM];
            [self syncPlayer];
            break;
        }
        default:{
            [self changePositionCustomModeViewWithY:MARGIN_Y];
            break;
        }
    }
}
- (void)changePositionCustomModeViewWithY:(NSInteger)Y{
    if(Y==MARGIN_Y){
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.backView.frame = self.view.frame;
            self.customModeView.frame = CGRectMake( self.customModeView.frame.origin.x,Y, self.customModeView.frame.size.width, self.customModeView.frame.size.height);
        }completion:nil];
    }else{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.backView.frame = CGRectMake(self.customModeView.frame.origin.x,HIDDEN_Y , self.customModeView.frame.size.width, self.customModeView.frame.size.height);
            self.customModeView.frame = CGRectMake(self.customModeView.frame.origin.x, Y, self.customModeView.frame.size.width, self.customModeView.frame.size.height);
        }completion:nil];
    }
}
- (IBAction)saveCustomMode:(id)sender {
    //디비에 저장 후 릴로드
    //FIXME:save전에 textField값이 정상적인지 체크하는 로직 필요
    if([_DBManager insertModeWithMinBPM:[self.minBPM.text intValue] maxBPM:[self.maxBPM.text intValue]] == NO){
        
        self.minBPM.text = @"";
        self.maxBPM.text = @"";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"저장실패" message:@"실패" delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [alert show];
        
        return;
    }
    self.minBPM.text = @"";
    self.maxBPM.text = @"";
    
    [_DBManager syncMode];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:ADDMODE_SECTION];
    [self.modeTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.minBPM resignFirstResponder];
    [self.maxBPM resignFirstResponder];
    [self changePositionCustomModeViewWithY:HIDDEN_Y];
}
- (IBAction)cancleCustomMode:(id)sender {
    self.minBPM.text = @"";
    self.maxBPM.text = @"";
    
    [self.minBPM resignFirstResponder];
    [self.maxBPM resignFirstResponder];
    [self changePositionCustomModeViewWithY:HIDDEN_Y];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)deleteCell{
    int selectedIndex = (int)[self.modeTable indexPathForSelectedRow].row;
    Mode *mode = [_DBManager getModeWithIndex:selectedIndex];
    NSLog(@"mode_id:%d",(int)mode.modeID);
    [_DBManager deleteModeWithModeID:mode.modeID];
    [_DBManager syncMode];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:ADDMODE_SECTION];
    [self.modeTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
//FIXME : 디비를 한번에 여러개가 접근해서 생기는 문제임.
//고쳐지면 다시 뷰 디드 로드로 옮겨야함.
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    _staticMode = @[@{@"modeTitle":@"걷기",@"minBPM":@"120"},@{@"modeTitle":@"조깅,트레드밀",@"minBPM":@"140"},@{@"modeTitle":@"러닝",@"minBPM":@"160"},@{@"modeTitle":@"사이클링",@"minBPM":@"130"}];
    _DBManager = [DBManager sharedDBManager];

    [_DBManager syncMode];
}
@end
