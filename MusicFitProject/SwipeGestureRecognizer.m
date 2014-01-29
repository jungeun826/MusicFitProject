
#import "SwipeGestureRecognizer.h"

@implementation SwipeGestureRecognizer

- (Direction)direction{
  CGPoint velocity = [self velocityInView:self.view.window];
    if (fabs(velocity.y) > fabs(velocity.x)) {
        if (velocity.y > 0)
            return DirectionUp;
        else
            return DirectionDown;
    }else {
        if (velocity.x > 0)
            return DirectionLeft;
        else
            return DirectionRight;
    }
}
- (Way)way{
  CGPoint velocity = [self velocityInView:self.view.window];
  if (fabs(velocity.y) > fabs(velocity.x))
    return WayVertical;
  else
    return WayHorizontal;
}

@end
