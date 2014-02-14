//
//  MyViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "MyViewController.h"

//#define CALENDER_SECTION 0
//#define RECOMMEND_SECTION 1
//#define INTEREST_SECTION 2
//#define BACKCHANGE_SECTION 3
@interface MyViewController () <UITableViewDataSource , UITableViewDelegate>

@end

@implementation MyViewController{
    NSArray * _menuList;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_menuList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_menuList[indexPath.row]];
        return cell;
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
	// Do any additional setup after loading the view.
    
    _menuList = @[@"CALENDER_CELL", @"RECOMMEND_CELL", @"INTEREST_CELL", /*@"BACKCHANGE_CELL",@"ALRAM_CELL"*/];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
