//
//  InviteCodeView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "LandingTextField.h"
#import "WrongMessageView.h"

#import "SignupView.h"
#import "WhosHereView.h"
#import "InviteCodeView.h"

#import "NMTransitionManager+Headers.h"

@interface InviteCodeView() <UITextFieldDelegate, UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIImageView *imageCode;
@property (weak, nonatomic) IBOutlet LandingTextField *codeField;
@property (weak, nonatomic) IBOutlet UIView *helpTextView;

@end

@implementation InviteCodeView

+ (InviteCodeView*)inviteCodeViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"InviteCodeView-3.5inch" : [FlipframeUtils nibNameForDevice:@"InviteCodeView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    InviteCodeView *inviteCodeView = [subViews firstObject];
    inviteCodeView.parentViewController = parent;
    return inviteCodeView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addNotifications];
    [self reloadVerifyButtonStatus];
    [self.codeField setPlaceholderText:@"OOOOOO" color:[UIColor clearColor] font:[UIFont fontWithName:@"HelveticaNeue" size:self.codeField.font.pointSize]];
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
    [self reloadVerifyButtonStatus];
    self.imageCode.hidden = IsNSStringValid(self.codeField.text);
}

#pragma mark - text field delegate
- (IBAction)onDidEndOnExit:(UITextField*)sender {

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.codeField) {
        if ([string isEqualToString:@" "]) {
            return NO;
        }
        else if ([self.codeField.text length] >= DEF_INVITE_CODE_SIZE && ![string isEqualToString:@""] && ![string isEqualToString:@"\n"]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //self.imageCode.hidden = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.imageCode.hidden = IsNSStringValid(textField.text);
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeInvalidInviteCode:
            [_codeField becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - handle button methods
- (IBAction)handleBtnDoneTouch:(id)sender {
    [self actionVerifyCode];
}

- (IBAction)handleBtnCancelTouch:(id)sender {
    [self.parentViewController popView:YES];
}

- (IBAction)handleBtnPeopleTouch:(id)sender {
    WhosHereView *whosHereView = [WhosHereView whosHereViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:whosHereView
                                   slideEnabled:NO
                                      animation:[NMColorFadeInTransitionAnimation animationWithContainerView:self color:[UIColor whiteColor]]
                                         sender:sender];
}

#pragma mark - Code verification

- (void)actionVerifyCode {
    if ([self actionCheckValidation]) {
        NSString *inviteCode = self.codeField.text;
        
        [self showProcessingView:YES];
        self.btnDone.hidden = YES;
        
        [[UserWebService sharedInstance] inviteCodeVerifyCode:inviteCode completion:^(BOOL isValid) {
            [self showProcessingView:NO];
            self.btnDone.hidden = NO;
            if (isValid) {
                [Global setInviteCode:inviteCode];
                SignupView *signupView = [SignupView signupViewWithParent:self.parentViewController];
                [self.parentViewController pushAnimatedView:signupView
                                               slideEnabled:YES
                                                  animation:nil
                                                     sender:self.btnDone];
            } else {
                [self actionShowErrorMessage:WrongMessageTypeInvalidInviteCode];
            }
        }];
    }
}

- (BOOL)actionCheckValidation {
    BOOL isValid = [ValidationService checkValidInviteCode:self.codeField.text];
    if (!isValid) {
        [self actionShowErrorMessage:WrongMessageTypeInvalidInviteCode];
        return NO;
    } else {
        return YES;
    }
}

- (void)reloadVerifyButtonStatus {
    self.btnDone.enabled = [ValidationService checkValidInviteCode:self.codeField.text];;
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

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
    [self removeNotifications];
}

#pragma mark - 

- (void)landingViewDidAppear {
    [super landingViewDidAppear];
    [self.codeField becomeFirstResponder];
}

- (NMTransitionAnimation *)generateIntroAnimation:(id)sender {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self];
    
    [animation addEntranceElement:[NMEntranceElementLeft animationWithContainerView:self elementView:self.codeField]];
    [animation addEntranceElement:[NMEntranceElementLeft animationWithContainerView:self elementView:self.imageCode]];
    
    NMEntranceElementTranslate *cancel = [NMEntranceElementTop animationWithContainerView:self elementView:self.btnCancel];
    NMEntranceElementTranslate *title = [NMEntranceElementTop animationWithContainerView:self elementView:self.titleLabel];
    NMEntranceElementTranslate *done = [NMEntranceElementTop animationWithContainerView:self elementView:self.btnDone];
    cancel.fadeIn = title.fadeIn = done.fadeIn = YES;
    [animation addEntranceElements:@[cancel, title, done]];
    
    NMEntranceElementBottom *helpText = [NMEntranceElementBottom animationWithContainerView:self elementView:self.helpTextView];
    [animation addEntranceElement:helpText];
    
    return animation;
}

@end
