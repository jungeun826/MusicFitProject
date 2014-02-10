//
//  DayCell.h
//  Calender
//
//  Created by jungeun on 14. 2. 9..
//  Copyright (c) 2014년 jungeun. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DayCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIButton *dayBtn;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (id)initBlankCell;
- (id)initWithDay:(NSString *)day lastMode:(NSString *)mode;

@end
