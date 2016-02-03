//
//  ForgotPwdView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "LandingTextField.h"
#import "WrongMessageView.h"
#import "BounceButton.h"

#import "ForgotPwdView.h"
#import "NMTransitionManager+Headers.h"

@interface ForgotPwdView() <UITextFieldDelegate, UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *emailField;
@property (weak, nonatomic) IBOutlet UIImageView *emailFieldSeparator;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel1;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel2;
@property (weak, nonatomic) IBOutlet BounceButton *btnSend;

@end

@implementation ForgotPwdView

+ (ForgotPwdView*)forgotPwdViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"ForgotPwdView-3.5inch" : [FlipframeUtils nibNameForDevice:@"ForgotPwdView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    ForgotPwdView *forgotView = [subViews firstObject];
    forgotView.parentViewController = parent;
    return forgotView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = self.emailField.font.pointSize;
    [self.emailField setPlaceholderText:@"Email" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
}

- (void)showKeyboard {
    [super showKeyboard];
    [self.emailField becomeFirstResponder];
}

- (void)handleBtnDoneTouch {
    [super handleBtnDoneTouch];
    [self actionForgotPassword];
}

#pragma mark - internal methods
- (void)actionForgotPassword {
    NSString *email = self.emailField.text;
    
    [self showProcessingView:YES];
    [[UserWebService sharedInstance] forgotPassword:email completion:^(NSString *result) {
        [self showProcessingView:NO];
        [self actionCompleteForgotPassword:result];
    }];
}

- (BOOL)actionCheckValidation {
    if (![ValidationService checkValidEmail:_emailField.text]) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidEmailFormat];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)actionCompleteForgotPassword:(NSString*)result {
    if ([result isEqualToString:@"ok"]) {
        [WrongMessageView showMessage:WrongMessageTypeNewPasswordRequestSent inView:[AppDelegate sharedInstance].window];
        [self actionGotoLogin];
    }   else if ([result isEqualToString:@"notfound"])      {
        [self actionShowErrorMessage:WrongMessageTypeErrorEmailNotOnFile];
    }   else    {
        [self actionShowErrorMessage:WrongMessageTypeNoInternetConnection];
    }
}

- (void)actionGotoLogin {
    [self.parentViewController popView:YES];
}

- (void)actionShowErrorMessage:(WrongMessageType)type {
    if (type == WrongMessageTypeNoInternetConnection) {
        [WrongMessageView showMessage:type inView:[AppDelegate sharedInstance].window];
        [_emailField becomeFirstResponder];
    }
    else {
        [WrongMessageView showAlert:type target:self];
    }
}

#pragma mark - text field delegate
- (IBAction)onDidEndOnExit:(UITextField*)sender {
    if ([sender isEqual:self.emailField]) {
        [self actionForgotPassword];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeInvalidEmailFormat:
        case WrongMessageTypeErrorEmailNotOnFile:
            [_emailField becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - button handler
- (IBAction)handleBtnSendTouch:(id)sender {
    [super handleBtnDoneTouch];
    [self actionForgotPassword];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - Animations

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    [animation addEntranceElement:[NMEntranceElementLeft animationWithContainerView:self elementView:self.emailField]];
    [animation addEntranceElement:[NMEntranceElementLeft animationWithContainerView:self elementView:self.emailFieldSeparator]];
    [animation addEntranceElement:[NMEntranceElementBottom animationWithContainerView:self elementView:self.btnSend]];
    
    [animation addEntranceElement:[NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel1]];
    [animation addEntranceElement:[NMEntranceElementRight animationWithContainerView:self elementView:self.hintLabel2]];
    
    return animation;
}

@end
