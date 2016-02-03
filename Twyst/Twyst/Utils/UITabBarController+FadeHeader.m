//
//  UITabBarController+FadeHeader.m
//  Twyst
//
//  Created by Nahuel Morales on 9/8/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UITabBarController+FadeHeader.h"

@implementation UITabBarController (FadeHeader)

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
           animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                             toViewController:(UIViewController *)toVC {
    
    FadeHeaderControllerAnimatedTransitioning *transitioning = [[FadeHeaderControllerAnimatedTransitioning alloc] init];
    transitioning.isDismissTransition = NO;
    return transitioning;
}

- (UIView *)headerView {
    UIViewController *viewController = self.selectedViewController;
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)viewController;
        [[navController visibleViewController] view]; // force layout
        if ([[navController visibleViewController] respondsToSelector:@selector(headerView)]) {
            return [(UIViewController<HeaderProtocol> *)[navController visibleViewController] headerView];
        }
    } else {
        if ([viewController respondsToSelector:@selector(headerView)]) {
            return [(UIViewController<HeaderProtocol> *)viewController headerView];
        }
    }
    return nil;
}

@end
