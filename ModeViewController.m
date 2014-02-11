//
//  ModeViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ModeViewController.h"
#import "DBManager.h"
#import "ModeCell.h"
#import "MusicFitPlayer.h"
#import "UIViewController+SwipeController.h"
#import "SwipeViewController.h"

#define STATICCELL_NUM 4
#define STATIC_SECTION 0
#define ADDMODE_SECTION 1
#define CUSTOMIZE_SECTION 2
#define HIDDEN_Y 600
#define MARGIN_Y 50

@interface ModeViewController () <AddedModeDelegate, UIAlertViewDelegate>@property (weak, nonatomic) IBOutlet UIView *customModeView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *maxBPMTextField;
@property (weak, nonatomic) IBOutlet UITextField *minBPMTextField;
@property (weak, nonatomic) IBOutlet UITableView *modeTable;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;


- (IBAction)saveCustomMode:(id)sender;
- (IBAction)cancelCustomMode:(id)sender;

@end

@implementation ModeViewController{
    DBManager *_DBManager;
}
- (IBAction)checkTextFieldLength:(id)sender {
    NSInteger titleLength = [self.titleTextField.text length];
    NSInteger minBPMLength = [self.minBPMTextField.text length];
    NSInteger maxBPMLegnth = [self.maxBPMTextField.text length];
    if(titleLength >0 && minBPMLength >0 && maxBPMLegnth >0){
        self.saveBtn.enabled = YES;
    }else
        self.saveBtn.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    NSLog(@"return key press");
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
        return [_DBManager  getNumberOfMode]-4;
    else//커스터마이징할 모드
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    StaticModeCell *staticCell;
    //addedCell;
   // UITableViewCell *cell;
    switch (indexPath.section){
        case STATIC_SECTION:{
            ModeCell *staticCell = [tableView dequeueReusableCellWithIdentifier:@"MODE_CELL" forIndexPath:indexPath];
           Mode *mode = [_DBManager getModeWithIndex:indexPath.row];
            
            [staticCell setStaticWithImageName:[NSString stringWithFormat:@"icon_mode%d.png", indexPath.row+1] title:mode.title minBPM:[mode getStringMinBPM]];

            return staticCell;
        }
        case ADDMODE_SECTION:{
            ModeCell *addedCell = [tableView dequeueReusableCellWithIdentifier:@"MODE_CELL"];
            Mode *mode = [_DBManager getModeWithIndex:indexPath.row+4];
            
            [addedCell setAddedWithTitle:mode.title minBPM:mode.minBPM maxBPM:mode.maxBPM];
            addedCell.addedDelegate = self;
            
            return addedCell;
        }
        default:{
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CUSTOMIZE_CELL"];
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:cell.frame];
            backgroundImageView.image = [UIImage imageNamed:@"basic_bg.png"];
            backgroundImageView.contentMode = UIViewContentModeScaleToFill;

            [cell setBackgroundView:backgroundImageView];
            
            return cell;
        }
    }
}

- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.modeTable deselectRowAtIndexPath:indexPath animated:YES];
    //커스텀이 아닌 경우 해당 셀에 대한 mode정보를 얻어온 후 해당하는 범위의 bpm을 찾아 리스트를 생성한다.
    switch (indexPath.section){
        case STATIC_SECTION:{
            //mode의 bpm정보
//           Mode *mode = [_DBManager getModeWithIndex:indexPath.row];
            //리스트 생성
            [_DBManager getModeListWithIndex:indexPath.row];
//            [_DBManager syncPlayList];
            //음악 재생
            MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
            [player setPlayList];
            //[player changePlayMusicWithIndex:0];
            //swipe
            [self.swipeViewController moveRightAnimated:YES];
            break;
        }
        case ADDMODE_SECTION:{
            //mode의 bpm정보
//            Mode *mode = [_DBManager getModeWithIndex:indexPath.row+3];
//            [_DBManager createListWithMinBPM:mode.minBPM maxBPM:mode.maxBPM];
            [_DBManager getModeListWithIndex:indexPath.row+4];
//            [_DBManager syncPlayList];
            //음악 재생
            MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
            [player setPlayList];
            //[player changePlayMusicWithIndex:0];
            //swipe
            [self.swipeViewController moveRightAnimated:YES];
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
    self.saveBtn.enabled = NO;
    
    if([_DBManager insertModeWithMinBPM:[self.minBPMTextField.text intValue] maxBPM:[self.maxBPMTextField.text intValue] title:self.titleTextField.text] == NO){
        
        self.minBPMTextField.text = @"";
        self.maxBPMTextField.text = @"";
        self.titleTextField.text = @"";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"저장실패" message:@"실패" delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [alert show];
        
        return;
    }
    self.minBPMTextField.text = @"";
    self.maxBPMTextField.text = @"";
    self.titleTextField.text = @"";
    
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:ADDMODE_SECTION];
    [self.modeTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.minBPMTextField resignFirstResponder];
    [self.maxBPMTextField resignFirstResponder];
    [self.titleTextField resignFirstResponder];
    [self changePositionCustomModeViewWithY:HIDDEN_Y];
}
- (IBAction)cancelCustomMode:(id)sender {
    self.minBPMTextField.text = @"";
    self.maxBPMTextField.text = @"";
    self.titleTextField.text = @"";
    
    self.saveBtn.enabled = NO;
    
    [self.minBPMTextField resignFirstResponder];
    [self.maxBPMTextField resignFirstResponder];
    [self.titleTextField resignFirstResponder];
    
    [self changePositionCustomModeViewWithY:HIDDEN_Y];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)deleteCell{
    int selectedIndex = (int)[self.modeTable indexPathForSelectedRow].row;
    Mode *mode = [_DBManager getModeWithIndex:selectedIndex];
//    NSLog(@"mode_id:%d",(int)mode.modeID);
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
    
    _DBManager = [DBManager sharedDBManager];

    [_DBManager syncMode];
}
@end
