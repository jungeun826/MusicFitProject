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
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation PlayListCell

- (void)setWithTitle:(NSString *)title artist:(NSString *)artist BPM:(NSInteger)bpm{
    self.BPMLabel.text = [NSString stringWithFormat:@"%d", (int)bpm];
    self.titleLabel.text = title;
    self.artistLabel.text = artist;
    self.BPMView.hidden = NO;
    self.deleteBtn.hidden = YES;
}
- (void)setWithTitle:(NSString *)title artist:(NSString *)artist{
    self.titleLabel.text = title;
    self.artistLabel.text = artist;
    self.deleteBtn.hidden = NO;
    self.BPMView.hidden = YES;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    if(self.BPMView.hidden == YES){
        BOOL selected = self.deleteBtn.selected;
        self.deleteBtn.selected = !self.deleteBtn.selected;
        if(selected ==YES){
            self.deleteBtn.imageView.image = [UIImage imageNamed:@"icon_songs_cancel.png"];
        }else{
            self.deleteBtn.imageView.image = [UIImage imageNamed:@"icon_songs_cancel.png"];
        }
    }
    // Configure the view for the selected state
}


@end
