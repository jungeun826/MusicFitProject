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
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
