//
//  SwipeView.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 29..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "SwipeView.h"

@implementation SwipeView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL pointInside = NO;
    // step through our subviews' frames that exist out of our bounds
    for (UIView *subview in self.subviews) {
        if (!CGRectContainsRect(self.bounds, subview.frame) && [subview pointInside:[self convertPoint:point toView:subview] withEvent:event]) {
            pointInside = YES;
            break;
        }
    }
    
    // now check inside the bounds
    if (!pointInside) {
        pointInside = [super pointInside:point withEvent:event];
    }
    
    return pointInside;
}
@end
