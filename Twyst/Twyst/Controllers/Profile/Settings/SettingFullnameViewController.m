//
//  SettingFullnameViewController.m
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

#import "SettingFullnameViewController.h"

@interface SettingFullnameViewController () <UITextFieldDelegate> {
    float _fontSizeText;
}

@property (weak, nonatomic) IBOutlet FTextField *txtFirstName;
@property (weak, nonatomic) IBOutlet FTextField *txtLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@end

@implementation SettingFullnameViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"SettingFullnameViewController"];
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
    
    [_txtFirstName setPlaceholderInfo:@"First Name" color:Color(46, 39, 52)];
    [_txtLastName setPlaceholderInfo:@"Last Name" color:Color(46, 39, 52)];
    
    OCUser *user = [Global getOCUser];
    _txtFirstName.text = user.FirstName;
    _txtLastName.text = user.LastName;
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
- (void) actionRegisterFullname:(NSString*)firstName lastName:(NSString*)lastName {
    [self.view endEditing:YES];
    [WrongMessageView hide];
    self.btnDone.hidden = YES;
    [CircleProcessingView showInView:self.view];
    OCUser *user = [Global getOCUser];
    user.FirstName = firstName;
    user.LastName = lastName;
    [[UserWebService sharedInstance] updateProfile:user completion:^(NSInteger statusCode) {
        [self actionCompleteRegisterUsername:statusCode];
    }];
}

- (void) actionCompleteRegisterUsername:(NSInteger)statusCode {
    [CircleProcessingView hide];
    if (statusCode == 0)   {
        NSLog(@"register full name success");
        [Global saveOCUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUsernameDidChangeNotification object:nil];
        [WrongMessageView showMessage:WrongMessageTypeProfileChangesSaved inView:[AppDelegate sharedInstance].window];
        [self actionClose];
    }   else    {
        NSLog(@"update full name fail");
        [Global recoverOCUser];
        self.btnDone.hidden = NO;
        [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
    }
}

- (void)reloadBtnDoneStatus {
    if ([ValidationService checkValidName:_txtFirstName.text]
        && [ValidationService checkValidName:_txtLastName.text]) {
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
    NSString *firstName = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *lastName = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self actionRegisterFullname:firstName lastName:lastName];
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
