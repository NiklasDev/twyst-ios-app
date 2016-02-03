//
//  VerifyPhoneView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/29/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "LandingTextField.h"
#import "WrongMessageView.h"

#import "VerifyPhoneView.h"
#import "VerifyCodeView.h"

#import "LandingTopBarView.h"
#import "NMTransitionManager+Headers.h"

@interface VerifyPhoneView() <UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;
@property (weak, nonatomic) IBOutlet UIImageView *keyboardSeparator;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIImageView *startPhoneNumber;
@property (weak, nonatomic) IBOutlet LandingTextField *phoneNumberField;

@end

@implementation VerifyPhoneView

+ (VerifyPhoneView*)verifyPhoneViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"VerifyPhoneView-3.5inch" : [FlipframeUtils nibNameForDevice:@"VerifyPhoneView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    VerifyPhoneView *verifyView = [subViews firstObject];
    verifyView.parentViewController = parent;
    return verifyView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = self.phoneField.font.pointSize;
    [self.phoneField setPlaceholderText:@"Enter Phone Number" color:Color(205, 208, 224) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    
    [self reloadNextButtonStatus];
}

- (void)showKeyboard {
    [super showKeyboard];
    [self.phoneField becomeFirstResponder];
}

- (void)handleBtnDoneTouch {
    [super handleBtnDoneTouch];
    [self handleBtnNextTouch:nil];
}

#pragma mark - internal methods
- (void)reloadNextButtonStatus {
    _btnNext.enabled = (_phoneField.text.length == 10);
}

- (void)actionVerifyPhone {
    NSString *phoneCode = _phoneField.text;
    phoneCode = [FlipframeUtils getNumbersFromString:phoneCode];
    [self showProcessingView:YES];
    [[UserWebService sharedInstance] verifyPhone:phoneCode completion:^(BOOL isSuccess) {
        [self showProcessingView:NO];
        if (isSuccess) {
            [self actionGotoVerify:phoneCode];
        }
        else {
            [WrongMessageView showAlert:WrongMessageTypeInvalidPhoneNumber target:nil];
        }
    }];
}

- (void)actionGotoVerify:(NSString*)phoneCode {
    VerifyCodeView *verifyView = [VerifyCodeView verifyCodeViewWithParent:self.parentViewController phoneNumber:phoneCode];
    [self.parentViewController pushAnimatedView:verifyView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:nil];
}

- (void)actionShowErrorMessage:(WrongMessageType)type {
    if (type == WrongMessageTypeNoInternetConnection) {
        [WrongMessageView showMessage:type inView:[AppDelegate sharedInstance].window];
        [_phoneField becomeFirstResponder];
    }
    else {
        [WrongMessageView showAlert:type target:self];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [self actionVerifyPhone];
        }
    }
}

- (void)onTextFieldDidChange {
    if ([_phoneField.text isEqualToString:@"1"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"10 digit number"
                                                        message:@"Please do not enter a 1 before your mobile number. Only enter your ten digit number, which consists of your area code followed by your mobile number. Example 555-555-5555."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
        _phoneField.text = @"";
    }
    [self reloadNextButtonStatus];
}

#pragma mark - button handler
- (IBAction)handleBtnNextTouch:(id)sender {
    [super handleBtnDoneTouch];
    
    NSMutableString *messageBody = [NSMutableString stringWithString:_phoneField.text];
    [messageBody insertString:@"-" atIndex:6];
    [messageBody insertString:@"-" atIndex:3];
    NSString *title = [NSString stringWithFormat:@"Is this your\nmobile phone number?\n\n%@\n", messageBody];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alertView.tag = 100;
    [alertView show];
}

- (IBAction)handleBtnNumber:(UIButton*)sender {
    if ([_phoneField.text length] >= 10) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    _phoneField.text = [_phoneField.text stringByAppendingString:string];
    [self onTextFieldDidChange];
}

- (IBAction)handleBtnXTouch:(id)sender {
    NSInteger length = _phoneField.text.length;
    if (length < 2) {
        _phoneField.text = @"";
    }
    else {
        _phoneField.text = [_phoneField.text substringToIndex:length - 1];
    }
    [self onTextFieldDidChange];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - Animations

- (void)customizeTopBar:(LandingTopBarView *)topBar {
    self.topBarView = topBar;
}

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    NMEntranceElementLeft *hintLabelAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.hintLabel];
    NMEntranceElementLeft *startPhoneAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.startPhoneNumber];
    NMEntranceElementLeft *phoneFieldAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.phoneField];
    
    NMEntranceElementBottom *keyboardAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.keyboardView];
    NMEntranceElementBottom *separatorAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.keyboardSeparator];
    NMEntranceElementBottom *btnNextAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.btnNext];
    
    separatorAnim.fadeIn = YES;
    startPhoneAnim.fadeIn = YES;
    
    CGFloat delay = 0.0;
    hintLabelAnim.delay = delay;
    delay += 0.1;
    phoneFieldAnim.delay = delay;
    delay += 0.1;
    keyboardAnim.delay = delay;
    separatorAnim.delay = delay;
    btnNextAnim.delay = delay;
    delay += 0.1;
    startPhoneAnim.delay = delay;
    
    [animation addEntranceElements:@[hintLabelAnim, startPhoneAnim, phoneFieldAnim, keyboardAnim, separatorAnim, btnNextAnim]];
    
    return animation;
}

@end
