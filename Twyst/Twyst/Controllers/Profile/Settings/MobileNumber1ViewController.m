//
//  MobileNumber1ViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "UserWebService.h"
#import "ValidationService.h"

#import "LandingTextField.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"

#import "MobileNumber1ViewController.h"
#import "MobileNumber2ViewController.h"

@interface MobileNumber1ViewController () <UIAlertViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@end

@implementation MobileNumber1ViewController

- (id)init {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"MobileNumber1ViewController-3.5inch" : [FlipframeUtils nibNameForDevice:@"MobileNumber1ViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.btnClose.hidden = self.isFirst;
    
    [self initView];
}

- (void)initView {
    CGFloat fontSize = self.phoneField.font.pointSize;
    [self.phoneField setPlaceholderText:@"Enter Phone Number" color:Color(205, 208, 224) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    
    OCUser *user = [Global getOCUser];
    _phoneField.text = user.Phonenumber;
    
    [self reloadNextButtonStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

#pragma mark - internal methods
- (void)reloadNextButtonStatus {
    _btnNext.enabled = (_phoneField.text.length == 10);
}

- (void)actionVerifyPhone {
    NSString *phoneCode = _phoneField.text;
    phoneCode = [FlipframeUtils getNumbersFromString:phoneCode];
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] verifyPhone:phoneCode completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            [self actionGotoVerify:phoneCode];
        }
        else {
            [WrongMessageView showAlert:WrongMessageTypeInvalidPhoneNumber target:nil];
        }
    }];
}

- (void) actionGotoVerify:(NSString*)phoneCode {
    MobileNumber2ViewController * viewController = [[MobileNumber2ViewController alloc] init];
    viewController.phoneNumber = phoneCode;
    [self.navigationController pushViewController:viewController animated:YES];
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

#pragma mark - handle button methods
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - button handler
- (IBAction)handleBtnNextTouch:(id)sender {
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

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
