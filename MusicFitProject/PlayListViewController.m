//
//  PlayListViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayListViewController.h"
#import "PlayListCell.h"
#import "PlayerViewController.h"
#import "MusicFitPlayer.h"
#import "DBManager.h"
//#define PALYMODE 0 NO
//#define EDITMODE 1 YES


#define CELL_IDENTIFIER @"PLAYLIST_CELL"

@interface PlayListViewController () <UIAlertViewDelegate>{
    DBManager *_DBManager;
}
@property (weak, nonatomic) IBOutlet UITableView *playListTable;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@end

@implementation PlayListViewController{
    BOOL _editMode;
}
- (void)viewWillAppear:(BOOL)animated{
    [self.playListTable reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = [_DBManager getNumberOfMusicInList];
//    NSLog(@"%d", (int)rows);
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLAYLIST_CELL" forIndexPath:indexPath];
    NSInteger musicID = [_DBManager getKeyValueInListWithKey:@"musicID" index:indexPath.row];
    Music *music = [_DBManager getMusicWithMusicID:musicID];
    
//    NSLog(@"%@", music.title);
    [cell setPlayListWithTitle:music.title artist:music.artist BPM:music.BPM image:[music getAlbumImageWithSize:CGSizeMake(20, 20)]];
    return cell;
    
}

- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //editMode가 아닐 경우 touch시에 음악 재생
    if(_editMode){
        
    }else{
        [_DBManager syncList];
        //음악 재생
        MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
        
        [player changePlayMusicWithIndex:indexPath.row];
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
- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _DBManager = [DBManager sharedDBManager];
    _editMode = NO;
    //FIXME : 아래 문장은 edit 누른 후에 곡추가 누를 경우에 수행해야 함.
    
    [_DBManager syncMusic];
    [_DBManager syncList];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeShowCurSelectedMusic:(NSInteger)index{
//    [self.playListTable.inde]
//    [self.playListTable ]
}
@end
