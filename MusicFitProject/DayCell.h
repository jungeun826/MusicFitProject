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
@property (weak, nonatomic) IBOutlet UIImageView *modeImageView;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;


- (id)initBlankCell;
- (id)initWithDay:(NSString *)day lastMode:(NSInteger)mode;
@end
