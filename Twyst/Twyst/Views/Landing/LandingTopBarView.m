//
//  LandingTopBarView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "LogoView.h"
#import "LoginView.h"
#import "SignupView.h"
#import "UsernameView.h"
#import "ForgotPwdView.h"
#import "NewPasswordView.h"
#import "InviteCodeView.h"
#import "WhosHereView.h"
#import "VerifyPhoneView.h"
#import "VerifyCodeView.h"
#import "NoContactsView.h"
#import "LandingContactView.h"
#import "NoFriendsView.h"
#import "LandingFriendView.h"

#import "LandingTopBarView.h"

#import "NMTransitionManager.h"
#import "NMEntranceTransitionAnimation.h"
#import "NMEntranceElementTop.h"
#import "NMEntranceElementFadeIn.h"

@interface LandingTopBarView () {
    CGRect _frameBack;
    CGRect _frameTitle;
    CGRect _frameDone;
    CGFloat _doneFontSize;
}

@end

@implementation LandingTopBarView

+ (LandingTopBarView*)topBarWithLandingView:(LandingBaseView*)landingView {
    LandingTopBarView *topBar = [[LandingTopBarView alloc] initWithLandingView:landingView];
    landingView.topBarView = topBar;
    return topBar;
}

- (id)initWithLandingView:(LandingBaseView*)landingView {
    self = [super init];
    if (self) {
        [self initMembers];
        [self initViewWithLandingView:landingView];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            _frameBack = CGRectMake(0, 22, 41, 40);
            _frameTitle = CGRectMake(82, 22, 211, 40);
            _frameDone = CGRectMake(316, 22, 48, 40);
            _doneFontSize = 17;
            break;
        case DeviceTypePhone6Plus:
            _frameBack = CGRectMake(3, 26, 40, 40);
            _frameTitle = CGRectMake(102, 26, 210, 40);
            _frameDone = CGRectMake(351, 19, 48, 40);
            _doneFontSize = 17;
            break;
        default:
            _frameBack = CGRectMake(0, 22, 40, 40);
            _frameTitle = CGRectMake(55, 22, 210, 40);
            _frameDone = CGRectMake(264, 22, 48, 40);
            _doneFontSize = 16;
            break;
    }
}

- (void)initViewWithLandingView:(LandingBaseView*)landingView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, bounds.size.width, UI_STATUS_BAR_HEIGHT + UI_TOP_BAR_HEIGHT);
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
    
    if ([landingView isKindOfClass:[NoContactsView class]] ||
        [landingView isKindOfClass:[LandingContactView class]] ||
        [landingView isKindOfClass:[NoFriendsView class]] ||
        [landingView isKindOfClass:[LandingFriendView class]]) {
        UIImage *imageTopBar = [UIImage imageNamedForDevice:@"top-bar-landing"];
        CGRect rectTopBarImage = CGRectMake(0, 0, imageTopBar.size.width, imageTopBar.size.height);
        UIImageView *topBar = [[UIImageView alloc] initWithFrame:rectTopBarImage];
        topBar.image = imageTopBar;
        [self addSubview:topBar];
    }
    
    if (![landingView isKindOfClass:[LogoView class]] &&
        ![landingView isKindOfClass:[InviteCodeView class]] &&
        ![landingView isKindOfClass:[WhosHereView class]]) {
        
        [landingView.parentViewController.topBarContainer setUserInteractionEnabled:YES];
        
        // add title
        self.labelTitle = [[HeaderLabel alloc] initWithFrame:_frameTitle];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.textColor = Color(49, 47, 60);
        self.labelTitle.text = [self titleForLandingView:landingView];
        self.labelTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.labelTitle];
        
        // add back button
        if (![landingView isKindOfClass:[NoFriendsView class]] &&
            ![landingView isKindOfClass:[LandingFriendView class]]) {
            self.btnBack = [BounceButton buttonWithType:UIButtonTypeCustom];
            self.btnBack.frame = _frameBack;
            [self.btnBack setImage:[UIImage imageNamedForDevice:@"btn-landing-back-on"] forState:UIControlStateNormal];
            [self.btnBack setImage:[UIImage imageNamedForDevice:@"btn-landing-back-hl"] forState:UIControlStateHighlighted];
            [self.btnBack addTarget:landingView.parentViewController action:@selector(handleBtnBackTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.btnBack];
        }
        
        // add done button
        if ([Global deviceType] == DeviceTypePhone4) {
            if (![landingView isKindOfClass:[NoContactsView class]] &&
                ![landingView isKindOfClass:[VerifyPhoneView class]] &&
                ![landingView isKindOfClass:[VerifyCodeView class]] &&
                ![landingView isKindOfClass:[NoFriendsView class]] &&
                ![landingView isKindOfClass:[LandingFriendView class]]) {
                self.btnDone = [BounceButton buttonWithType:UIButtonTypeCustom];
                self.btnDone.frame = _frameDone;
                [self.btnDone setTitle:[self buttonTitleForLandingView:landingView] forState:UIControlStateNormal];
                [self.btnDone setTitleColor:Color(58, 50, 88) forState:UIControlStateNormal];
                [self.btnDone setTitleColor:Color(91, 87, 111) forState:UIControlStateHighlighted];
                [self.btnDone setTitleColor:ColorRGBA(58, 50, 88, 0.2) forState:UIControlStateDisabled];
                self.btnDone.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:_doneFontSize];
                [self.btnDone addTarget:landingView.parentViewController action:@selector(handleBtnDoneTouch:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:self.btnDone];
            }
        }
    }
    else {
        [landingView.parentViewController.topBarContainer setUserInteractionEnabled:NO];
    }
}

- (NSString*)titleForLandingView:(LandingBaseView*)landingView {
    NSString *title = nil;
    if ([landingView isKindOfClass:[LogoView class]]) {
        title = @"";
    }
    else if ([landingView isKindOfClass:[LoginView class]]) {
        title = @"Login";
    }
    else if ([landingView isKindOfClass:[SignupView class]]) {
        title = @"Sign Up";
    }
    else if ([landingView isKindOfClass:[NewPasswordView class]]) {
        title = @"Help";
    }
    else if ([landingView isKindOfClass:[ForgotPwdView class]]) {
        title = @"Help";
    }
    else if ([landingView isKindOfClass:[UsernameView class]]) {
        title = @"Username";
    }
    else if ([landingView isKindOfClass:[VerifyPhoneView class]]) {
        title = @"Verify";
    }
    else if ([landingView isKindOfClass:[VerifyCodeView class]]) {
        title = @"";
    }
    else if ([landingView isKindOfClass:[NoContactsView class]] ||
             [landingView isKindOfClass:[LandingContactView class]] ||
             [landingView isKindOfClass:[NoFriendsView class]] ||
             [landingView isKindOfClass:[LandingFriendView class]]) {
        title = @"Find People";
    }
    return title;
}

- (NSString*)buttonTitleForLandingView:(LandingBaseView*)landingView {
    NSString *title = @"Done";
    if ([landingView isKindOfClass:[UsernameView class]] ||
        [landingView isKindOfClass:[VerifyPhoneView class]]) {
        title = @"Next";
    }
    return title;
}

#pragma mark - 

- (NSArray *)generateEntranceElements {
    NMEntranceElementTop *btnBackEntrance = [NMEntranceElementTop animationWithContainerView:self.btnBack.superview elementView:self.btnBack];
    NMEntranceElementTop *btnDoneEntrance = [NMEntranceElementTop animationWithContainerView:self.btnDone.superview elementView:self.btnDone];
    NMEntranceElementTop *labelEntrance = [NMEntranceElementTop animationWithContainerView:self.labelTitle.superview elementView:self.labelTitle];
    
    btnBackEntrance.fadeIn = YES;
    btnDoneEntrance.fadeIn = YES;
    labelEntrance.fadeIn = YES;
    
    return @[btnBackEntrance, btnDoneEntrance, labelEntrance];
}

- (void)animateIntro {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    [animation addEntranceElements:[self generateEntranceElements]];
    [[NMTransitionManager sharedInstance] beginAnimation:animation];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
