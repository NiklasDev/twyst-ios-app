//
//  MobileNumber2ViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "AppDelegate.h"
#import "UserWebService.h"
#import "ValidationService.h"

#import "HeaderLabel.h"
#import "BounceButton.h"
#import "WrongMessageView.h"
#import "LandingTextField.h"
#import "CircleProcessingView.h"

#import "SettingViewController.h"
#import "MobileNumber2ViewController.h"

@interface MobileNumber2ViewController () <UITextFieldDelegate> {
    
}

@property (weak, nonatomic) IBOutlet LandingTextField *codeField;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet BounceButton *btnResend;
@property (weak, nonatomic) IBOutlet HeaderLabel *labelTitle;

@end

@implementation MobileNumber2ViewController

- (id)init {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"MobileNumber2ViewController-3.5inch" : [FlipframeUtils nibNameForDevice:@"MobileNumber2ViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

- (void)initView {
    CGFloat fontSize = self.codeField.font.pointSize;
    [self.codeField setPlaceholderText:@"Enter your code" color:Color(205, 208, 224) font:[UIFont fontWithName:@"HelveticaNeue" size:fontSize]];
    
    self.labelTitle.text = [self formattedPhone];
    
    [self reloadNextButtonStatus];
}

- (NSString *)formattedPhone {
    NSMutableString *phoneCode = [NSMutableString stringWithFormat:@"%@", self.phoneNumber];
    [phoneCode insertString:@"-" atIndex:6];
    [phoneCode insertString:@") " atIndex:3];
    [phoneCode insertString:@"+1 (" atIndex:0];
    return phoneCode;
}

#pragma mark - internal methods
- (void)reloadNextButtonStatus {
    _btnNext.enabled = (_codeField.text.length == DEF_MOBILE_VERIFICATION_CODE_LEN);
}

- (void)actionVerifyPhone {
    NSString *phoneCode = [FlipframeUtils getNumbersFromString:self.phoneNumber];
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] verifyPhone:phoneCode completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            [WrongMessageView showAlert:WrongMessageTypeVerificationCodeSent target:nil];
        }
        else {
            [WrongMessageView showAlert:WrongMessageTypeInvalidPhoneNumber target:nil];
        }
    }];
}

- (void)actionVerifyCode {
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] sendVerificationCode:_codeField.text completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            OCUser *user = [Global getOCUser];
            user.Verified = YES;
            user.Phonenumber = [FlipframeUtils getNumbersFromString:self.phoneNumber];
            [Global saveOCUser];
            [self actionGotoNextStep];
        }
        else {
            [WrongMessageView showAlert:WrongMessageTypeInvalidVerificationCode target:nil];
        }
    }];
}

- (void) actionGotoNextStep {
    [WrongMessageView showMessage:WrongMessageTypeProfileChangesSaved inView:[AppDelegate sharedInstance].window];
    NSArray *viewControllers = self.navigationController.viewControllers;
    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[SettingViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
}

#pragma mark - alert view delegate
- (void)onTextFieldDidChange {
    [self reloadNextButtonStatus];
}

#pragma mark - button handler
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleBtnNextTouch:(id)sender {
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
