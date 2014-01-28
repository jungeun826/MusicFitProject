//
//  MainViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 15..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "PlayViewController.h"
#import "ModeViewController.h"
#import "AppDelegate.h"
@interface PlayViewController ()

@end

@implementation PlayViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)moveToMode:(id)sender {
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    ModeViewController *modeVC = [[ModeViewController alloc]init];
    app.window.rootViewController = modeVC;
}
@end
