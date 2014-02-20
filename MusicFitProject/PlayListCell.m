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
@property (weak, nonatomic) IBOutlet UIView *BPMView;
@end

@implementation PlayListCell{
//    BOOL _playList;
}
//playList 경우
- (void)setPlayListWithTitle:(NSString *)title artist:(NSString *)artist BPM:(NSInteger)bpm image:(UIImage *)image{
    
    
    self.albumImageView.layer.masksToBounds = YES;
    self.albumImageView.layer.cornerRadius = self.albumImageView.frame.size.width/2;
//    self.albumImageView.layer.contents = (id)[UIImage imageNamed:@"artview_round_shadow.png"];

    
    
    self.BPMLabel.text = [NSString stringWithFormat:@"%d", (int)bpm];
    self.titleLabel.text = title;
    self.artistLabel.text = artist;
    self.BPMView.hidden = NO;
//    _playList = YES;
    self.albumImageView.image = image;
}
//edit일 때
- (void)setEditWithTitle:(NSString *)title artist:(NSString *)artist  {
    self.titleLabel.text = title;
    self.artistLabel.text = artist;
    self.albumImageView.image = [UIImage imageNamed:@"icon_mode_cancel.png"];
    self.BPMView.hidden = NO;
//    _playList = NO;
}
//add눌렀을 때
- (void)setAddWithTitle:(NSString *)title artist:(NSString *)artist {
    self.titleLabel.text = title;
    self.artistLabel.text = artist;
    self.albumImageView.image = [UIImage imageNamed:@"PlayList_albumDefault.png"];
//    _playList = NO;
    self.BPMView.hidden = YES;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    //add
//    if(self.BPMView.hidden == YES && _playList == NO){
//        if(selected){
//            self.albumImageView.image = [UIImage imageNamed:@"icon_songs_check_small.png"];
//        }else{
//            self.albumImageView.image = [UIImage imageNamed:@"PlayList_albumDefault.png"];
//        }
//    }else if(self.BPMView.hidden == _playList){
//        if(selected){
//            self.albumImageView.image = [UIImage imageNamed:@"icon_songs_check_small.png"];
//        }else{
//            self.albumImageView.image = [UIImage imageNamed:@"icon_mode_cancel.png"];
//        }
//    }
    // Configure the view for the selected state
}


@end
