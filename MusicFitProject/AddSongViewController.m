//
//  AddSongViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 12..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "AddSongViewController.h"
#import "DBManager.h"
#import "PlayListCell.h"
#import "EditModeViewController.h"

@interface AddSongViewController ()
@property (weak, nonatomic) IBOutlet UITableView *addSongTable;

@end

@implementation AddSongViewController
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    DBManager *dbManager = [DBManager sharedDBManager];
    NSInteger rows = [dbManager getNumberOfMusic];
    NSLog(@"%d", (int)rows);
    return rows;
}

- (IBAction)deliberyAddSongList:(id)sender {
    _addSongList = [[NSArray alloc]init];
    
    EditModeViewController *editVC = (EditModeViewController *)self.presentingViewController;
    NSArray *addSelectedList = [self.addSongTable indexPathsForSelectedRows];
    
    for(int index = 0 ; index < [addSelectedList count]; index++){
        [editVC.addSongList addObject:addSelectedList[index] ];
    }    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLAYLIST_CELL" forIndexPath:indexPath];
    DBManager *dbManager = [DBManager sharedDBManager];
    
    Music *music = [dbManager getMusicWithIndex:indexPath.row];
    
    [cell setEditWithTitle:music.title artist:music.artist];
    return cell;
    
}
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
