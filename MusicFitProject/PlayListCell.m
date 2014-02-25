//
//  PlayListCell.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayListCell.h"
@interface PlayListCell()
@property (weak, nonatomic) IBOutlet UILabel *BPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backArtView;
@property (weak, nonatomic) IBOutlet UIView *BPMView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteCheckImg;
@end

@implementation PlayListCell{
    BOOL _addList;
    BOOL _isEditMode;
}
//playList 경우
- (void)setPlayListWithTitle:(NSString *)title artist:(NSString *)artist BPM:(NSInteger)bpm image:(UIImage *)image{
    self.backArtView.hidden = NO;
    _isEditMode = NO;
    
    self.albumImageView.layer.masksToBounds = YES;
    self.albumImageView.layer.cornerRadius = self.albumImageView.frame.size.width/2;

    self.BPMLabel.text = [NSString stringWithFormat:@"%d", (int)bpm];
    self.titleLabel.text = title;
    self.artistLabel.text = artist;
    self.BPMView.hidden = NO;
    _addList = NO;
    self.albumImageView.image = image;
    
    [self setSelectedBg];
}
- (void)setSelectedBg{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    UIImageView *selectedImageView = [[UIImageView alloc]initWithFrame:self.frame];
    
    selectedImageView.image = [UIImage imageNamed:@"basic_bg_2_on.png"];
    [selectedBackgroundView addSubview:selectedImageView];
    
    self.selectedBackgroundView = selectedBackgroundView;
}
////edit일 때
//- (void)setEditWithTitle:(NSString *)title artist:(NSString *)artist  {
//    self.titleLabel.text = title;
//    self.artistLabel.text = artist;
//    self.albumImageView.image = [UIImage imageNamed:@"icon_mode_cancel.png"];
//    self.BPMView.hidden = NO;
////    _playList = NO;
//}
//add눌렀을 때
- (void)setAddWithTitle:(NSString *)title artist:(NSString *)artist {
    _isEditMode = NO;
    
    self.titleLabel.text = title;
    self.artistLabel.text = artist;
    self.albumImageView.image = [UIImage imageNamed:@"PlayList_albumDefault.png"];
    _addList = YES;
    self.BPMView.hidden = YES;
    self.backArtView.hidden = YES;
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
//    [super setEditing:editing animated:animated];
    _isEditMode = editing;
    self.BPMView.hidden = _isEditMode;
    self.deleteCheckImg.hidden = !_isEditMode;
//    NSLog(@"setEditing %@",_isEditMode == YES ? @"YES" : @"NO");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

//    NSLog(@"setSelected %@",self.editing == YES ? @"YES" : @"NO");
    //add
    if(_isEditMode){
        if(selected){
            self.deleteCheckImg.image = [UIImage imageNamed:@"icon_songs_check_small.png"];
        }else{
            self.deleteCheckImg.image = [UIImage imageNamed:@"icon_mode_cancel.png"];
        }
    }else if(_addList){
        if(selected){
            self.albumImageView.image = [UIImage imageNamed:@"icon_songs_check_small.png"];
        }else{
            self.albumImageView.image = [UIImage imageNamed:@"icon_songs_none.png"];
        }
    }
    // Configure the view for the selected state
}
@end
