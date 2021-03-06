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
#define _4INCH_MARGIN_Y 100
#define _3_5INCH_MARGIN_Y 50

@interface ModeViewController () <AddedModeDelegate, UIAlertViewDelegate>@property (weak, nonatomic) IBOutlet UIView *customModeView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *maxBPMTextField;
@property (weak, nonatomic) IBOutlet UITextField *minBPMTextField;
@property (weak, nonatomic) IBOutlet UITableView *modeTable;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;


- (IBAction)saveCustomMode:(id)sender;
- (IBAction)cancelCustomMode:(id)sender;

@end

@implementation ModeViewController{
    DBManager *_DBManager;
    NSInteger _lastSelectIndex;
}
- (NSInteger)getCustomModeViewMarginY{
    if(IS_4_INCH_DEVICE)
        return _4INCH_MARGIN_Y;
    else
        return _3_5INCH_MARGIN_Y;
}
- (IBAction)modeEditing:(id)sender {
    BOOL editing = !self.modeTable.editing;
    [self.modeTable setEditing:editing animated:YES];

    self.editBtn.selected = editing;
    SwipeViewController *swipeVC = (SwipeViewController *)self.parentViewController;
    swipeVC.doSwipe = !editing;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == ADDMODE_SECTION ){
        if(indexPath.row  != _lastSelectIndex-4){
            return YES;
        }else
            return NO;
    }
    
    return NO;
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
    if(section == STATIC_SECTION) //고정 모드 4개
        return STATICCELL_NUM;
    else if(section == ADDMODE_SECTION)//추가된 모드
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
            
            [staticCell setStaticWithImageName:[NSString stringWithFormat:@"icon_mode%d.png", (int)(indexPath.row+1)] title:mode.title minBPM:[mode getStringMinBPM] modeID:mode.modeID];

            return staticCell;
        }
        case ADDMODE_SECTION:{
            ModeCell *addedCell = [tableView dequeueReusableCellWithIdentifier:@"MODE_CELL"];
            Mode *mode = [_DBManager getModeWithIndex:indexPath.row+4];
            
            [addedCell setAddedWithTitle:mode.title minBPM:mode.minBPM maxBPM:mode.maxBPM modeID:mode.modeID];
            addedCell.addedDelegate = self;
            
            return addedCell;
        }
        default:{
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CUSTOMIZE_CELL"];
            UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            UIImageView *selectedImageView = [[UIImageView alloc]initWithFrame:cell.frame];
            
            selectedImageView.image = [UIImage imageNamed:@"basic_bg_2_on.png"];
            [selectedBackgroundView addSubview:selectedImageView];
            //    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.3]]; // set color here
            [selectedBackgroundView setAlpha:0.4];
            
            cell.selectedBackgroundView = selectedBackgroundView;
            
//            [cell setBackgroundView:backgroundImageView];
            return cell;
        }
    }
}

- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.modeTable deselectRowAtIndexPath:indexPath animated:YES];
    //커스텀이 아닌 경우 해당 셀에 대한 mode정보를 얻어온 후 해당하는 범위의 bpm을 찾아 리스트를 생성한다.
    switch (indexPath.section){
        case STATIC_SECTION:{
            //modeID로 리스트 갱신
            [_DBManager syncModeListWithIndex:indexPath.row];
            
            //음악 재생에 대한 정보 갱신을 위해 player에게 전달
            [self.modeToPlayerDegate changeMode:[_DBManager getCurModeID]];
            _lastSelectIndex = indexPath.row;
//            NSLog(@"lastIndex : %d", _lastSelectIndex);
            //swipe
            [self.swipeViewController moveRightAnimated:YES];
            
            break;
        }
        case ADDMODE_SECTION:{
            
            [_DBManager syncModeListWithIndex:indexPath.row+4];
            [self.modeToPlayerDegate changeMode:[_DBManager getCurModeID]];
            _lastSelectIndex = indexPath.row+4;
//            NSLog(@"lastIndex : %d", _lastSelectIndex);
            //swipe
            [self.swipeViewController moveRightAnimated:YES];
            break;
        }
        default:{
            [self changePositionCustomModeViewWithY:[self getCustomModeViewMarginY]];
            break;
        }
    }
}
- (void)changePositionCustomModeViewWithY:(NSInteger)Y{
    if(Y==[self getCustomModeViewMarginY]){
        self.backView.frame = self.view.frame;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{

            self.customModeView.frame = CGRectMake( self.customModeView.frame.origin.x,Y, self.customModeView.frame.size.width, self.customModeView.frame.size.height);
        }completion:nil];
    }else{
        self.backView.frame = CGRectMake(self.customModeView.frame.origin.x,HIDDEN_Y , self.customModeView.frame.size.width, self.customModeView.frame.size.height);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
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
-(void)deleteModeWithModeID:(NSInteger)modeID{
//    int selectedIndex = (int)[self.modeTable indexPathForSelectedRow].row;
    NSLog(@"deleteMode : %d", (int)modeID );
//    Mode *mode = [_DBManager getModeWithModeID:modeID];
     NSInteger modeIndex = [_DBManager getIndexOfModeID:modeID];
//    NSLog(@"mode_id:%d",(int)mode.modeID);
    [_DBManager deleteModeWithModeID:modeID];
   
    NSLog(@" delete modeIndex :%d, lastSelectIndex :%d", modeIndex, _lastSelectIndex);
    
    if(modeIndex < _lastSelectIndex){
        _lastSelectIndex--;
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:ADDMODE_SECTION];
    [self.modeTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
//FIXME : 디비를 한번에 여러개가 접근해서 생기는 문제임.
//고쳐지면 다시 뷰 디드 로드로 옮겨야함.
- (void)viewDidLoad{
    [super viewDidLoad];
    self.modeToPlayerDegate = [MusicFitPlayer sharedPlayer];
    
    _DBManager = [DBManager sharedDBManager];
    [_DBManager syncMode];
    [_DBManager syncMusic];
    _lastSelectIndex = [_DBManager getIndexOfModeID:[_DBManager getCurModeID]];
    NSLog(@"lastIndex : %d", _lastSelectIndex);
}
@end
