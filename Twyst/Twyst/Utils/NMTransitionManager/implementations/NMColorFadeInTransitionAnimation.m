//
//  NMColorFadeInTransitionAnimation.m
//  Twyst
//
//  Created by Nahuel Morales on 9/1/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMColorFadeInTransitionAnimation.h"

@implementation NMColorFadeInTransitionAnimation

+ (instancetype)animationWithContainerView:(UIView *)containerView color:(UIColor *)color {
    NMColorFadeInTransitionAnimation *animation = [[self class] animationWithContainerView:containerView];
    animation.color = color;
    return animation;
}

- (void)prepareAnimation {
    
}

- (void)beginAnimation:(void(^)())completion {
    UIView *colorView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    colorView.backgroundColor = self.color;
    colorView.alpha = 0.0;
    [self.containerView addSubview:colorView];
    [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        colorView.alpha = 1.0;
    } completion:^(BOOL finished) {
        completion();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [colorView removeFromSuperview];
        });
    }];
}

@end
