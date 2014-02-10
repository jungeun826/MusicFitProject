//
//  CalenderViewController.m
//  Calender
//
//  Created by jungeun on 14. 2. 9..
//  Copyright (c) 2014년 jungeun. All rights reserved.
//

#import "CalendarViewController.h"
#import "DayCell.h"

#define WeekSection 0
#define DaySection 1
@interface CalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *calenderView;
@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;

@end

@implementation CalendarViewController{
    BOOL _isWeekCell;
    NSInteger _firstDayIndex;
    NSInteger _days;
    
    NSDateComponents *_selectedDate;
    NSDateComponents *_curDate;
    NSDateComponents *_month;
    
    NSCalendar *_calendar;
}
- (IBAction)backMyMenu:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showPrevMonth:(id)sender {
    [self setMonthWithMonth:[_month month]-1];
    
    [self setSelectedDate:1];
    
    [self setDaysInFirstWeek];
    [self setDays];
    
    [self setMonthAndYearLabel];
    [self.calenderView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}
- (IBAction)showNextMonth:(id)sender {
    [self setMonthWithMonth:[_month month]+1];
    
    [self setSelectedDate:1];
    
    [self setDaysInFirstWeek];
    [self setDays];
    
    [self setMonthAndYearLabel];
    [self.calenderView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 42;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DayCell" forIndexPath:indexPath];
    
    if(indexPath.row >= _firstDayIndex && indexPath.row < (_days+_firstDayIndex) ){
        NSString  *day = [NSString stringWithFormat:@"%d", (indexPath.row - _firstDayIndex+1)];
        cell = [cell initWithDay:day lastMode:nil];
    }else{
        cell = [cell initBlankCell];
    }
    if([_curDate day] == (indexPath.row - _firstDayIndex)){
        [cell setSelected:YES animated:NO];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row >= _firstDayIndex && indexPath.row < (_days+_firstDayIndex) ){
        [_selectedDate setDay:(indexPath.row - (_firstDayIndex) +1)];
        [self showDayCellDetail:_selectedDate];
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
//    NSLog(@"change month :%@", [_calendar dateFromComponents:_month]);
}
- (void)setSelectedDate:(NSInteger)day{
    
    [_selectedDate setMonth: [_month month]];
    [_selectedDate setYear:[_month year]];
    [_selectedDate setDay:day];
    
//    NSLog(@"change selectedDate :%@", _selectedDate);
//    NSDate *selectedDate = [_calendar dateFromComponents:_selectedDate];
//    NSLog(@"change selectedDate : %@", selectedDate);
}
- (void)setMonthAndYearLabel{
    NSInteger month = [_month month];
    NSInteger year = [_month year];
    
    NSString *monthAndYear = [NSString stringWithFormat:@"%04d.%02d",year,month];
    
    self.monthAndYearLabel.text = monthAndYear;
}
- (void)didReceiveMemoryWarning
{
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
    NSLog(@"selected Date : %04d.%02d.%02d", [selectedDate year], [selectedDate month], [selectedDate day]);
    //DB접근 해 해당 날짜에 대한 정보를 가져옴
    //가져온 데이터를 테이블 셀에 뿌릴 수 있도록 어레이 형태로 리턴하도록함.
    //테이블 셀에서 릴로드 하도록 함
    //그 후 테이블 셀 포 로우? 거기에서 테이블 셀에 대해서 정보를 저장하는 방식을 채택하고
    //맨 마지막 셀이 나오면 해야하는 작업도 적용해야함.
}
@end
