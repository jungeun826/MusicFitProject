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
    NSArray *_deleteSongList;
    NSInteger _rows;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == ORIGINMUSIC_SECTION){
    _rows = [_DBManager getNumberOfMusicInList];

        return _rows ;
    }else{
        NSLog(@"%d", (int)(_rows+[_addSongList count]));
        return [_addSongList count];
    }
}
- (IBAction)askListSave:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"리스트를 저장하시겠습니까?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
    [alert show];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == ORIGINMUSIC_SECTION){
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLAYLIST_CELL" forIndexPath:indexPath];
    NSInteger musicID = [_DBManager getKeyValueInListWithKey:@"musicID" index:indexPath.row];
    Music *music = [_DBManager getMusicWithMusicID:musicID];
    
//    NSLog(@"%@", music.title);
    [cell setEditWithTitle:music.title artist:music.artist];

    
    return cell;
    }else {
        PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLAYLIST_CELL" forIndexPath:indexPath];
        Music *music = [_DBManager getMusicWithIndex:[_addSongList[indexPath.row] row]];
        [cell setEditWithTitle:music.title artist:music.artist];

        return cell;
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == alertView.cancelButtonIndex){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(buttonIndex == alertView.firstOtherButtonIndex){
        //delete select된것을 삭제하도록 함.
        NSArray *selectedIndexPaths =[self.editTable indexPathsForSelectedRows];
        if([selectedIndexPaths count]>0 ){
            _deleteSongList =  [self.editTable indexPathsForSelectedRows];
        
            [_DBManager deleteListWithArray:_deleteSongList];
            
            NSInteger latestDeleteIndex = 0;
            for(int index = 0 ; index < [_deleteSongList count] ; index++){
                NSIndexPath *indexPath = _deleteSongList[index];
                if(indexPath.section != ADDEDMUSIC_SECTION)
                    continue;
                
                NSInteger deleteIndex = indexPath.row;
                if(latestDeleteIndex < deleteIndex)
                    --deleteIndex;
                
                [_addSongList removeObjectAtIndex:deleteIndex];
                latestDeleteIndex = deleteIndex+1;
            }
        }
        
        
        if([_addSongList count] > 0)
            [_DBManager insertListWithArray:_addSongList];
        
        //mode의 List 싱크는 이미 디비매니저 함수에서 함.
        //따라서 리스트에 대한 큐를 만들어 아이템으로 넣어주어야 하는 것 필요.
        [self.editListToPlayerDelegate syncEditList];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _deleteSongList = [self.editTable indexPathsForSelectedRows];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:ADDEDMUSIC_SECTION];
    
    [self.editTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    for(int index = 0 ; index < [_deleteSongList count] ; index++){
        NSIndexPath *indexPath = _deleteSongList[index];
        if(indexPath.section != ADDEDMUSIC_SECTION)
            continue;
        
        [self.editTable selectRowAtIndexPath:_deleteSongList[index] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     self.editListToPlayerDelegate = [MusicFitPlayer sharedPlayer];
    _DBManager = [DBManager sharedDBManager];
    _deleteSongList = [[NSArray alloc]init];
    _addSongList = [[NSMutableArray alloc]init];
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
