//
//  SettingBioViewController.m
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

#import "SettingBioViewController.h"

@interface SettingBioViewController () <UITextViewDelegate, UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITextView *txtBio;
@property (weak, nonatomic) IBOutlet UILabel *labelPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@end

@implementation SettingBioViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"SettingBioViewController"];
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
    
    OCUser *user = [Global getOCUser];
    _txtBio.text = user.Bio;
    _labelPlaceholder.hidden = (_txtBio.text.length != 0);
}

#pragma mark - internal actions
- (void) actionRegisterBio:(NSString*)bio {
    [self.view endEditing:YES];
    [WrongMessageView hide];
    self.btnDone.hidden = YES;
    [CircleProcessingView showInView:self.view];
    OCUser *user = [Global getOCUser];
    user.Bio = bio;
    [[UserWebService sharedInstance] updateProfile:user completion:^(NSInteger statusCode) {
        [self actionCompleteRegisterBio:statusCode];
    }];
}

- (void) actionCompleteRegisterBio:(NSInteger)statusCode {
    [CircleProcessingView hide];
    if (statusCode == 0)   {
        NSLog(@"register bio success");
        [Global saveOCUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBioDidChangeNotification object:nil];
        [WrongMessageView showMessage:WrongMessageTypeProfileChangesSaved inView:[AppDelegate sharedInstance].window];
        [self actionClose];
    }   else    {
        NSLog(@"update bio fail");
        [Global recoverOCUser];
        self.btnDone.hidden = NO;
        [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
    }
}

- (void)reloadBtnDoneStatus {
    BOOL result = [ValidationService checkValidBio:_txtBio.text];
    [self.btnDone setEnabled:result];
    self.labelPlaceholder.hidden = (_txtBio.text.length != 0);
}

- (void)actionClose {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - handle button methods
- (IBAction)handleBtnCancelTouch:(id)sender {
    [self actionClose];
}

- (IBAction)handleBtnDoneTouch:(id)sender {
    NSString *bio = [self.txtBio.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self actionRegisterBio:bio];
}

#pragma mark - text view delegate
- (void)textViewDidChange:(UITextView *)textView {
    if (self.txtBio.text.length >= DEF_BIO_COUNT_MAX) {
        NSString * subString = [self.txtBio.text substringToIndex:DEF_BIO_COUNT_MAX];
        self.txtBio.text = subString;
    }
    [self reloadBtnDoneStatus];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case WrongMessageTypeUsernameLength:
        case WrongMessageTypeUsernameOverLength:
        case WrongMessageTypeUsernameInvalidFormat:
        case WrongMessageTypeErrorExistingUsername:
            [_txtBio becomeFirstResponder];
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
