//
//  FadeNavigationControllerAnimatedTransitioning.m
//  Twyst
//
//  Created by Nahuel Morales on 9/7/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FadeHeaderControllerAnimatedTransitioning.h"
#import <QuartzCore/QuartzCore.h>

@interface FadeHeaderControllerAnimatedTransitioning ()

@end

@implementation FadeHeaderControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];

    UIView *headerViewFrom = [self getHeaderViewfrom:fromController];
    UIView *headerViewTo = [self getHeaderViewfrom:toController];
    
    headerViewFrom = [self getImageViewFromView:headerViewFrom];
    headerViewFrom.frame = headerViewTo.frame;
    [headerViewTo.superview addSubview:headerViewFrom];
    
    toController.view.frame = [transitionContext finalFrameForViewController:toController];
    headerViewTo.alpha = 0.0;
    
    if (self.isDismissTransition) {
        fromController.view.alpha = 0.0;
        [fromController.view removeFromSuperview];
    }
    [containerView addSubview:toController.view];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        //fromNavController.view.alpha = 0.0;
        headerViewTo.alpha = 1.0;
        headerViewFrom.alpha = 0.0;
    } completion:^(BOOL finished) {
        [headerViewFrom removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (UIView *)getHeaderViewfrom:(UIViewController *)viewController {
    [viewController view]; // force layout
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)viewController;
        [[navController visibleViewController] view]; // force layout
        if ([[navController visibleViewController] respondsToSelector:@selector(headerView)]) {
            return [(UIViewController<HeaderProtocol> *)[navController visibleViewController] headerView];
        }
        
        NSLog(@"Header Protocol not implemented in class %@", [[navController visibleViewController] class]);
    } else {
        if ([viewController respondsToSelector:@selector(headerView)]) {
            return [(UIViewController<HeaderProtocol> *)viewController headerView];
        }
        
        NSLog(@"Header Protocol not implemented in class %@", [viewController class]);
    }
    
    return nil;
}

- (UIImageView *)getImageViewFromView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = view.frame;
    return imageView;
}

@end
