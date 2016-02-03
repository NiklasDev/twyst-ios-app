//
//  NewPasswordView.m
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

#import "NewPasswordView.h"

@interface NewPasswordView() <UITextFieldDelegate, UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *passwordField;

@end

@implementation NewPasswordView

+ (NewPasswordView*)newPwdViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"NewPasswordView-3.5inch" : [FlipframeUtils nibNameForDevice:@"NewPasswordView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    NewPasswordView *newPwdView = [subViews firstObject];
    newPwdView.parentViewController = parent;
    return newPwdView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = self.passwordField.font.pointSize;
    [self.passwordField setPlaceholderText:@"New Password" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
}

- (void)showKeyboard {
    [super showKeyboard];
    [self.passwordField becomeFirstResponder];
}

- (void)handleBtnDoneTouch {
    [super handleBtnDoneTouch];
    [self actionRegisterNewPassword];
}

#pragma mark - internal methods
- (void)actionRegisterNewPassword {
    if ([self actionCheckValidation]) {
        NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [self showProcessingView:YES];
        [[UserWebService sharedInstance] updatePassword:password completion:^(OCUser *user) {
            [self showProcessingView:NO];
            [self actionCompleteRegisterNewPwd:user];
        }];
    }
}

- (BOOL)actionCheckValidation {
    OCUser *user = [Global getOCUser];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([user.Password isEqualToString:password]) {
        [self actionShowErrorMessage:WrongMessageTypeItsTheSameAsTheOldPassword];
        return NO;
    }
    else if (![ValidationService checkValidPassword:password]) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidPasswordFormat];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)actionCompleteRegisterNewPwd:(OCUser*)user {
    if (user) {
        NSLog(@"change pass success: %@", user);
        user.ForgotPass = NO;
        [Global updateOCUser:user];
        [self actionStartApp];
    }   else    {
        NSLog(@"change fail: %@", user);
        [self actionShowErrorMessage:WrongMessageTypeNoInternetConnection];
        [_passwordField becomeFirstResponder];
    }
}

- (void)actionStartApp {
    [[AppDelegate sharedInstance] startApp];
}

- (void)actionShowErrorMessage:(WrongMessageType)type {
    if (type == WrongMessageTypeNoInternetConnection) {
        [WrongMessageView showMessage:type inView:[AppDelegate sharedInstance].window];
        [_passwordField becomeFirstResponder];
    }
    else {
        [WrongMessageView showAlert:type target:self];
    }
}

#pragma mark - text field delegate
- (IBAction)onDidEndOnExit:(UITextField*)sender {
    if ([sender isEqual:self.passwordField]) {
        [self actionRegisterNewPassword];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeInvalidPasswordFormat:
            [_passwordField becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - button handler
- (IBAction)handleBtnDoneTouch:(id)sender {
    [self actionRegisterNewPassword];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
