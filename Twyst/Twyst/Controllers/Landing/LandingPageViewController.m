//
//  LandingPageViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "LogoView.h"
#import "LoginView.h"
#import "SignupView.h"
#import "UsernameView.h"
#import "ForgotPwdView.h"
#import "NewPasswordView.h"
#import "VerifyPhoneView.h"
#import "LandingTopBarView.h"
#import "CircleProcessingView.h"

#import "LandingPageViewController.h"

#import "NMSimpleTransition.h"
#import "NMTransitionManager.h"
#import "NMEmptyTransitionAnimation.h"

@interface LandingPageViewController () <UIScrollViewDelegate> {
    NSMutableArray *_landingViews;
    LandingBaseView *_topView;
    LandingTopBarView *_topBar;
    
    BOOL _isNewPassword;
    BOOL _isUsername;
    BOOL _isVerifyPhone;
}

@property (nonatomic, weak) IBOutlet UIView *landingViewContainer;

@end

@implementation LandingPageViewController

- (id)init
{
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"LandingPageViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _landingViews = [NSMutableArray new];
        _isNewPassword = NO;
        _isUsername = NO;
        _isVerifyPhone = NO;
    }
    
    return self;
}

- (id)initWithNewPassword {
    self = [self init];
    if (self) {
        // Custom initialization
        _isNewPassword = YES;
    }
    
    return self;
}

- (id)initWithUsername {
    self = [self init];
    if (self) {
        // Custom initialization
        _isUsername = YES;
    }
    
    return self;
}

- (id)initWithVerifyPhone {
    self = [self init];
    if (self) {
        // Custom initialization
        _isVerifyPhone = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LogoView *logoView = [LogoView logoViewWithParent:self];
    [self initWithRootView:logoView];
    
    if (_isUsername) {
        UsernameView *usernameView = [UsernameView usernameViewWithParent:self];
        [self pushView:usernameView animated:NO];
    }
    else if (_isNewPassword) {
        NewPasswordView *newPwdView = [NewPasswordView newPwdViewWithParent:self];
        [self pushView:newPwdView animated:NO];
    }
    else if (_isVerifyPhone) {
        VerifyPhoneView *verifyView = [VerifyPhoneView verifyPhoneViewWithParent:self];
        [self pushView:verifyView animated:NO];
    }
}

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_topView landingViewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_topView landingViewWillDisappear];
}

#pragma mark - view management
- (void)initWithRootView:(LandingBaseView*)rootView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    [rootView setFrame:frame];
    
    _topBar = [LandingTopBarView topBarWithLandingView:rootView];
    [_landingViews addObject:rootView];
    _topView = rootView;
    [rootView showInView:self.landingViewContainer];
    [self.topBarContainer addSubview:_topBar];
}

- (void)pushAnimatedView:(LandingBaseView*)newView slideEnabled:(BOOL)slideEnabled animation:(NMTransitionAnimation *)outroAnimation sender:(id)sender {
    NMSimpleTransition *transition = [[NMSimpleTransition alloc] init];
    transition.fromAnimation = outroAnimation ? outroAnimation : [NMEmptyTransitionAnimation animationWithContainerView:_topView];
    transition.toAnimation = [newView generateIntroAnimation:sender];
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [self pushView:newView animated:slideEnabled completion:completion];
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

- (void)pushView:(LandingBaseView*)newView animated:(BOOL)animated {
    [self pushView:newView animated:animated completion:^{}];
}

- (void)pushView:(LandingBaseView*)newView animated:(BOOL)animated completion:(void(^)())completionBlock {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect pushFrame = CGRectMake(bounds.size.width, 0, bounds.size.width, bounds.size.height);
    CGRect topFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    CGRect popFrame = CGRectMake(- bounds.size.width, 0, bounds.size.width, bounds.size.height);
    
    [newView setFrame:pushFrame];
    newView.alpha = 0.0f;
    [self.landingViewContainer addSubview:newView];
    
    LandingTopBarView *newTopBar = [LandingTopBarView topBarWithLandingView:newView];
    newTopBar.alpha = 0.0f;
    [self.topBarContainer addSubview:newTopBar];
    [newView customizeTopBar:newTopBar];
    
    [_topView hideKeyboard];
    [_topView landingViewWillDisappear];
    
    if (animated) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [_topView setFrame:popFrame];
                             [newView setFrame:topFrame];
                             _topView.alpha = 0.0f;
                             newView.alpha = 1.0f;
                             _topBar.alpha = 0.0f;
                             newTopBar.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [_landingViews addObject:newView];
                             _topView = newView;
                             [_topBar removeFromSuperview];
                             _topBar = newTopBar;
                             [_topView showKeyboard];
                             [_topView landingViewDidAppear];
                             completionBlock();
                         }];
    }
    else {
        [_topView setFrame:popFrame];
        [newView setFrame:topFrame];
        _topView.alpha = 0.0f;
        newView.alpha = 1.0f;
        
        UIView *tmpTopBar = _topBar;
        UIView *tmpNewTopBar = newTopBar;
        [UIView animateWithDuration:0.3f animations:^{
            tmpTopBar.alpha = 0.0f;
            tmpNewTopBar.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [tmpTopBar removeFromSuperview];
        }];
        
        [_landingViews addObject:newView];
        _topView = newView;
        _topBar = newTopBar;
        [_topView showKeyboard];
        [_topView landingViewDidAppear];
        completionBlock();
    }
}

- (void)popView:(BOOL)animated {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect topFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    CGRect popFrame = CGRectMake(bounds.size.width, 0, bounds.size.width, bounds.size.height);
    
    [_landingViews removeObject:_topView];
    LandingBaseView *preView = [_landingViews lastObject];
    
    LandingTopBarView *newTopBar = [LandingTopBarView topBarWithLandingView:preView];
    newTopBar.alpha = 0.0f;
    [self.topBarContainer addSubview:newTopBar];
    [preView customizeTopBar:newTopBar];
    
    [_topView hideKeyboard];
    [_topView landingViewWillDisappear];
    
    if (animated) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [_topView setFrame:popFrame];
                             [preView setFrame:topFrame];
                             _topView.alpha = 0.0f;
                             preView.alpha = 1.0f;
                             _topBar.alpha = 0.0f;
                             newTopBar.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [_topView removeFromSuperview];
                             _topView = preView;
                             [_topBar removeFromSuperview];
                             _topBar = newTopBar;
                             [_topView showKeyboard];
                             [_topView landingViewDidAppear];
                         }];
    }
    else {
        [_topView setFrame:popFrame];
        [preView setFrame:topFrame];
        _topView.alpha = 0.0f;
        preView.alpha = 1.0f;
        _topBar.alpha = 0.0f;
        newTopBar.alpha = 1.0f;
        
        [_topView removeFromSuperview];
        _topView = preView;
        [_topBar removeFromSuperview];
        _topBar = newTopBar;
        [_topView showKeyboard];
        [_topView landingViewDidAppear];
    }
}

#pragma mark - handle button methods
- (void)handleBtnBackTouch:(id)sender {
    [self popView:YES];
}

- (void)handleBtnDoneTouch:(id)sender {
    [_topView handleBtnDoneTouch];
}

#pragma mark - show processing view
- (void)showProcessingView:(BOOL)show {
    if (show) {
        [CircleProcessingView showInView:[AppDelegate sharedInstance].window];
        _topBar.btnDone.hidden = YES;
    }
    else {
        [CircleProcessingView hide];
        _topBar.btnDone.hidden = NO;
    }
}

#pragma mark - status bar hidden
- (BOOL) prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (_topView) {
        return ([_topView isKindOfClass:[LogoView class]]) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
    else {
        return UIStatusBarStyleLightContent;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
