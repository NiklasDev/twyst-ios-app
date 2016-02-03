//
//  UIViewController+FadeHeader.h
//  Twyst
//
//  Created by Nahuel Morales on 9/8/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FadeHeaderControllerAnimatedTransitioning.h"

@interface UIViewController (FadeHeader) <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

- (void)presentViewControllerWithFadeAnimation:(UIViewController *)viewController;
- (void)pushViewControllerWithFadeAnimation:(UIViewController *)viewController;

@end
