//
//  DayCell.m
//  Calender
//
//  Created by jungeun on 14. 2. 9..
//  Copyright (c) 2014년 jungeun. All rights reserved.
//

#import "DayCell.h"
@interface DayCell()

@end
@implementation DayCell{
    BOOL _selected;
}
- (id)initBlankCell{
    self = [super init];
    if(self){
        self.dayLabel.hidden = YES;
        self.modeImageView.hidden = YES;
        self.selectImageView.hidden = YES;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderWidth = 1.0f;
    }
    return self;
}
- (id)initWithDay:(NSString *)day lastMode:(NSInteger)mode{
    self = [super init];
    if(self){
        CGFloat borderWidth = 1.0f;
        UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"setting_calendar_today.png"]];
        bgView.layer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"setting_calendar_today.png"]].CGColor;
        bgView.layer.borderWidth = borderWidth;
        
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderWidth = 1.0f;
        
        
        self.selectedBackgroundView = bgView;
        
        self.dayLabel.hidden = NO;
        self.modeImageView.hidden = NO;
        self.selectImageView.hidden = NO;
        _selected = NO;
        if(mode == 0){
            self.dayLabel.text = day;
            self.modeImageView.image = nil;
        }else if(mode == 1){
            self.dayLabel.text = @"";
            [self.modeImageView  setImage:[UIImage imageNamed:@"icon_mode1.png"]];
        }else if(mode == 2){
                        self.dayLabel.text = @"";
            [self.modeImageView  setImage:[UIImage imageNamed:@"icon_mode2.png"]];
        }else if(mode == 3){
            self.dayLabel.text = @"";
            [self.modeImageView  setImage:[UIImage imageNamed:@"icon_mode3.png"]];
        }else if(mode == 4){
            self.dayLabel.text = @"";
            [self.modeImageView  setImage:[UIImage imageNamed:@"icon_mode4.png"]];
        }else{
            self.dayLabel.text = @"";
           [self.modeImageView  setImage:[UIImage imageNamed:@"pop.png"]];
        }
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
