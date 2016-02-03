//
//  UsernameView.m
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

#import "UsernameView.h"
#import "VerifyPhoneView.h"

#import "LandingTopBarView.h"
#import "NMTransitionManager+Headers.h"

@interface UsernameView() <UITextFieldDelegate, UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIImageView *nameFieldSeparator;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *hintlabel2Logo;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel22;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel3;

@end

@implementation UsernameView

+ (UsernameView*)usernameViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"UsernameView-3.5inch" : [FlipframeUtils nibNameForDevice:@"UsernameView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    UsernameView *nameView = [subViews firstObject];
    nameView.parentViewController = parent;
    return nameView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = self.nameField.font.pointSize;
    [self.nameField setPlaceholderText:@"Username" color:Color(58, 50, 88) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    
    [self addNotifications];
    [self reloadNextButtonStatus];
}

- (void)showKeyboard {
    [super showKeyboard];
    [self.nameField becomeFirstResponder];
}

- (void)handleBtnDoneTouch {
    [super handleBtnDoneTouch];
    [self actionRegisterUsername];
}

#pragma mark - internal methods
- (void)reloadNextButtonStatus {
    _btnNext.enabled = (_nameField.text.length >= 4 && _nameField.text.length <= 20);
}

- (void)actionRegisterUsername {
    if ([self actionCheckValidation]) {
        NSString *username = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        OCUser *user = [Global getOCUser];
        user.UserName = username;
        [self showProcessingView:YES];
        [[UserWebService sharedInstance] updateProfile:user completion:^(NSInteger statusCode) {
            [self showProcessingView:NO];
            [self actionCompleteRegisterUsername:statusCode];
        }];
    }
}

- (BOOL)actionCheckValidation {
    NSInteger validation = [ValidationService checkValidUsername:self.nameField.text];
    if (validation < 0) {
        [self actionShowErrorMessage:WrongMessageTypeUsernameLength];
        return NO;
    }
    else if (validation == 1) {
        [self actionShowErrorMessage:WrongMessageTypeUsernameInvalidFormat];
        return NO;
    }
    else if (validation > 1) {
            [self actionShowErrorMessage:WrongMessageTypeUsernameOverLength];
            return NO;
    }
    else {
        return YES;
    }
}

- (void) actionCompleteRegisterUsername:(NSInteger)statusCode {
    if (statusCode == 0)   {
        NSLog(@"register username success");
        [Global saveOCUser];
        [self actionGotoVerify];
    }   else if (statusCode == 2)   {
        NSLog(@"this username already exists");
        [Global recoverOCUser];
        [self actionShowErrorMessage:WrongMessageTypeErrorExistingUsername];
    }   else    {
        NSLog(@"update username fail");
        [Global recoverOCUser];
        [self actionShowErrorMessage:WrongMessageTypeNoInternetConnection];
        [_nameField becomeFirstResponder];
    }
}

- (void)actionGotoVerify {
    VerifyPhoneView *verifyView = [VerifyPhoneView verifyPhoneViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:verifyView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:nil];
}

- (void)actionShowErrorMessage:(WrongMessageType)type {
    if (type == WrongMessageTypeNoInternetConnection) {
        [WrongMessageView showMessage:type inView:[AppDelegate sharedInstance].window];
        [_nameField becomeFirstResponder];
    }
    else {
        [WrongMessageView showAlert:type target:self];
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

#pragma mark - text field delegate
- (IBAction)onDidEndOnExit:(UITextField*)sender {
    if ([sender isEqual:self.nameField]) {
        [self actionRegisterUsername];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeUsernameLength:
        case WrongMessageTypeUsernameOverLength:
        case WrongMessageTypeUsernameInvalidFormat:
        case WrongMessageTypeErrorExistingUsername:
            [_nameField becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - button handler
- (IBAction)handleBtnNextTouch:(id)sender {
    [super handleBtnDoneTouch];
    [self actionRegisterUsername];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
    [self removeNotifications];
}

#pragma mark - Animations

- (void)customizeTopBar:(LandingTopBarView *)topBar {
    self.topBarView = topBar;
}

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    NMEntranceElementLeft *fieldAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.nameField];
    NMEntranceElementLeft *fieldSepAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.nameFieldSeparator];
    NMEntranceElementLeft *btnNextAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.btnNext];
    
    NMEntranceElementLeft *hintLabelAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel];
    NMEntranceElementLeft *hintLabel2Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel2];
    NMEntranceElementLeft *hintLabel2LogoAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintlabel2Logo];
    NMEntranceElementLeft *hintLabel22Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel22];
    NMEntranceElementLeft *hintLabel3Anim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel3];
    
    CGFloat delay = 0.0;
    hintLabelAnim.delay = delay;
    delay += 0.1;
    hintLabel2Anim.delay = delay;
    hintLabel2LogoAnim.delay = delay;
    hintLabel22Anim.delay = delay;
    delay += 0.1;
    hintLabel3Anim.delay = delay;
    
    [animation addEntranceElements:@[fieldAnim, fieldSepAnim, btnNextAnim, hintLabelAnim, hintLabel2Anim, hintLabel2LogoAnim, hintLabel22Anim, hintLabel3Anim]];
    
    return animation;
}

@end
