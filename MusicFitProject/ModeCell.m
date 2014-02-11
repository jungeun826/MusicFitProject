//
//  AddedModeCell.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ModeCell.h"

@interface ModeCell()
@property (weak, nonatomic) IBOutlet UIImageView *modeImageView;
@property (weak, nonatomic) IBOutlet UILabel *title_Label;
@property (weak, nonatomic) IBOutlet UILabel *BPMRangeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rangeImageView;
@property (weak, nonatomic) IBOutlet UIView *BPMView;

@end
@implementation ModeCell
//added mode
- (void)setAddedWithTitle:(NSString *)title minBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM{
    self.modeImageView.image = [UIImage imageNamed:@"icon_mode_music.png"];
    self.title_Label.text = title;
    self.rangeImageView.image = [UIImage imageNamed:@"icon_mode_cancel"];
    self.rangeImageView.hidden = YES;
//    self.BPMView.hidden = YES;
    [self.BPMRangeLabel setNumberOfLines:2];
    [self.BPMRangeLabel setTextAlignment:NSTextAlignmentCenter];
    
//    UIFont *font = self.BPMRangeLabel.font;
//    [font fontWithSize:13];
    
    [self.BPMRangeLabel.font fontWithSize:12];
    self.BPMRangeLabel.text = [NSString stringWithFormat:@"%d  ~\n %6d", minBPM,maxBPM];
    CGRect frame = self.BPMView.frame;
    frame.origin.x += 10;
    self.BPMView.frame = frame;
//    self.BPMRangeLabel.hidden = YES;
    [self setSelectedColor];
}

//staticMode
- (void)setStaticWithImageName:(NSString *)imageName title:(NSString *)title minBPM:(NSString *)minBPM{
    self.modeImageView.image = [UIImage imageNamed:imageName];
    self.rangeImageView.image = [UIImage imageNamed:@"icon_mode_arrow.png"];
    self.title_Label.text = title;
    self.BPMRangeLabel.text = minBPM;
    [self setSelectedColor];
}


- (void)setSelectedColor{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.2]]; // set color here
    [selectedBackgroundView setAlpha:0.2];
    
    [self setSelectedBackgroundView:selectedBackgroundView];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
@end
