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
#import "SwipeController.h"

#define ADD_HEIGHT 80
#define ORIGINMUSIC_SECTION 0
#define ADDEDMUSIC_SECTION 1
#define PLAYLIST_CELL @"PLAYLIST_CELL"
#define ADDSONG_CELL @"ADDLIST_CELL"
#define PLAYLISTTABLE_TAG 10
#define ADDSONGLISTTABLE_TAG 11

#define _4INCH_EDIT_TABLEHEIGHT 440
#define _4INCH_TABLEHEIGHT 360

#define _3_5INCH_EDIT_TABLEHEIGHT 350
#define _3_5INCH_TABLEHEIGHT 270

@interface PlayListViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *addSongView;
@property (weak, nonatomic) IBOutlet UITableView *addSongTable;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UITableView *playListTable;
@end

@implementation PlayListViewController{
    DBManager *_DBManager;
    NSArray *_deleteSongList;
    NSInteger _rows;
}
- (NSInteger)getEditPlayListHeight{
    if(IS_4_INCH_DEVICE)
        return _4INCH_TABLEHEIGHT;
    else
        return _3_5INCH_TABLEHEIGHT;
}
- (NSInteger)getPlayListHeight{
    if(IS_4_INCH_DEVICE)
        return _4INCH_EDIT_TABLEHEIGHT;
    else
        return _3_5INCH_EDIT_TABLEHEIGHT;
}
- (IBAction)showAddSongList:(id)sender {
    [self changePositionAddSongListView:MoveToUp];
}
- (void)changePositionAddSongListView:(MoveToDirection) direction{
    CGRect frame = self.addSongView.frame;
    if(direction == MoveToDown)
        frame.origin.y = 600;
    else if(direction == MoveToUp)
        frame.origin.y = 36;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.addSongView.frame = frame;
    }completion:^(BOOL finished) {
        [self.addSongTable setEditing:YES animated:NO];
        [self.addSongTable setEditing:NO animated:YES];
    }];
}
//edit한 것을 저장할지 묻는것을 띄워줌
- (IBAction)askListSave:(id)sender {
    _deleteSongList = [self.playListTable indexPathsForSelectedRows];
    
    if( [_deleteSongList count] == 0 && [self.addSongList count] == 0){
        [self endEditMode];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"리스트를 저장하시겠습니까?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
    [alert show];
}
- (IBAction)saveAddList:(id)sender {
    [self.addSongList removeAllObjects];
    [self.addSongList addObjectsFromArray:[self.addSongTable indexPathsForSelectedRows]];
    
    [self changePositionAddSongListView:MoveToDown];
    
    for(int index = 0 ; index < [_deleteSongList count] ; index++){
        NSIndexPath *indexPath = _deleteSongList[index];
        if(indexPath.section != ADDEDMUSIC_SECTION)
            continue;
        
        [self.playListTable selectRowAtIndexPath:_deleteSongList[index] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:ADDEDMUSIC_SECTION];
    
    [self.playListTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    
    
}
//저장한다고 하면 저장하도록 함.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //저장 안함 -> editMode를 끝냄
    if(buttonIndex == alertView.firstOtherButtonIndex){
        //delete select된것을 삭제하도록 함.
        
        if([_deleteSongList count]>0 ){
            [_DBManager deleteListWithArray:_deleteSongList];
            
            NSInteger latestDeleteIndex = 0;
            for(int index = 0 ; index < [_deleteSongList count] ; index++){
                NSIndexPath *indexPath = _deleteSongList[index];
                if(indexPath.section != ADDEDMUSIC_SECTION)
                    continue;
                
                NSInteger deleteIndex = indexPath.row;
                if(latestDeleteIndex < deleteIndex)
                    --deleteIndex;
                
                [self.addSongList removeObjectAtIndex:deleteIndex];
                latestDeleteIndex = deleteIndex+1;
            }
        }
        
        
        if([self.addSongList count] > 0)
            [_DBManager insertListWithArray:self.addSongList];
        
        //mode의 List 싱크는 이미 디비매니저 함수에서 함.
        //따라서 리스트에 대한 큐를 만들어 아이템으로 넣어주어야 하는 것 필요.
        [self.editListToPlayerDelegate syncEditList];
    }
    [self endEditMode];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self.playListTable reloadData];
    CGRect frame = self.playListTable.frame;
    frame.size.height =[self getEditPlayListHeight];
    self.playListTable.frame = frame;
}

- (IBAction)changeEditMode:(id)sender {
    [self.playListTable setEditing:YES animated:YES];
    
    self.editBtn.hidden = YES;
    
    self.playListTable.multipleTouchEnabled = YES;
    [self changeTableViewSize];
    
    SwipeViewController *swipeVC = (SwipeViewController *)self.parentViewController;
    swipeVC.doSwipe = NO;
}

- (void)endEditMode{
    [self.playListTable setEditing:NO animated:YES];
    
    self.editBtn.hidden = NO;
    _deleteSongList = [[NSMutableArray alloc]init];
    self.addSongList = [[NSMutableArray alloc]init];
    
    
    self.playListTable.multipleTouchEnabled = NO;
    [self changeTableViewSize];
    
    [self.playListTable reloadData];
    
    SwipeViewController *swipeVC = (SwipeViewController *)self.parentViewController;
    swipeVC.doSwipe = YES;
}
- (void)changeTableViewSize{
    PlayerViewController *playerVC = (PlayerViewController *)[[self parentViewController] parentViewController];
    
    if(self.playListTable.editing == YES){ //editing이면
        CGRect frame = self.playListTable.frame;
        frame.size.height = [self getPlayListHeight];
        self.playListTable.frame = frame;
        
        [playerVC movePlayerWithDirection:MoveToDown];
    }else{//아니면
        CGRect frame = self.playListTable.frame;
        frame.size.height =[self getEditPlayListHeight];
        self.playListTable.frame = frame;
        [playerVC movePlayerWithDirection:MoveToUp];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView.tag == PLAYLISTTABLE_TAG){
        return 2;
    }else
        return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView.tag == PLAYLISTTABLE_TAG){
        if(section == ORIGINMUSIC_SECTION){
            _rows = [_DBManager getNumberOfMusicInList];
            
            return _rows ;
        }
        NSLog(@"%d", (int)(_rows+[self.addSongList count]));
        return [self.addSongList count];
    }else{// if(tableView.tag == ADDSONGLISTTABLE_TAG){
        DBManager *dbManager = [DBManager sharedDBManager];
        NSInteger rows = [dbManager getNumberOfMusic];
        NSLog(@"All song count : %d", (int)rows);
        return rows;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView.tag == PLAYLISTTABLE_TAG){
        if(indexPath.section == ORIGINMUSIC_SECTION){
            PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:PLAYLIST_CELL forIndexPath:indexPath];
            NSInteger musicID = [_DBManager getKeyValueInListWithKey:@"musicID" index:indexPath.row];
            Music *music = [_DBManager getMusicWithMusicID:musicID];
            
            [cell setPlayListWithTitle:music.title artist:music.artist BPM:music.BPM image:[music getAlbumImageWithSize:CGSizeMake(20, 20)]];
            
            return cell;
        }else {
            PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:PLAYLIST_CELL forIndexPath:indexPath];
            Music *music = [_DBManager getMusicWithIndex:[_addSongList[indexPath.row] row]];
            [cell setPlayListWithTitle:music.title artist:music.artist BPM:music.BPM image:[music getAlbumImageWithSize:CGSizeMake(20, 20)]];
            
            return cell;
        }
    }
    // tableView.tag == ADDSONGLISTTABLE_TAG
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:ADDSONG_CELL forIndexPath:indexPath];
    DBManager *dbManager = [DBManager sharedDBManager];
    
    Music *music = [dbManager getMusicWithIndex:indexPath.row];
    
    [cell setAddWithTitle:music.title artist:music.artist];
    return cell;
}

- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([tableView tag] == PLAYLISTTABLE_TAG){
        //editMode가 아닐 경우 touch시에 음악 재생
        if(!self.playListTable.editing){
            [_DBManager syncList];
            //음악 재생
            MusicFitPlayer *player = [MusicFitPlayer sharedPlayer];
            
            [player changePlayMusicWithIndex:indexPath.row];
        }else{
            _deleteSongList = [self.playListTable indexPathsForSelectedRows];
        }
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.editListToPlayerDelegate = [MusicFitPlayer sharedPlayer];
    _deleteSongList = [[NSArray alloc]init];
    self.addSongList = [[NSMutableArray alloc]init];
    
    self.playListTable.allowsMultipleSelectionDuringEditing = YES;
	// Do any additional setup after loading the view.
    _DBManager = [DBManager sharedDBManager];
    
    //FIXME : 아래 문장은 edit 누른 후에 곡추가 누를 경우에 수행해야 함.
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
