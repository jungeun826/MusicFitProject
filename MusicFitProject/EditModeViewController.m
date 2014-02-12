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
#import "MusicFitPlayer.h"

#define ORIGINMUSIC_SECTION 0
#define ADDEDMUSIC_SECTION 1
@interface EditModeViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *editTable;

@end

@implementation EditModeViewController{
    DBManager *_DBManager;
    NSMutableArray *_addSongList;
    NSArray *_deleteSongList;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = [_DBManager getNumberOfMusicInList];
    NSLog(@"%d", (int)rows);
    return rows;
}
- (IBAction)askListSave:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"리스트를 저장하시겠습니까?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
    [alert show];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLAYLIST_CELL" forIndexPath:indexPath];
    NSInteger musicID = [_DBManager getKeyValueInListWithKey:@"musicID" index:indexPath.row];
    Music *music = [_DBManager getMusicWithMusicID:musicID];
    
//    NSLog(@"%@", music.title);
    [cell setEditWithTitle:music.title artist:music.artist];
    return cell;
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == alertView.cancelButtonIndex){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(buttonIndex == alertView.firstOtherButtonIndex){
        //delete select된것을 삭제하도록 함.
        _deleteSongList = [[NSArray alloc]init];
        _deleteSongList = [self.editTable indexPathsForSelectedRows];
        [_DBManager deleteListWithArray:_deleteSongList];
        
        [[MusicFitPlayer sharedPlayer] setPlayList];
        [self dismissViewControllerAnimated:YES completion:nil];
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
    _DBManager = [DBManager sharedDBManager];
    _deleteSongList = [[NSArray alloc]init];
}
- (void)viewWillAppear:(BOOL)animated{
//    [MusicFitPlayer sha]
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
