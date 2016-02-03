//
//  SignupView.m
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

#import "SignupView.h"
#import "UsernameView.h"

#import "LandingTopBarView.h"
#import "NMTransitionManager+Headers.h"

@interface SignupView() <UITextFieldDelegate, UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIView *textContainer;
@property (weak, nonatomic) IBOutlet LandingTextField *firstnameField;
@property (weak, nonatomic) IBOutlet LandingTextField *lastnameField;
@property (weak, nonatomic) IBOutlet LandingTextField *emailField;
@property (weak, nonatomic) IBOutlet LandingTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@end

@implementation SignupView

+ (SignupView*)signupViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"SignupView-3.5inch" : [FlipframeUtils nibNameForDevice:@"SignupView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    SignupView *signupView = [subViews firstObject];
    signupView.parentViewController = parent;
    return signupView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = self.firstnameField.font.pointSize;
    [self.firstnameField setPlaceholderText:@"First name" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    [self.lastnameField setPlaceholderText:@"Last name" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    [self.emailField setPlaceholderText:@"Email" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    [self.passwordField setPlaceholderText:@"Password" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    
    [self addNotifications];
    [self reloadNextButtonStatus];
}

- (void)showKeyboard {
    [super showKeyboard];
    [self.firstnameField becomeFirstResponder];
}

- (void)handleBtnDoneTouch {
    [super handleBtnDoneTouch];
    [self actionRegister];
}

#pragma mark - internal methods
- (void)reloadNextButtonStatus {
    _btnNext.enabled = IsNSStringValid(_firstnameField.text) && IsNSStringValid(_lastnameField.text) && IsNSStringValid(_emailField.text) && IsNSStringValid(_passwordField.text);
}

- (void) actionRegister {
    if ([self actionCheckValidation]) {
        NSString *email = self.emailField.text;
        NSString *password = self.passwordField.text;
        NSString *firstName = [self.firstnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *lastName = [self.lastnameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self showProcessingView:YES];
        [[UserWebService sharedInstance] registerNewUser:email withPass:password firstName:firstName lastName:lastName completion:^(OCUser *user, BOOL isExisting) {
            [self showProcessingView:NO];
            [self actionCompleteRegisterUser:user withExisting:isExisting];
        }];
    }
}

- (BOOL)actionCheckValidation {
    if (![ValidationService checkValidName:_firstnameField.text]) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidFirstName];
        return NO;
    }
    else if (![ValidationService checkValidName:_lastnameField.text]) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidLastName];
        return NO;
    }
    else if (![ValidationService checkValidEmail:_emailField.text]) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidEmailFormat];
        return NO;
    }
    else if (![ValidationService checkValidPassword:_passwordField.text]) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidPasswordFormat];
        return NO;
    }
    else {
        return YES;
    }
}

- (void) actionCompleteRegisterUser:(OCUser*)user withExisting:(BOOL) isExisting {
    if (user)   {
        NSLog(@"register success");
        [self actionGotoUsername];
    }   else    {
        NSLog(@"register fail");
        if (isExisting) {
            [self actionShowErrorMessage:WrongMessageTypeErrorExistingEmail];
        }
        else {
            [self actionShowErrorMessage:WrongMessageTypeNoInternetConnection];
        }
    }
}

- (void)actionGotoUsername {
    UsernameView *usernameView = [UsernameView usernameViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:usernameView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:nil];
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
    if ([sender isEqual:self.firstnameField]) {
        [self.firstnameField becomeFirstResponder];
    }
    else if ([sender isEqual:self.lastnameField]) {
        [self.lastnameField becomeFirstResponder];
    }
    else if ([sender isEqual:self.emailField]) {
        [self.passwordField becomeFirstResponder];
    }
    else if ([sender isEqual:self.passwordField]) {
        [self actionRegister];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeErrorExistingEmail:
        case WrongMessageTypeInvalidEmailFormat:
            [_emailField becomeFirstResponder];
            break;
        case WrongMessageTypeInvalidPasswordFormat:
            [_passwordField becomeFirstResponder];
            break;
        case WrongMessageTypeInvalidFirstName:
            [_firstnameField becomeFirstResponder];
            break;
        case WrongMessageTypeInvalidLastName:
            [_lastnameField becomeFirstResponder];
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
    [self reloadNextButtonStatus];
}

#pragma mark - button handler
- (IBAction)handleBtnNextTouch:(id)sender {
    [super handleBtnDoneTouch];
    [self actionRegister];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
    [self removeNotifications];
}

#pragma mark -

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    NMEntranceElementTranslate *firstNameAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.firstnameField];
    NMEntranceElementTranslate *lastNameAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.lastnameField];
    NMEntranceElementTranslate *emailAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.emailField];
    NMEntranceElementTranslate *passAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.passwordField];
    NMEntranceElementTranslate *btnNextAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.btnNext];
    
    CGFloat delay = 0.0;
    firstNameAnim.delay = delay;
    delay += 0.1;
    lastNameAnim.delay = delay;
    delay += 0.1;
    emailAnim.delay = delay;
    delay += 0.1;
    passAnim.delay = delay;
    
    [animation addEntranceElements:@[firstNameAnim, lastNameAnim, emailAnim, passAnim, btnNextAnim]];
    
    return animation;
}

- (void)landingViewDidAppear {
    [super landingViewDidAppear];
}

@end
