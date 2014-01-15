//
//  ViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 10..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "FirstViewController.h"
#import "BPMAnalyzeViewController.h"
@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIView *BPMContainer;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)skipTutorial:(id)sender {
    self.BPMContainer.hidden = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
