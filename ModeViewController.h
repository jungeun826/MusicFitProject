//
//  ModeViewController.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModeToPlayerDelegate.h"

@interface ModeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak) id<ModeToPlayerDelegate> modeToPlayerDegate;

@end
