//
//  NMImageBurstTransitionAnimation.m
//  Twyst
//
//  Created by Nahuel Morales on 9/2/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMImageBurstTransitionAnimation.h"

@implementation NMImageBurstTransitionAnimation

+ (instancetype)animationWithContainerView:(UIView *)containerView burstView:(UIView *)burstView image:(UIImage *)image {
    NMImageBurstTransitionAnimation *animation = [[self class] animationWithContainerView:containerView];
    animation.burstView = burstView;
    animation.image = image;
    return animation;
}

- (void)prepareAnimation {
    
}

- (void)beginAnimation:(void(^)())completion {
    UIImageView *burstView = [[UIImageView alloc] initWithImage:self.image];
    burstView.contentMode = UIViewContentModeScaleAspectFill;
    burstView.clipsToBounds = YES;
    burstView.frame = [self.containerView convertRect:self.burstView.frame fromView:self.burstView.superview];
    [self.containerView addSubview:burstView];
    [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        burstView.frame = self.containerView.bounds;
    } completion:^(BOOL finished) {
        completion();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [burstView removeFromSuperview];
        });
    }];
}


@end
