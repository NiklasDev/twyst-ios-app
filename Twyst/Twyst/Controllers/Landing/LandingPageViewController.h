//
//  LandingPageViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMSimpleTransition.h"

@class LandingBaseView;

@interface LandingPageViewController : UIViewController

@property (nonatomic, assign) BOOL isLogoAnimate;
@property (nonatomic, weak) IBOutlet UIView *topBarContainer;

- (id)initWithNewPassword;
- (id)initWithUsername;
- (id)initWithVerifyPhone;

- (void)pushAnimatedView:(LandingBaseView*)newView slideEnabled:(BOOL)slideEnabled animation:(NMTransitionAnimation *)outroAnimation sender:(id)sender;
- (void)pushView:(LandingBaseView*)view animated:(BOOL)animated;
- (void)popView:(BOOL)animated;

- (void)handleBtnBackTouch:(id)sender;
- (void)handleBtnDoneTouch:(id)sender;

- (void)showProcessingView:(BOOL)show;

@end
