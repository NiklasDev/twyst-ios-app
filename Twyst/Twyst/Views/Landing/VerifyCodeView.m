//
//  VerifyCodeView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/29/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"
#import "ContactManageService.h"

#import "LandingTextField.h"
#import "WrongMessageView.h"

#import "VerifyCodeView.h"
#import "NoFriendsView.h"
#import "LandingFriendView.h"
#import "BounceButton.h"

#import "LandingTopBarView.h"
#import "NMTransitionManager+Headers.h"

#define CONTACTS_ACCESS_DENIED_TAG 933139

@interface VerifyCodeView() <UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *codeField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (weak, nonatomic) IBOutlet UIView *keyboardView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet BounceButton *btnResend;

@end

@implementation VerifyCodeView

+ (VerifyCodeView*)verifyCodeViewWithParent:(LandingPageViewController*)parent phoneNumber:(NSString *)phoneNumber {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"VerifyCodeView-3.5inch" : [FlipframeUtils nibNameForDevice:@"VerifyCodeView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    VerifyCodeView *verifyView = [subViews firstObject];
    verifyView.parentViewController = parent;
    [verifyView initView:phoneNumber];
    return verifyView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fontSize = self.codeField.font.pointSize;
    [self.codeField setPlaceholderText:@"Enter your code" color:Color(205, 208, 224) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    [self reloadNextButtonStatus];
}

- (void)initView:(NSString*)phoneNumber{
    self.phoneNumber = phoneNumber;
}

- (NSString *)formattedPhone {
    NSMutableString *phoneCode = [NSMutableString stringWithFormat:@"%@", self.phoneNumber];
    [phoneCode insertString:@"-" atIndex:6];
    [phoneCode insertString:@") " atIndex:3];
    [phoneCode insertString:@"+1 (" atIndex:0];
    return phoneCode;
}

- (void)showKeyboard {
    [super showKeyboard];
    [self.codeField becomeFirstResponder];
}

- (void)handleBtnDoneTouch {
    [super handleBtnDoneTouch];
    [self actionFindFriends];
}

#pragma mark - internal methods
- (void)reloadNextButtonStatus {
    _btnNext.enabled = (_codeField.text.length == DEF_MOBILE_VERIFICATION_CODE_LEN);
}

- (void)actionVerifyPhone {
    NSString *phoneCode = [FlipframeUtils getNumbersFromString:self.phoneNumber];
    [self showProcessingView:YES];
    [[UserWebService sharedInstance] verifyPhone:phoneCode completion:^(BOOL isSuccess) {
        [self showProcessingView:NO];
        if (isSuccess) {
            [WrongMessageView showAlert:WrongMessageTypeVerificationCodeSent target:nil];
        }
        else {
            [WrongMessageView showAlert:WrongMessageTypeInvalidPhoneNumber target:nil];
        }
    }];
}

- (void)actionVerifyCode {
    [self showProcessingView:YES];
    [[UserWebService sharedInstance] sendVerificationCode:_codeField.text completion:^(BOOL isSuccess) {
        [self showProcessingView:NO];
        if (isSuccess) {
            OCUser *user = [Global getOCUser];
            user.Verified = YES;
            user.Phonenumber = [FlipframeUtils getNumbersFromString:self.phoneNumber];
            [Global saveOCUser];
            [self actionFindFriends];
        }
        else {
            [WrongMessageView showAlert:WrongMessageTypeInvalidVerificationCode target:nil];
        }
    }];
}

- (void)actionFindFriends {
    ContactManageService *contactService = [ContactManageService sharedInstance];
    [self showProcessingView:YES];

    if (contactService.isContactLoaded) {
        NSString *phoneCodes = [contactService generatePhoneNumberString];
        [[UserWebService sharedInstance] searchFriendByPhoneCode:phoneCodes completion:^(NSArray *friends) {
            [self showProcessingView:NO];
            if (friends) {
                if (friends.count > 0) {
                    [self actionGotoFriends:friends];
                }
                else {
                    [self actionGotoNoFriends];
                }
            }
            else {
                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self];
            }
        }];
    } else {
        [contactService startNewContactSession:^(BOOL accessGranted, BOOL userBannedAccess) {
            [self showProcessingView:NO];
            
            if (accessGranted) {
                [self actionFindFriends];
            } else if (userBannedAccess) {
                [self actionStartApp];
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access to contacts denied"
                                                                message:@"The Twyst's access to your contacts has been denied. You can change it from your system preferences and try again."
                                                               delegate:self
                                                      cancelButtonTitle:@"Retry"
                                                      otherButtonTitles:@"Skip", nil];
                alert.tag = CONTACTS_ACCESS_DENIED_TAG;
                [alert show];
                 */
            }
        }];
    }
}

- (void)actionGotoNoFriends {
    NoFriendsView *noFriendsView = [NoFriendsView noFriendsViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:noFriendsView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:nil];
}

- (void)actionGotoFriends:(NSArray*)friends {
    LandingFriendView *friendsView = [LandingFriendView friendViewWithParent:self.parentViewController friends:friends];
    [self.parentViewController pushAnimatedView:friendsView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:nil];
}

- (void)actionStartApp {
    [[AppDelegate sharedInstance] startApp];
}

- (void)actionShowErrorMessage:(WrongMessageType)type {
    if (type == WrongMessageTypeNoInternetConnection) {
        [WrongMessageView showMessage:type inView:[AppDelegate sharedInstance].window];
        [_codeField becomeFirstResponder];
    }
    else {
        [WrongMessageView showAlert:type target:self];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        
        case CONTACTS_ACCESS_DENIED_TAG:
            if (buttonIndex == 0) {
                [self actionFindFriends];
            } else {
                [[AppDelegate sharedInstance] startApp];
            }
            break;
        default:
            break;
    }
}

- (void)onTextFieldDidChange {
    [self reloadNextButtonStatus];
}

#pragma mark - button handler
- (IBAction)handleBtnNextTouch:(id)sender {
    [super handleBtnDoneTouch];
    [self actionVerifyCode];
}

- (IBAction)handleBtnNumber:(UIButton*)sender {
    if ([_codeField.text length] >= DEF_MOBILE_VERIFICATION_CODE_LEN) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    _codeField.text = [_codeField.text stringByAppendingString:string];
    [self onTextFieldDidChange];
}

- (IBAction)handleBtnXTouch:(id)sender {
    NSInteger length = _codeField.text.length;
    if (length < 2) {
        _codeField.text = @"";
    }
    else {
        _codeField.text = [_codeField.text substringToIndex:length - 1];
    }
    [self onTextFieldDidChange];
}

- (IBAction)handleBtnResendTouch:(id)sender {
    [self actionVerifyPhone];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - Animations

- (void)customizeTopBar:(LandingTopBarView *)topBar {
    self.topBarView = topBar;
    topBar.labelTitle.text = [self formattedPhone];
}

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    NMEntranceElementRight *hintAnim = [NMEntranceElementRight animationWithContainerView:self elementView:self.hintLabel];
    NMEntranceElementLeft *codeAnim = [NMEntranceElementLeft animationWithContainerView:self elementView:self.codeField];
    
    NMEntranceElementFadeIn *btnResendAnim = [NMEntranceElementFadeIn animationWithContainerView:self elementView:self.btnResend];

    NMEntranceElementBottom *keyboardAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.keyboardView];
    NMEntranceElementBottom *btnNextAnim = [NMEntranceElementBottom animationWithContainerView:self elementView:self.btnNext];
    
    CGFloat delay = 0.0;
    hintAnim.delay = delay;
    delay += 0.1;
    codeAnim.delay = delay;
    btnResendAnim.delay = delay;
    keyboardAnim.delay = delay;
    btnNextAnim.delay = delay;
    
    [animation addEntranceElements:@[hintAnim, codeAnim, btnResendAnim, keyboardAnim, btnNextAnim]];
    
    return animation;
}

@end
