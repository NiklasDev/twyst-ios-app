//
//  UIViewController+FadeHeader.m
//  Twyst
//
//  Created by Nahuel Morales on 9/8/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIViewController+FadeHeader.h"

@implementation UIViewController (FadeHeader)

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    FadeHeaderControllerAnimatedTransitioning *transitioning = [[FadeHeaderControllerAnimatedTransitioning alloc] init];
    transitioning.isDismissTransition = NO;
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    FadeHeaderControllerAnimatedTransitioning *transitioning = [[FadeHeaderControllerAnimatedTransitioning alloc] init];
    transitioning.isDismissTransition = YES;
    return transitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    FadeHeaderControllerAnimatedTransitioning *transitioning = [[FadeHeaderControllerAnimatedTransitioning alloc] init];
    transitioning.isDismissTransition = (operation == UINavigationControllerOperationPop);
    return transitioning;
}

#pragma mark - Present & Push

- (void)presentViewControllerWithFadeAnimation:(UIViewController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.transitioningDelegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)pushViewControllerWithFadeAnimation:(UIViewController *)viewController {
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
