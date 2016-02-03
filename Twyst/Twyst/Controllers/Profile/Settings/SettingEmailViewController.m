//
//  SettingEmailViewController.m
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

#import "SettingEmailViewController.h"

@interface SettingEmailViewController () <UITextFieldDelegate, UIAlertViewDelegate> {
    float _fontSizeText;
}

@property (weak, nonatomic) IBOutlet FTextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@end

@implementation SettingEmailViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"SettingEmailViewController"];
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
    
    [_txtEmail setPlaceholderInfo:@"Email" color:Color(46, 39, 52)];
    
    OCUser *user = [Global getOCUser];
    _txtEmail.text = user.EmailAddress;
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

#pragma mark -internal actions
- (void) actionRegisterEmail:(NSString*) email {
    [self.view endEditing:YES];
    [WrongMessageView hide];
    self.btnDone.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] updateEmail:email completion:^(NSInteger statusCode) {
        [CircleProcessingView hide];
        [self actionCompleteRegisterEmail:statusCode];
    }];
}

- (void) actionCompleteRegisterEmail:(NSInteger)statusCode {
    if (statusCode == 0)   {
        NSLog(@"register email success");
        [Global saveOCUser];
        [WrongMessageView showMessage:WrongMessageTypeProfileChangesSaved inView:[AppDelegate sharedInstance].window arrayOffsetY:@[@0, @0, @0]];
        [self actionClose];
    }   else if (statusCode == 1) {
        NSLog(@"email already exists");
        [Global recoverOCUser];
        self.btnDone.hidden = NO;
        [WrongMessageView showAlert:WrongMessageTypeErrorExistingEmail target:self];
    }   else    {
        NSLog(@"update email fail");
        [Global recoverOCUser];
        self.btnDone.hidden = NO;
        [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
    }
}

- (void)reloadBtnDoneStatus {
    BOOL isValid = [ValidationService checkValidEmail:_txtEmail.text];
    [self.btnDone setEnabled:isValid];
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
    NSString *email = self.txtEmail.text;
    [self actionRegisterEmail:email];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeInvalidEmailFormat:
        case WrongMessageTypeErrorExistingEmail:
            [_txtEmail becomeFirstResponder];
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
