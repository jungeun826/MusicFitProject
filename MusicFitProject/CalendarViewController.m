//
//  CalenderViewController.m
//  Calender
//
//  Created by jungeun on 14. 2. 9..
//  Copyright (c) 2014년 jungeun. All rights reserved.
//

#import "CalendarViewController.h"
#import "DayCell.h"
#import "DBManager.h"
#import "DayInfoCell.h"
#import "CalendarDayInfo.h"

#define tableCellID @"DayInfo_Cell"

//#define MonthInfoSection 0
//#define DayInfoSection 1
//#define OneDaySection 0


@interface CalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *calenderView;
@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;
@property (weak, nonatomic) IBOutlet UITableView *calendarTable;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *promiseTextField;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *monthExerInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayExerInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *dayExerInfoView;

@end

@implementation CalendarViewController{
    BOOL _isWeekCell;
    NSInteger _firstDayIndex;
    NSInteger _days;
    
    NSDateComponents *_selectedDate;
    NSDateComponents *_curDate;
    NSDateComponents *_month;
    
    NSCalendar *_calendar;
    BOOL _PromiseCapacityFull;
    
    NSMutableArray *_selectDayInfo;
    NSDictionary *_selectMonthInfo;
    NSMutableArray *_selectMonthArr;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_selectDayInfo count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DayInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellID forIndexPath:indexPath];
    CalendarDayInfo *info = _selectDayInfo[indexPath.row];
    cell = [cell initWithMode:info.modeID startTimeString:[info getStartTime] exerTimeString:[info getExerTime]];
    return cell;
}
- (IBAction)dissmissPromiseTextField:(id)sender {
    [self.promiseTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(NSOrderedSame == [string compare:@"" options:NSCaseInsensitiveSearch]){
        return YES;
    }
    if([textField.text length] > 11)
        return NO;
    else
        return YES;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //편집된 이미지가 있으면 사용, 없으면 원본으로 사용
    UIImage *usingImage = (nil == editedImage) ? originalImage : editedImage;

    
    CGSize size = CGSizeMake(55, 55);
    UIImage *resizeImage = [self imageWithImage:usingImage scaledToSize:size];
    
    usingImage = resizeImage;
    self.profileImageView.image = usingImage;
    [self saveUserDefaultProfileImage:usingImage];
    //피커 감추기
    [picker dismissViewControllerAnimated:YES completion:nil];}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (IBAction)setProfile:(id)sender {
    //앨범에서 가져오는거
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)showPrevMonth:(id)sender {
    [self setMonthWithMonth:[_month month]-1];
    
    [self setSelectedDate:1];
    
    [self setDaysInFirstWeek];
    [self setDays];
    
    [self setMonthAndYearLabel];
    [self.calenderView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:_firstDayIndex + [_curDate day]-2 inSection:0];
    [self.calenderView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionTop];
    [self.calendarTable reloadData];
}
- (IBAction)showNextMonth:(id)sender {
    if( [_curDate month] == [_month month])
        return;
    
    [self setMonthWithMonth:[_month month]+1];
    
    [self setSelectedDate:1];
    
    [self setDaysInFirstWeek];
    [self setDays];
    
    [self setMonthAndYearLabel];
    [self.calenderView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:_firstDayIndex + [_curDate day]-2 inSection:0];
    [self.calenderView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionTop];
    
    [self.calendarTable reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 42;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DayCell" forIndexPath:indexPath];
    
    if(indexPath.row >= _firstDayIndex && indexPath.row < (_days+_firstDayIndex) ){
        NSInteger index =(indexPath.row - _firstDayIndex);
        NSString  *day = [NSString stringWithFormat:@"%d",index+1 ];
//        NSInteger modeID = [(NSNumber *)_selectMonthArr[dayIndex] integerValue];
        cell = [cell initWithDay:day lastMode: [_selectMonthArr[index] integerValue]];
    }else{
        cell = [cell initBlankCell];
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.promiseTextField resignFirstResponder];
//    [self.calenderView deselectItemAtIndexPath:indexPath animated:YES];
    if(indexPath.row >= _firstDayIndex && indexPath.row < (_days+_firstDayIndex) ){
        [_selectedDate setDay:(indexPath.row - (_firstDayIndex) +1)];
        [self showDayCellDetail:_selectedDate];
        
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMonthWithMonth:(NSInteger)month{
    [_month setMonth: month];
    // FIXME : 전 달력으로 가면 1일인지 원래 선택했던 날짜인지 정해야함.
    if([_month month] < 1){
        [_month setMonth: 12];
        [_month setYear: [_month year]-1];
    }else if([_month month] > 12){
        [_month setMonth: 1];
        [_month setYear: [_month year]+1];
    }
    [_month setDay:1];
}
- (void)setSelectedDate:(NSInteger)day{
    [_selectedDate setMonth: [_month month]];
    [_selectedDate setYear:[_month year]];
    [_selectedDate setDay:day];
}
- (void)setMonthAndYearLabel{
    NSInteger month = [_month month];
    NSInteger year = [_month year];
    
    NSString *monthAndYear = [NSString stringWithFormat:@"%04d.%02d",year,month];
    
    self.monthAndYearLabel.text = monthAndYear;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setDaysInFirstWeek{
    NSDateComponents *month = [_calendar components:NSYearCalendarUnit|
     NSMonthCalendarUnit|
     NSDayCalendarUnit|
     NSWeekdayCalendarUnit|
     NSCalendarCalendarUnit
                 fromDate:[_calendar dateFromComponents:_month]];
    //1 = 일요일 ..... 7=토요일
    _firstDayIndex = [month weekday]-1;
//    NSLog(@"setDaysInFirstWeek  : %@", month);
}

- (void)setDays{
    _days = [_calendar rangeOfUnit:NSDayCalendarUnit
                            inUnit:NSMonthCalendarUnit
                           forDate:[_calendar dateFromComponents:_month]].length;
//    NSLog(@"days : %d", _days);
}

- (void)showDayCellDetail:(NSDateComponents *)selectedDate{
    
    NSLog(@"selected Date : %04d.%02d.%02d", (int)[selectedDate year], (int)[selectedDate month], (int)[selectedDate day]);
    //디비에서 해당 날짜를 가져옴
    DBManager *dbManager = [DBManager sharedDBManager];
    [_selectDayInfo removeAllObjects];
    [_selectDayInfo addObjectsFromArray:[dbManager getCalendarDayInfoWithDay:selectedDate]];
    //해당 날짜에 대한 총 운동시간을 구함
    NSInteger totalDayExerTime = 0;
    NSInteger count =[_selectDayInfo count] ;
    if(count == 0){
        self.dayExerInfoView.hidden =YES;
    }else{
        self.dayExerInfoView.hidden = NO;
        
    for(int index = 0 ; index < count ; index++){
        totalDayExerTime += [_selectDayInfo[index] exerTime];
    }
    //총 운동시간에 대해 시:분으로 표현
    NSInteger minute = totalDayExerTime%60;
    NSInteger hour = totalDayExerTime/60;
    NSString *exerTimeString = [NSString stringWithFormat:@"%2d:%2d", hour, minute];
    CalendarDayInfo *info = _selectDayInfo[0];
    
    self.dayExerInfoLabel.text = [NSString stringWithFormat:@"%d일 총 운동 시간 : %@",[info getDay],exerTimeString];
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
    //DB접근 해 해당 날짜에 대한 정보를 가져옴
    //가져온 데이터를 테이블 셀에 뿌릴 수 있도록 어레이 형태로 리턴하도록함.
    //테이블 셀에서 릴로드 하도록 함
    //그 후 테이블 셀 포 로우? 거기에서 테이블 셀에 대해서 정보를 저장하는 방식을 채택하고
    //맨 마지막 셀이 나오면 해야하는 작업도 적용해야함.
}
- (UIImage *)loadFromUserDefaultProfileImage{
    NSData *profileImageData = [[NSUserDefaults standardUserDefaults] valueForKey:@"profileImage_preference"];
    UIImage *profileImage = [UIImage imageWithData:profileImageData];
    if (profileImage == nil) {
        profileImage = [UIImage imageNamed:@"setting_profile_bg.png"];
    }
    return profileImage;
}
- (void)saveUserDefaultProfileImage:(UIImage *)profileImage{
    NSData *profileImageData = UIImagePNGRepresentation(profileImage);
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    [userDefualt setObject:profileImageData forKey:@"profileImage_preference"];
    [userDefualt synchronize];
}
- (NSString *)loadFromUserDefaultPromise{
    NSString *promiseString = [[NSUserDefaults standardUserDefaults] valueForKey:@"promise_preference"];
    return promiseString;
}
- (void)saveUserDefaultPromise:(NSString *)promiseString{
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    [userDefualt setObject:promiseString forKey:@"promise_preference"];
    [userDefualt synchronize];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    [self saveUserDefaultPromise:self.promiseTextField.text];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.profileImageView.image = [self loadFromUserDefaultProfileImage];
    self.promiseTextField.text = [self loadFromUserDefaultPromise];
    DBManager *dbManager = [DBManager sharedDBManager];

    _selectDayInfo = [[NSMutableArray alloc]init];
    _selectMonthInfo = [[NSDictionary alloc]init];
    _selectMonthArr = [[NSMutableArray alloc]init];
    
    _isWeekCell = NO;
    _calendar = [NSCalendar currentCalendar];
    
    _curDate = [_calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    _selectedDate =
    [_calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    _month = [_calendar components:NSYearCalendarUnit|
              NSMonthCalendarUnit|
              NSDayCalendarUnit|
              NSWeekdayCalendarUnit|
              NSCalendarCalendarUnit
                          fromDate:[NSDate date]];
    [_month setDay:1];
    
    [self setMonthAndYearLabel];
    [self setDaysInFirstWeek];
    [self setDays];
    
    [self showDayCellDetail:_curDate];
    [_selectMonthArr addObjectsFromArray:[dbManager getCalendarMonthInfoWithMonth:_month]];
    _selectMonthInfo = [dbManager getCalendarMonthDicWithMonth:_month];
    
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:_firstDayIndex + [_curDate day]-2 inSection:0];
    [self.calenderView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionTop];
}
@end
