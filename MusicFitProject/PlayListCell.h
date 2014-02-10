//
//  PlayListCell.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListCell : UITableViewCell
- (void)setWithTitle:(NSString *)title artist:(NSString *)artist BPM:(NSInteger)bpm image:(UIImage *)image;
- (void)setWithTitle:(NSString *)title artist:(NSString *)artist;
@end
