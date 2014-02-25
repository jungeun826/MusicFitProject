//
//  PlayListCell.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListCell : UITableViewCell
- (void)setPlayListWithTitle:(NSString *)title artist:(NSString *)artist BPM:(NSInteger)bpm image:(UIImage *)image;
//- (void)setEditWithTitle:(NSString *)title artist:(NSString *)artist;
- (void)setAddWithTitle:(NSString *)title artist:(NSString *)artist;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
@end
