//
//  AddedModeCell.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddedModeDelegate.h"
@interface AddedModeCell : UITableViewCell
@property (weak, nonatomic) id<AddedModeDelegate> addedDelegate;
//@property (weak, nonatomic) id<ModeDelegate> modeDelegate;
- (void)setWithminBPM:(NSString *)minBPM maxBPM:(NSString *)maxBPM;

@end
