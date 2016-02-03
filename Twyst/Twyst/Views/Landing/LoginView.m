//
//  LoginView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "LandingTopBarView.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "LandingTextField.h"
#import "WrongMessageView.h"

#import "LoginView.h"
#import "UsernameView.h"
#import "ForgotPwdView.h"
#import "NewPasswordView.h"
#import "VerifyPhoneView.h"

#import "NMTransitionManager+Headers.h"


@interface LoginView() <UITextFieldDelegate, UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *userTextField;
@property (weak, nonatomic) IBOutlet LandingTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnForgot;

@end

@implementation LoginView

+ (LoginView*)loginViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"LoginView-3.5inch" : [FlipframeUtils nibNameForDevice:@"LoginView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    LoginView *loginView = [subViews firstObject];
    loginView.parentViewController = parent;
    return loginView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = self.userTextField.font.pointSize;
    [self.userTextField setPlaceholderText:@"Email or username" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    [self.passwordField setPlaceholderText:@"Password" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    
    [self addNotifications];
    [self reloadDoneButtonStatus];
}

- (void)showKeyboard {
    [super showKeyboard];
    [self.userTextField becomeFirstResponder];
}

- (void)handleBtnDoneTouch {
    [super handleBtnDoneTouch];
    [self actionLogin];
}

#pragma mark - internal methods
- (void)reloadDoneButtonStatus {
    _btnDone.enabled = IsNSStringValid(_userTextField.text) && IsNSStringValid(_passwordField.text);
}

- (void) actionLogin {
    if ([self actionCheckValidation]) {
        NSString *userText = self.userTextField.text;
        NSString *password = self.passwordField.text;
        [self showProcessingView:YES];
        [[UserWebService sharedInstance] loginUser:userText withPass:password completion:^(OCUser *user) {
            [self showProcessingView:NO];
            [self actionCompleteLoginUser:user];
        }];
    }
}

- (BOOL)actionCheckValidation {
    if (![ValidationService checkValidEmail:self.userTextField.text] && [ValidationService checkValidUsername:self.userTextField.text] != 0) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidEmailFormat];
        return NO;
    }
    else if (![ValidationService checkValidPassword:self.passwordField.text]) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidPasswordFormat];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)actionCompleteLoginUser:(OCUser*)user {
    if (user) {
        NSLog(@"sign in success: %@", user);
        BOOL isChangePass = user.ForgotPass;
        BOOL isVerified = user.Verified;
        
        if (!IsNSStringValid(user.UserName))  {
            [self actionGotoUsername];
        }
        else if (!isVerified) {
            [self actionGotoVerifyPhone];
        }
        else if (isChangePass) {
            [self actionGotoNewPassword];
        }
        else {
            [self actionStartApp];
        }
    }
    else {
        [self actionShowErrorMessage:WrongMessageTypeInvalidCrediential];
    }
}

- (void)actionGotoNewPassword {
    NewPasswordView *newPwdView = [NewPasswordView newPwdViewWithParent:self.parentViewController];
    [self.parentViewController pushView:newPwdView animated:YES];
}

- (void)actionGotoUsername {
    UsernameView *usernameView = [UsernameView usernameViewWithParent:self.parentViewController];
    [self.parentViewController pushView:usernameView animated:YES];
}

- (void)actionGotoVerifyPhone {
    VerifyPhoneView *verifyView = [VerifyPhoneView verifyPhoneViewWithParent:self.parentViewController];
    [self.parentViewController pushView:verifyView animated:YES];
}

- (void)actionStartApp {
    NMSimpleTransition *transition = [[NMSimpleTransition alloc] init];
    transition.fromAnimation = [NMColorFadeInTransitionAnimation animationWithContainerView:self.parentViewController.view color:[UIColor whiteColor]];
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [[AppDelegate sharedInstance] startApp];
        completion();
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

- (void)actionShowErrorMessage:(WrongMessageType)type {
    [WrongMessageView showAlert:type target:self];
}

#pragma mark - text field delegate
- (IBAction)onDidEndOnExit:(UITextField*)sender {
    if ([sender isEqual:self.userTextField]) {
        [self.passwordField becomeFirstResponder];
    }
    else if ([sender isEqual:self.passwordField]) {
        [self actionLogin];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeInvalidCrediential:
        case WrongMessageTypeInvalidEmailFormat:
            [_userTextField becomeFirstResponder];
            break;
        case WrongMessageTypeInvalidPasswordFormat:
            [_passwordField becomeFirstResponder];
            break;
        default:
        break;
    }
}

#pragma mark - add / remove text field notification
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTextFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

- (void)onTextFieldDidChange:(NSNotification *)notification {
    [self reloadDoneButtonStatus];
}

#pragma mark - button handler
- (IBAction)handleBtnForgotPwd:(id)sender {
    ForgotPwdView *forgotPwdView = [ForgotPwdView forgotPwdViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:forgotPwdView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:sender];
}

- (IBAction)handleBtnDoneTouch:(id)sender {
    [super handleBtnDoneTouch];
    [self actionLogin];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
    [self removeNotifications];
}

#pragma mark - 

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];

    [animation addEntranceElement:[NMEntranceElementLeft animationWithContainerView:self elementView:self.userTextField]];
    [animation addEntranceElement:[NMEntranceElementRight animationWithContainerView:self elementView:self.passwordField]];
    [animation addEntranceElement:[NMEntranceElementBottom animationWithContainerView:self elementView:self.btnDone]];
    
    NMEntranceElementFadeIn *forgotAnim = [NMEntranceElementFadeIn animationWithContainerView:self elementView:self.btnForgot];
    [animation addEntranceElement:forgotAnim];

    return animation;
}

- (void)landingViewDidAppear {
    [super landingViewDidAppear];
}

@end
