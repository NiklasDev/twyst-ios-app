//
//  NMColorBurstTransitionAnimation.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMColorBurstTransitionAnimation.h"
#import "NMCircleView.h"

@implementation NMColorBurstTransitionAnimation

+ (instancetype)animationWithContainerView:(UIView *)containerView burstView:(UIView *)burstView {
    return [[self class] animationWithContainerView:containerView burstView:burstView burstColor:nil];
}

+ (instancetype)animationWithContainerView:(UIView *)containerView burstView:(UIView *)burstView burstColor:(UIColor *)burstColor {
    NMColorBurstTransitionAnimation *animation = [[self class] animationWithContainerView:containerView];
    animation.burstView = burstView;
    animation.burstColor = burstColor;
    return animation;
}


- (void)prepareAnimation {
    
}

- (void)beginAnimation:(void(^)())completion {
    NMCircleView *burstCircleView = [NMCircleView circleWithColor:self.burstColor ? self.burstColor : self.burstView.tintColor];
    CGPoint center = [self.containerView convertPoint:self.burstView.center fromView:self.burstView.superview];
    burstCircleView.center = center;
    [self.containerView addSubview:burstCircleView];
    [UIView animateWithDuration:0.3 delay:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat size = self.containerView.frame.size.width > self.containerView.frame.size.height ? self.containerView.frame.size.width : self.containerView.frame.size.height;
        size = size * 1.5;
        burstCircleView.frame = CGRectMake(center.x - size, center.y - size, 2.0*size, 2.0*size);
        
    } completion:^(BOOL finished) {
        completion();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [burstCircleView removeFromSuperview];
        });
    }];
}

@end
