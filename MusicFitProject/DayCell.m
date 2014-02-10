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
@implementation DayCell
- (id)initBlankCell{
    self = [super init];
    if(self){
        self.dayLabel.hidden = YES;
        self.dayBtn.hidden = YES;
    }
    return self;
}
- (id)initWithDay:(NSString *)day lastMode:(NSString *)mode{
    self = [super init];
    if(self){
        self.dayLabel.hidden = NO;
        self.dayBtn.hidden = NO;
        if(mode == nil){
            self.dayLabel.text = day;
        }else if([mode isEqualToString:@"걷기"]){
            self.dayLabel.text = @"";
            [self.dayBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.dayBtn setImage:[UIImage imageNamed:@"48.png"] forState:UIControlStateSelected];
        }else if([mode isEqualToString:@"조깅,트레밀러"]){
                        self.dayLabel.text = @"";
            [self.dayBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.dayBtn setImage:[UIImage imageNamed:@"48.png"] forState:UIControlStateSelected];
        }else if([mode isEqualToString:@"뛰기"]){
            self.dayLabel.text = @"";
            [self.dayBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.dayBtn setImage:[UIImage imageNamed:@"48.png"] forState:UIControlStateSelected];
        }else if([mode isEqualToString:@"사이클링"]){
            self.dayLabel.text = @"";
            [self.dayBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.dayBtn setImage:[UIImage imageNamed:@"48.png"] forState:UIControlStateSelected];
        }else{
            self.dayLabel.text = @"";
            [self.dayBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.dayBtn setImage:[UIImage imageNamed:@"48.png"] forState:UIControlStateSelected];
        }
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected];
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
