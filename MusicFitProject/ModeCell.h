//
//  AddedModeCell.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddedModeDelegate.h"
@interface ModeCell : UITableViewCell
@property (weak, nonatomic) id<AddedModeDelegate> addedDelegate;
- (void)setAddedWithTitle:(NSString *)title minBPM:(NSInteger)minBPM maxBPM:(NSInteger)maxBPM modeID:(NSInteger)modeID;
- (void)setStaticWithImageName:(NSString *)imageName title:(NSString *)title minBPM:(NSString *)minBPM modeID:(NSInteger)modeID;
@end
