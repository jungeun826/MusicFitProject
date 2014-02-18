//
//  DayInfoCell.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *modeImgaeView;

- (id)initWithMode:(NSInteger)modeID startTimeString:(NSString *)startTimeString exerTimeString:(NSString *)exerTimeString;
- (NSString *)modeImageName:(NSInteger)modeID;
@end
