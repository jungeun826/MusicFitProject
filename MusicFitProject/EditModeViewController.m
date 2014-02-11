//
//  editModeViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 6..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "EditModeViewController.h"
#import "DBManager.h"
#import "PlayListCell.h"

#define ORIGINMUSIC_SECTION 0
#define ADDEDMUSIC_SECTION 1
@interface EditModeViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation EditModeViewController{
    DBManager *_DBManager;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = [_DBManager getNumberOfMusicInPlayList];
    NSLog(@"%d", (int)rows);
    return rows;
}
- (IBAction)askListSave:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"리스트를 저장하시겠습니까?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
    [alert show];
}
- (void)backPlayListVC{
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLAYLIST_CELL" forIndexPath:indexPath];
    NSInteger musicID = [_DBManager getMusicInfoInPlayListWithIndex:indexPath.row];
    Music *music = [_DBManager getMusicWithMusicID:musicID];
    
    NSLog(@"%@", music.title);
    [cell setWithTitle:music.title artist:music.artist];
    return cell;
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == alertView.cancelButtonIndex){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //editMode가 아닐 경우 touch시에 음악 재생
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
    _DBManager = [DBManager sharedDBManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
