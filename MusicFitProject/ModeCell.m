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
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end
@implementation ModeCell{
    NSInteger _modeID;
}

//added mode
- (void)setAddedWithTitle:(NSString *)title minBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM modeID:(NSInteger)modeID{
    
    _modeID = modeID;
    self.modeImageView.image = [UIImage imageNamed:@"icon_mode_music.png"];
    self.title_Label.text = title;
    self.rangeImageView.image = [UIImage imageNamed:@"icon_mode_cancel"];
    self.rangeImageView.hidden = YES;
    CGRect frame = self.BPMView.frame;
    frame.origin.x += 10;
    [self.BPMView setFrame:frame];
    self.deleteBtn.hidden = YES;
    self.editingAccessoryType = UITableViewCellEditingStyleDelete;
//    self.editingAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop.png"]];
//    self.BPMView.hidden = YES;
    [self.BPMRangeLabel setNumberOfLines:2];
    [self.BPMRangeLabel setTextAlignment:NSTextAlignmentCenter];
    
//    UIFont *font = self.BPMRangeLabel.font;
//    [font fontWithSize:13];
    
    [self.BPMRangeLabel.font fontWithSize:12];
    self.BPMRangeLabel.text = [NSString stringWithFormat:@"%d  ~\n %6d", minBPM,maxBPM];
//    self.BPMRangeLabel.hidden = YES;
    [self setSelectedBg];
}

//staticMode
- (void)setStaticWithImageName:(NSString *)imageName title:(NSString *)title minBPM:(NSString *)minBPM modeID:(NSInteger)modeID{
    _modeID = modeID;
    
    self.modeImageView.image = [UIImage imageNamed:imageName];
    self.rangeImageView.image = [UIImage imageNamed:@"icon_mode_arrow.png"];
    self.title_Label.text = title;
    self.BPMRangeLabel.text = minBPM;
        self.deleteBtn.hidden = YES;
    //[self setSelectedBg];
}
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesBegan");
//}

//-(void)layoutSubviews {
//    for (UIView *view in self.contentView.subviews) {
//        NSLog(@"subview : %@", view);
//    }
//}
- (IBAction)modeCellDelete:(id)sender {
    [self.addedDelegate deleteModeWithModeID:_modeID];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    self.modeImageView.hidden = editing;
    self.deleteBtn.hidden = !editing;
}
- (void)setSelectedBg{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    UIImageView *selectedImageView = [[UIImageView alloc]initWithFrame:self.frame];
    
    selectedImageView.image = [UIImage imageNamed:@"basic_bg_2_on.png"];
    [selectedBackgroundView addSubview:selectedImageView];
//    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.3]]; // set color here
    [selectedBackgroundView setAlpha:0.4];

    self.selectedBackgroundView=selectedBackgroundView;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
@end
