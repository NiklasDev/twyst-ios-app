//
//  SettingUsernameViewController.m
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

#import "SettingUsernameViewController.h"

@interface SettingUsernameViewController () <UITextFieldDelegate, UIAlertViewDelegate> {
    float _fontSizeText;
}

@property (weak, nonatomic) IBOutlet FTextField *txtUsername;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@end

@implementation SettingUsernameViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"SettingUsernameViewController"];
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
    
    [_txtUsername setPlaceholderInfo:@"Username" color:Color(46, 39, 52)];
    
    OCUser *user = [Global getOCUser];
    _txtUsername.text = user.UserName;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeNotifications];
}

#pragma mark - add / remove text field notification
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

- (void)handleTextFieldDidChange:(NSNotification*)notification {
    [self reloadBtnDoneStatus];
}

#pragma mark - internal actions
- (void) actionRegisterUsername:(NSString*) username {
    [self.view endEditing:YES];
    [WrongMessageView hide];
    self.btnDone.hidden = YES;
    [CircleProcessingView showInView:self.view];
    OCUser *user = [Global getOCUser];
    user.UserName = username;
    [[UserWebService sharedInstance] updateProfile:user completion:^(NSInteger statusCode) {
        [self actionCompleteRegisterUsername:statusCode];
    }];
}

- (void) actionCompleteRegisterUsername:(NSInteger)statusCode {
    [CircleProcessingView hide];
    if (statusCode == 0)   {
        NSLog(@"register username success");
        [Global saveOCUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUsernameDidChangeNotification object:nil];
        [WrongMessageView showMessage:WrongMessageTypeProfileChangesSaved inView:[AppDelegate sharedInstance].window];
        [self actionClose];
    }   else if (statusCode == 2)  {
        NSLog(@"this username already exists");
        [Global recoverOCUser];
        self.btnDone.hidden = NO;
        [WrongMessageView showAlert:WrongMessageTypeErrorExistingUsername target:self];
    }   else    {
        NSLog(@"update username fail");
        [Global recoverOCUser];
        self.btnDone.hidden = NO;
        [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
    }
}

- (void)reloadBtnDoneStatus {
    NSInteger result = [ValidationService checkValidUsername:_txtUsername.text];
    if (result == 0) {
        [self.btnDone setEnabled:YES];
    }
    else {
        [self.btnDone setEnabled:NO];
    }
}

- (void)actionClose {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - text field methods
- (IBAction)onDidEndOnExit:(id)sender {
    
}

#pragma mark - handle button methods
- (IBAction)handleBtnCancelTouch:(id)sender {
    [self actionClose];
}

- (IBAction)handleBtnDoneTouch:(id)sender {
    NSString *username = [self.txtUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self actionRegisterUsername:username];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeUsernameLength:
        case WrongMessageTypeUsernameOverLength:
        case WrongMessageTypeUsernameInvalidFormat:
        case WrongMessageTypeErrorExistingUsername:
            [_txtUsername becomeFirstResponder];
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
