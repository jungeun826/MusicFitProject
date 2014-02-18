//
//  DayInfoCell.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "DayInfoCell.h"
#import "CalendarDayInfo.h"

@implementation DayInfoCell
- (id)initWithMode:(NSInteger)modeID startTimeString:(NSString *)startTimeString exerTimeString:(NSString *)exerTimeString{
    self = [super self];
    if(self){
        self.modeImgaeView.image = [UIImage imageNamed:[self modeImageName:modeID]];
        
        self.infoLabel.text = [NSString stringWithFormat:@"%@ 부터 %@",startTimeString, exerTimeString];
    }
    return self;
}

- (NSString *)modeImageName:(NSInteger)modeID{
    if(modeID == 1)
        return @"icon_mode1.png";
    else if(modeID ==2)
        return @"icon_mode2.png";
    else if(modeID ==3)
        return @"icon_mode3.png";
    else if(modeID ==4)
        return @"icon_mode4.png";
    else
        return @"progressive2.png";
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
