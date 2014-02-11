//
//  AddedModeCell.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "AddedModeCell.h"

@interface AddedModeCell()
@property (weak, nonatomic) IBOutlet UIButton *imageView;
@property (weak, nonatomic) IBOutlet UILabel *BPMRangeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selecteImageView;

@end
@implementation AddedModeCell
- (void)setWithminBPM:(NSString *)minBPM maxBPM:(NSString *)maxBPM{
    NSString *text = [NSString stringWithFormat:@"%@ ~ %@",minBPM, maxBPM];
    [self changeBackground];
    self.BPMRangeLabel.text = text;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)changeBackground{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
    backgroundImageView.image = [UIImage imageNamed:@"basic_bg.png"];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    
    [self setSelecteImageView:backgroundImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (IBAction)deleteCustomizeCell:(id)sender {
    [self.addedDelegate deleteCell];
}
@end
