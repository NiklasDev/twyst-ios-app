//
//  UIView+Animation.m
//  Twyst
//
//  Created by Niklas Ahola on 8/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

- (void)startPulseAnimation:(CGFloat)pulseScale duration:(CGFloat)duration {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = duration;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1 + pulseScale];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1 - pulseScale];
    [self.layer addAnimation:scaleAnimation forKey:@"pulsate"];
}

- (void)stopPulseAnimation {
    [self.layer removeAnimationForKey:@"pulsate"];
}

- (void)bounceAnimation:(CGFloat)duration {
    [self bounceAnimation:duration scale:0.1f];
}

- (void)bounceAnimation:(CGFloat)duration scale:(CGFloat)scale {
    [UIView animateWithDuration:duration / 1.5 animations:^{
        self.transform = CGAffineTransformMakeScale(1 + scale, 1 + scale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            self.transform = CGAffineTransformMakeScale(1 - scale, 1 - scale);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration / 2 animations:^{
                self.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

@end
