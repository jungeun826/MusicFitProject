//
//  ModeViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ModeViewController.h"
#import "ModeManager.h"
#import "AddedModeCell.h"
#import "StaticModeCell.h"
#import "PlayViewController.h"
#import "AppDelegate.h"

#define STATICCELL_NUM 4
#define STATIC_SECTION 0
#define ADDMODE_SECTION 1
#define CUSTOMIZE_SECTION 2
#define HIDDEN_Y 600
#define MARGIN_Y 100

@interface ModeViewController () <AddedModeDelegate>{
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
    ModeManager *_modeManager;
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
        return [_modeManager getNumberOfMode];
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
            Mode *mode = [_modeManager getModeWithIndex:indexPath.row];
            
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
- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == CUSTOMIZE_SECTION){
        [self changePositionCustomModeViewWithY:MARGIN_Y];
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
    [_modeManager addModeWithMinBPM:[self.minBPM.text intValue] maxBPM:[self.maxBPM.text intValue]];
    self.minBPM.text = @"";
    self.maxBPM.text = @"";
    
    [_modeManager syncMode];
    
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
- (void)viewDidLoad{
    [super viewDidLoad];
    _staticMode = @[@{@"modeTitle":@"걷기",@"minBPM":@"120"},@{@"modeTitle":@"조깅,트레드밀",@"minBPM":@"140"},@{@"modeTitle":@"러닝",@"minBPM":@"160"},@{@"modeTitle":@"사이클링",@"minBPM":@"130"}];
    _modeManager = [ModeManager sharedModeManager];
    [_modeManager syncMode];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)deleteCell{
    int selectedIndex = [self.modeTable indexPathForSelectedRow].row;
    Mode *mode = [_modeManager getModeWithIndex:selectedIndex];
    NSLog(@"mode_id:%d",mode.mode_id);
    [_modeManager deleteModeWithModeID:mode.mode_id];
    [_modeManager syncMode];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:ADDMODE_SECTION];
    [self.modeTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
