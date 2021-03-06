//
//  SwipeViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 28..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "SwipeViewController.h"
#import "SwipeView.h"
#import "PlayerViewController.h"
//#define alphaHiddenControllers 0.0


@interface SwipeViewController ()
@property(strong, nonatomic) SwipeGestureRecognizer *swipeGestureRecognizer;
@property(assign, nonatomic) CGPoint positionBeforeSwipe;
@property(assign, nonatomic) Way lastSwipeWay;
@property(strong, nonatomic) NSMutableArray *destinationControllersInWay;
@end

@implementation SwipeViewController
- (id)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.view = [[SwipeView alloc] initWithFrame:frame];
        
        _maxRow = 0;
        _maxCol = 3;
        self.doSwipe = YES;
        self.curCol = 0;
        return self;
    }
    return nil;
}

- (void)setControllers:(NSArray *)controllers{
    [self setControllers:controllers withFrame:self.view.frame];
}
- (void)viewDidLoad{
    [super viewDidLoad];
}
#pragma mark - Public methods
- (void)resetPositions:(NSArray *)viewControllers {
    UIViewController *currentVisibleViewController = _visibleViewController;
    [self setControllers:viewControllers withFrame:[[UIScreen mainScreen] applicationFrame]];
    _visibleViewController = currentVisibleViewController;
}

- (void)moveLeftAnimated:(BOOL)animated{
    [self moveLeftAnimated:animated withCompletion:nil];
}

- (void)moveRightAnimated:(BOOL)animated{
    [self moveRightAnimated:animated withCompletion:nil];
}


- (void)moveLeftAnimated:(BOOL)animated withCompletion:(void (^)(void))completion{
    [self goToViewController:_visibleViewController.leftViewController way:WayHorizontal direction:DirectionRight animated:animated completion:completion];
}

- (void)moveRightAnimated:(BOOL)animated withCompletion:(void (^)(void))completion{
    UIViewController *rightVC =_visibleViewController.rightViewController;
    [self goToViewController:rightVC way:WayHorizontal direction:DirectionRight animated:animated completion:completion];
}

- (UIViewController *)getControllerAtPosition:(Position)position{
    NSPredicate *positionPredicate = [NSPredicate predicateWithFormat:@"row == %d AND col == %d", position.row, position.col];
    NSArray *viewControllersWithMatchedPosition = [_viewControllers filteredArrayUsingPredicate:positionPredicate];
    if (viewControllersWithMatchedPosition.count == 0)
        return nil;
    
    return [viewControllersWithMatchedPosition objectAtIndex:0];
}

- (void)goToViewController:(UIViewController *)controller way:(Way)way direction:(Direction)direction animated:(BOOL)animated completion:(void (^)(void))completion{
    [self goToViewController:controller translation:CGPointZero velocity:CGPointZero way:way direction:direction animated:animated completion:completion];
}


#pragma mark - Private methods

- (void)setControllers:(NSArray *)controllers withFrame:(CGRect)frame{
    _viewControllers = controllers;

    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    int index = 0;
    for (UIViewController *child in _viewControllers) {
        Position left = child.position;
        left.col = left.col - 1;
        Position right = child.position;
        right.col = right.col + 1;
        Position top = child.position;
        top.row = top.row - 1;
        Position bottom = child.position;
        bottom.row = bottom.row + 1;
        
        child.leftViewController = [self getControllerAtPosition:left];
        child.rightViewController = [self getControllerAtPosition:right];
        
        if(index == 3){
            CGRect frameInsideMasterView = child.view.frame;
            frameInsideMasterView.origin.x = screenWidth * child.col;
            frameInsideMasterView.origin.y = screenHeight * child.row;
            frameInsideMasterView.size.height = 480;
            child.view.frame = frameInsideMasterView;
        }
        CGRect frameInsideMasterView = child.view.frame;
        frameInsideMasterView.origin.x = screenWidth * child.col;
        frameInsideMasterView.origin.y = screenHeight * child.row;
        child.view.frame = frameInsideMasterView;
        index ++;
    }
    
    CGSize contentSize = CGSizeMake(screenWidth * (_maxCol + 1), screenHeight * (_maxRow + 1));
    CGRect newFrame = self.view.frame;
    newFrame.size = contentSize;
    self.view.frame = newFrame;
    
    for (UIViewController *child in _viewControllers) {
        [self addChildViewController:child];
        [self.view addSubview:child.view];
        [child didMoveToParentViewController:self];
    }
    
    _swipeGestureRecognizer = [[SwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetected:)];
    
    [self.view addGestureRecognizer:_swipeGestureRecognizer];
    
    _visibleViewController = [_viewControllers objectAtIndex:0];
    _curCol = 0;
}

- (void)swipeDetected:(SwipeGestureRecognizer *)swipe{
    if(self.doSwipe == NO)
        return;
    
    if (swipe.state == UIGestureRecognizerStateBegan) {
        _positionBeforeSwipe = self.view.frame.origin;
        _lastSwipeWay = swipe.way;
        [self setDestinationControllersWithWay:swipe.way];
    }else if (swipe.state == UIGestureRecognizerStateChanged) {
        [self handleSwipeWithDirection:swipe.direction way:swipe.way velocity:[swipe velocityInView:self.view] translation:[swipe translationInView:self.view]];
    }else if (swipe.state == UIGestureRecognizerStateEnded) {
        [self handleEndedSwipeWithDirection:swipe.direction way:swipe.way velocity:[swipe velocityInView:self.view] translation:[swipe translationInView:self.view]];
    }
}

- (void)setDestinationControllersWithWay:(Way)way{
    _destinationControllersInWay = [[NSMutableArray alloc]init];
    if (way == WayHorizontal) {
        if (_visibleViewController.leftViewController) {
            [_destinationControllersInWay addObject:_visibleViewController.leftViewController];
        }
        if (_visibleViewController.rightViewController) {
            [_destinationControllersInWay addObject:_visibleViewController.rightViewController];
        }
    }
}

- (void)handleSwipeWithDirection:(Direction)direction way:(Way)way velocity:(CGPoint)velocity translation:(CGPoint)translation{
    if (_lastSwipeWay != way || way == WayVertical)
        return;
    BOOL nextControllerExists = NO;
    nextControllerExists |= direction == DirectionRight && _visibleViewController.rightViewController;
    nextControllerExists |= direction == DirectionLeft && _visibleViewController.leftViewController;
    
    if( direction == DirectionDown || direction == DirectionUp || !nextControllerExists)
        return;
    
    if (way == WayHorizontal)
        translation.y = 0;
    else
        return;
    
    CGRect frame = self.view.frame;
    CGPoint newOrigin;
    newOrigin.x = _positionBeforeSwipe.x + translation.x;
//    newOrigin.y = _positionBeforeSwipe.y + translation.y;
//    CGFloat x = 0.0f;
    
//    if(newOrigin.x < x){
//        newOrigin.x = x;
//    }
    frame.origin = newOrigin;
    self.view.frame = frame;
    
    
    CGFloat movedPoints = 0;
    CGFloat totalPoints = 0;
    
    if (way == WayHorizontal) {
        totalPoints = _visibleViewController.view.frame.size.width;
        movedPoints = fabsf(translation.x);
    }
}

- (void)handleEndedSwipeWithDirection:(Direction)direction way:(Way)way velocity:(CGPoint)velocity translation:(CGPoint)translation{
    const CGFloat horizontalThreshold = _visibleViewController.view.frame.size.width / 4;
    const CGFloat velocityThreshold = 1000;
    
    BOOL nextControllerExists = NO;
    nextControllerExists |= direction == DirectionRight && _visibleViewController.rightViewController;
    nextControllerExists |= direction == DirectionLeft && _visibleViewController.leftViewController;
    
    if( direction == DirectionDown || direction == DirectionUp || !nextControllerExists)
        return;
    
    BOOL overHorizontalThreshold = fabs(translation.x) > horizontalThreshold;
    BOOL overVelocityXThreshold = fabs(velocity.x) > velocityThreshold;
    
    if ( translation.x == 0 || translation.y == 0) {
        [self goToViewController:_visibleViewController translation:CGPointZero velocity:CGPointZero way:WayNone direction:direction animated:YES completion:^{
        }];
        return;
    }
    if (way == WayHorizontal && way == _lastSwipeWay && (overHorizontalThreshold || overVelocityXThreshold)) {
        if (direction == DirectionLeft) {
//            NSLog(@"goto left controller");
            [self goToViewController:_visibleViewController.leftViewController translation:translation velocity:velocity way:WayHorizontal direction:direction animated:YES completion:^{
            }];
            return;
        }
        else if (direction == DirectionRight) {
//            NSLog(@"goto right controller");
            [self goToViewController:_visibleViewController.rightViewController translation:translation velocity:velocity way:WayHorizontal direction:direction animated:YES completion:^{
            }];
            return;
        }
    }
}

- (void)goToViewController:(UIViewController *)newController translation:(CGPoint)translation velocity:(CGPoint)velocity way:(Way)way  direction:(Direction)direction animated:(BOOL)animated completion:(void (^)(void))completion{
//    [_delegate willMoveToViewController:newController atPosition:newController.position];
    
    NSTimeInterval velocityAnimation = INT_MAX;
    if (!animated)
        velocityAnimation = 0;
    else {
        if (translation.x == 0 && translation.y == 0 && velocity.x == 0 && velocity.y == 0)
            velocityAnimation = 0.3;
        else {
            if (way == WayHorizontal) {
                CGFloat points = fabsf(_visibleViewController.view.frame.size.width - (CGFloat)fabs(translation.x));
                CGFloat panVelocity = fabsf(velocity.x);
                if (panVelocity > 0)
                    velocityAnimation = points / panVelocity;
            }
            velocityAnimation = MAX(0.3, MIN(velocityAnimation, 0.7));
        }
    }
   
//    if(self.curCol == 2 && direction ==DirectionRight){
//        
//
//    }else if(self.curCol == 3 && direction ==DirectionLeft){
//        
//    }
    if(_visibleViewController.rightViewController.rightViewController == nil && direction ==DirectionRight){
        //            [self.delegate hiddenPlayer];
        PlayerViewController *playerVC = (PlayerViewController *)[self parentViewController];
        [playerVC movePlayerWithDirection:MoveToLeft];
    }else if(_visibleViewController.rightViewController == nil && direction ==DirectionLeft){
        PlayerViewController *playerVC = (PlayerViewController *)[self parentViewController];
        [playerVC movePlayerWithDirection:MoveToRight];
    }
    [UIView animateWithDuration:velocityAnimation animations:^{
        CGRect frameForVisibleViewController = self.view.frame;
        frameForVisibleViewController.origin.x = -newController.view.frame.origin.x;
        self.view.frame = frameForVisibleViewController;
        
        [_visibleViewController viewWillDisappear:animated];
        [newController viewWillAppear:animated];

        
    }completion:^(BOOL finished) {
        if (finished) {
            // call UIKit view callbacks. not sure it's right
           
            _visibleViewController = newController;
            if(direction == DirectionRight)
                self.curCol++;
            else if(direction == DirectionLeft)
                self.curCol--;
//            [_delegate didMoveToViewController:newController atPosition:newController.position];
            if (completion)
                completion();
        }
    }];
    
    
    
}
@end
