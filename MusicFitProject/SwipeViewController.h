//
//  SwipeViewController.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 28..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIViewController+SwipeController.h"
#import "SwipeGestureRecognizer.h"

typedef enum {
    ShiftHorizontal,
    ShiftVertical
}ShiftDirection;


@protocol SwipeControllerDelegate <NSObject>
@optional
//- (void)willMoveToViewController:(UIViewController *)viewController atPosition:(Position)position;
- (void)didMoveToViewController:(UIViewController *)viewController atPosition:(Position)position;
@end

//@protocol CalendarToPlayerDelegate <NSObject>
//- (void)hiddenPlayer;
//- (void)showPlayer;
//@end;

@interface SwipeViewController : UIViewController

//@property (weak) id<CalendarToPlayerDelegate> delegate;

@property(weak, readonly, nonatomic) UIViewController *visibleViewController;
@property(strong, readonly, nonatomic) NSArray *viewControllers;
@property(assign, readonly, nonatomic) NSInteger maxRow;
@property(assign, readonly, nonatomic) NSInteger maxCol;
@property BOOL doSwipe;
@property NSInteger curCol;

- (id)initWithFrame:(CGRect)frame;

- (void)resetPositions:(NSArray *)viewControllers;

- (void)setControllers:(NSArray *)controllers;

//- (void)goToViewController:(UIViewController *)controller way:(Way)way animated:(BOOL)animated completion:(void (^)(void))completion;

- (void)moveLeftAnimated:(BOOL)animated;

- (void)moveRightAnimated:(BOOL)animated;

- (void)moveLeftAnimated:(BOOL)animated withCompletion:(void (^)(void))completion;

- (void)moveRightAnimated:(BOOL)animated withCompletion:(void (^)(void))completion;

- (UIViewController *)getControllerAtPosition:(Position)position;
@end
