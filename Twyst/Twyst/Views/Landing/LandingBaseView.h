//
//  LandingBaseView.h
//  Twyst
//
//  Created by Niklas Ahola on 3/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LandingPageViewController.h"
#import "NMTransitionAnimation.h"

@class LandingTopBarView;

@interface LandingBaseView : UIView

@property (nonatomic, retain) LandingPageViewController *parentViewController;
@property (nonatomic, weak) LandingTopBarView *topBarView;

- (void)showInView:(UIView*)view;

- (void)showKeyboard;
- (void)hideKeyboard;

- (void)handleBtnBackTouch:(id)sender;
- (void)handleBtnDoneTouch;

- (void)showProcessingView:(BOOL)show;

- (void)landingViewDidAppear;
- (void)landingViewWillDisappear;

- (void)customizeTopBar:(LandingTopBarView*)topBar;

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender;
@end
