//
//  editModeViewController.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 6..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EditListToPlayerDelegate.h"

@interface EditModeViewController : UIViewController
@property (strong) NSMutableArray *addSongList;

@property (weak) id<EditListToPlayerDelegate> editListToPlayerDelegate;

@end
