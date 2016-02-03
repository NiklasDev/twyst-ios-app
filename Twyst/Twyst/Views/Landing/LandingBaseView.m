//
//  LandingBaseView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "LandingBaseView.h"
#import "LandingTopBarView.h"

#import "NMEmptyTransitionAnimation.h"

#define kTopBarMinAlpha 0.3

@implementation LandingBaseView

- (void)showInView:(UIView *)view {
    [view addSubview:self];
}

- (void)showKeyboard {
    
}

- (void)hideKeyboard {
    [self endEditing:YES];
}

- (void)handleBtnBackTouch:(id)sender {
    [self.parentViewController handleBtnBackTouch:nil];
}

- (void)handleBtnDoneTouch {
    [self hideKeyboard];
}

- (void)showProcessingView:(BOOL)show {
    [self.parentViewController showProcessingView:show];
}

- (void)landingViewDidAppear {
    [self.parentViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)landingViewWillDisappear {
    
}

- (void)customizeTopBar:(LandingTopBarView*)topBar {
    
}

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    return [NMEmptyTransitionAnimation animationWithContainerView:self];
}

@end
