//
//  StaticModeCell.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "StaticModeCell.h"
@interface StaticModeCell()
@property (weak, nonatomic) IBOutlet UIImageView *modeImageView;
@property (weak, nonatomic) IBOutlet UILabel *title_Label;
@property (weak, nonatomic) IBOutlet UILabel *minBPM_Label;
@end

@implementation StaticModeCell
- (void)setWithImageName:(NSString *)imageName title:(NSString *)title minBPM:(NSString *)minBPM{
        self.modeImageView.image = [UIImage imageNamed:imageName];
        self.title_Label.text = title;
        self.minBPM_Label.text =minBPM;
        [self setSelectedColor];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setSelectedColor{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.2]]; // set color here
    [selectedBackgroundView setAlpha:0.2];
    
    [self setSelectedBackgroundView:selectedBackgroundView];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
