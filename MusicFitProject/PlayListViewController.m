//
//  PlayListViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayListViewController.h"
#import "PlayListCell.h"
#define CELL_IDENTIFIER @"PLAYLIST_CELL"

@interface PlayListViewController (){
    PlayListDBManager *_palyListDBManager;
    MusicDBManager *_musicDBManager;
}
@property (weak, nonatomic) IBOutlet UITableView *playListTable;

@end

@implementation PlayListViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = [_palyListDBManager getNumberOfMusicInPlayList];
    NSLog(@"%d", rows);
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLAYLIST_CELL" forIndexPath:indexPath];
    NSInteger musicID = [_palyListDBManager getMusicInfoInPlayListWithIndex:indexPath.row];
    Music *music = [_musicDBManager getMusicWithMusicID:musicID];
    
    NSLog(@"%@", music.title);
    [cell setWithTitle:music.title artist:music.artist BPM:music.BPM];
    
    return cell;
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
    _musicDBManager = [MusicDBManager sharedMusicDBManager];
    [_musicDBManager syncMusic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
