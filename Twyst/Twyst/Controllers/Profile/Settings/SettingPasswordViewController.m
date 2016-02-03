//
//  SettingPasswordViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/09/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UserWebService.h"
#import "ValidationService.h"

#import "AppDelegate.h"

#import "FTextField.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"

#import "SettingPasswordViewController.h"

@interface SettingPasswordViewController () <UITextFieldDelegate, UIAlertViewDelegate> {
    float _fontSizeText;
}

@property (weak, nonatomic) IBOutlet FTextField *txtOldPwd;
@property (weak, nonatomic) IBOutlet FTextField *txtNewPwd;
@property (weak, nonatomic) IBOutlet FTextField *txtCfmPwd;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@end

@implementation SettingPasswordViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"SettingPasswordViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_txtOldPwd setPlaceholderInfo:@"Old password" color:Color(46, 39, 52)];
    [_txtNewPwd setPlaceholderInfo:@"New password" color:Color(46, 39, 52)];
    [_txtCfmPwd setPlaceholderInfo:@"Confirm password" color:Color(46, 39, 52)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    if ([Global deviceType] == DeviceTypePhone4) {
        [self addKeyboardObserver];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
    
    if ([Global deviceType] == DeviceTypePhone4) {
        [self removeKeyboardObserver];
    }
}

#pragma mark - show / hide keyboard
- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    CGPoint contentOffset = CGPointMake(0, 35);
    [self.scrollView setContentOffset:contentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)handleTextFieldDidChange:(NSNotification*)notification {
    [self reloadBtnDoneStatus];
}

#pragma mark - internal actions
- (BOOL)actionCheckValidation {
    NSString *oldPwd = _txtOldPwd.text;
    NSString *newPwd = _txtNewPwd.text;
    NSString *cfmPwd = _txtCfmPwd.text;
    
    OCUser *curUser = [Global getOCUser];
    
    if (![oldPwd isEqualToString:curUser.Password]) {
        return NO;
    }
    else if (![newPwd isEqualToString:cfmPwd]) {
        return NO;
    }
    else if (![ValidationService checkValidPassword:newPwd]) {
        return NO;
    } 
    return YES;
}

- (void) actionChangePassword:(NSString *)newPwd {
    
    if ([_txtOldPwd.text isEqualToString:_txtNewPwd.text]) {
        [WrongMessageView showAlert:WrongMessageTypeItsTheSameAsTheOldPassword target:self];
    } else {
        [self.view endEditing:YES];
        [WrongMessageView hide];
        self.btnDone.hidden = YES;
        [CircleProcessingView showInView:self.view];
        [[UserWebService sharedInstance] updatePassword:newPwd completion:^(OCUser *user) {
            [CircleProcessingView hide];
            if (user) {
                NSLog(@"change password success");
                [WrongMessageView showMessage:WrongMessageTypeProfileChangesSaved inView:[AppDelegate sharedInstance].window arrayOffsetY:@[@0, @0, @0]];
                [self actionClose];
            }
            else    {
                NSLog(@"change password fail");
                self.btnDone.hidden = NO;
                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
            }
        }];
    }
}

- (void)actionClose {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadBtnDoneStatus {
    BOOL isValid = [self actionCheckValidation];
    [self.btnDone setEnabled:isValid];
}

#pragma mark - text field methods
- (IBAction)onDidEndOnExit:(UITextField *)sender {
    if ([sender isEqual:_txtOldPwd]) {
        [_txtNewPwd becomeFirstResponder];
    }
    else if ([sender isEqual:_txtNewPwd]) {
        [_txtCfmPwd becomeFirstResponder];
    }
    else if ([sender isEqual:_txtCfmPwd]) {
        [_txtCfmPwd resignFirstResponder];
        
    }
}

#pragma mark - handle button methods
- (IBAction)handleBtnCancelTouch:(id)sender {
    [self actionClose];
}

- (IBAction)handleBtnDoneTouch:(id)sender {
    NSString *newPwd = self.txtNewPwd.text;
    [self actionChangePassword:newPwd];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeIncorrectOldPassword:
            [_txtOldPwd becomeFirstResponder];
            break;
        case WrongMessageTypeDoesNotMatchPassword:
        case WrongMessageTypeInvalidPasswordFormat:
            [_txtNewPwd becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
