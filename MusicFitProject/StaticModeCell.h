//
//  StaticModeCell.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 24..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddedModeDelegate.h"

@interface StaticModeCell : UITableViewCell
//@property (weak, nonatomic) id<ModeDelegate> modeDelegate;
-(void)setWithImageName:(NSString *)imageName title:(NSString *)title minBPM:(NSString *)minBPM;
@end
