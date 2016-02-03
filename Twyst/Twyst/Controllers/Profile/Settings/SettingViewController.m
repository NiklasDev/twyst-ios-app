//
//  SettingViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/09/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "UIImage+Device.h"

#import "AppDelegate.h"
#import "UserWebService.h"
#import "UserLocalServices.h"

#import "SettingSwitch.h"
#import "UserWebService.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"

#import "SettingViewController.h"
#import "SettingUsernameViewController.h"
#import "SettingEmailViewController.h"
#import "SettingPasswordViewController.h"
#import "SettingBioViewController.h"
#import "SettingPushViewController.h"
#import "SettingFullnameViewController.h"
#import "MobileNumber1ViewController.h"

@interface SettingViewController () <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
    float _fontSizeText;
    
    NSString *_cellIdentifier;
    NSArray * settings;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"SettingViewController"];
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
    
    _cellIdentifier = @"settingCellIdentifier";
    settings = @[
                 @[@"Username", @"Full Name", @"Mobile Number", @"Email", @"Password", @"Bio"],
                 @[@"Private Account"],
                 @[@"Push Notifications", @"Save Photos"],
                 @[@"info@twystapp.co", @"Privacy Policy"],
                 ];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -internal actions
- (void)actionClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - handle button methods
- (IBAction)handleBtnCancelTouch:(id)sender {
    [self actionClose];
}

#pragma mark - setting related methods
- (void)loadSettings:(SettingSwitch *)ctrlSwitch {
    if (ctrlSwitch.section == 1) {
        ctrlSwitch.on = [Global getOCUser].PrivateProfile;
    }
    else if (ctrlSwitch.section == 2) {
        ctrlSwitch.on = [Global getConfig].isSaveVideo;
    }
}

- (void)actionUpdatePrivateProfile {
    OCUser *user = [Global getOCUser];
    user.PrivateProfile = !user.PrivateProfile;
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] updateProfile:user completion:^(NSInteger statusCode) {
        [CircleProcessingView hide];
        if (statusCode == 0)   {
            NSLog(@"update private profile success");
            [Global saveOCUser];
        }   else    {
            NSLog(@"update private profile fail");
            [Global recoverOCUser];
            [self.tableView reloadData];
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
        }
    }];
}

#pragma mark - table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [settings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[settings objectAtIndex:section] count];
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            return 30;
            break;
        case DeviceTypePhone6Plus:
            return 35;
            break;
        default:
            return 28;
            break;
    }
}

#pragma mark -
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            return 44;
            break;
        case DeviceTypePhone6Plus:
            return 48;
            break;
        default:
            return 37;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * cellText = [[settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (cell == nil) {
        DeviceType type = [Global deviceType];
        switch (type) {
            case DeviceTypePhone6:
                cell = [self tableView:tableView iPhone6CellForRowAtIndexPath:indexPath];
                break;
            case DeviceTypePhone6Plus:
                cell = [self tableView:tableView iPhone6PlusCellForRowAtIndexPath:indexPath];
                break;
            default:
                cell = [self tableView:tableView defaultCellForRowAtIndexPath:indexPath];
                break;
        }
    }
    
    cell.textLabel.text = cellText;
    
    OCUser *user = [Global getOCUser];
    UILabel *labelDetail = (UILabel*)[cell viewWithTag:400];
    labelDetail.hidden = NO;
    if ([cellText isEqualToString:@"Username"]) {
        labelDetail.text = user.UserName;
    }
    else if ([cellText isEqualToString:@"Full Name"]) {
        labelDetail.text = [NSString stringWithFormat:@"%@ %@", user.FirstName, user.LastName];
    }
    else if ([cellText isEqualToString:@"Mobile Number"]) {
        labelDetail.text = [FlipframeUtils getStyledPhoneNumber:user.Phonenumber];
    }
    else if ([cellText isEqualToString:@"Email"]) {
        labelDetail.text = user.EmailAddress;
    }
    else {
        labelDetail.hidden = YES;
    }
    
    SettingSwitch *ctrlSwitch = (SettingSwitch *)[cell viewWithTag:300];
    ctrlSwitch.section = indexPath.section;
    if ([cellText isEqualToString:@"Save Photos"]
        || [cellText isEqualToString:@"Private Account"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ctrlSwitch.hidden = NO;
        [self loadSettings:ctrlSwitch];
    }
    else if ([cellText isEqualToString:@"Push Notifications"]
             || [cellText isEqualToString:@"info@twystapp.co"]
             || [cellText isEqualToString:@"Privacy Policy"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        ctrlSwitch.hidden = YES;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        ctrlSwitch.hidden = YES;
    }
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView defaultCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
    
    // cell text
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.94f];
    cell.textLabel.textColor = Color(38, 32, 43);
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.backgroundColor = [UIColor whiteColor];
    
    //
    CGRect frameSwitch = CGRectMake(255, 2.5, 51, 32);
    SettingSwitch *ctrlSwitch = [[SettingSwitch alloc] initWithFrame:frameSwitch];
    [ctrlSwitch addTarget:self action:@selector(handleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    ctrlSwitch.tag = 300;
    [cell addSubview:ctrlSwitch];
    ctrlSwitch.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    //
    CGRect frameCell = CGRectMake(0, 0, 320, 37);
    UIView *rollover = [[UIView alloc] initWithFrame:frameCell];
    rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
    cell.selectedBackgroundView = rollover;
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView iPhone6CellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
    
    // cell text
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    cell.textLabel.textColor = Color(38, 32, 43);
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.backgroundColor = [UIColor whiteColor];
    
    //
    CGRect frameSwitch = CGRectMake(310, 6, 51, 32);
    SettingSwitch *ctrlSwitch = [[SettingSwitch alloc] initWithFrame:frameSwitch];
    [ctrlSwitch addTarget:self action:@selector(handleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    ctrlSwitch.tag = 300;
    [cell addSubview:ctrlSwitch];
    
    //
    CGRect frameCell = CGRectMake(0, 0, 375, 44);
    UIView *rollover = [[UIView alloc] initWithFrame:frameCell];
    rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
    cell.selectedBackgroundView = rollover;
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView iPhone6PlusCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
    
    // cell text
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.4f];
    cell.textLabel.textColor = Color(38, 32, 43);
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.backgroundColor = [UIColor whiteColor];
    
    //
    CGRect frameSwitch = CGRectMake(349, 8, 51, 32);
    SettingSwitch *ctrlSwitch = [[SettingSwitch alloc] initWithFrame:frameSwitch];
    [ctrlSwitch addTarget:self action:@selector(handleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    ctrlSwitch.tag = 300;
    [cell addSubview:ctrlSwitch];
    
    //
    CGRect frameCell = CGRectMake(0, 0, 414, 48);
    UIView *rollover = [[UIView alloc] initWithFrame:frameCell];
    rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
    cell.selectedBackgroundView = rollover;
    
    return cell;
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 50;
    }
    else if (section == 2) {
        return 68;
    }
    else if (section == 3) {
        DeviceType type = [Global deviceType];
        switch (type) {
            case DeviceTypePhone6:
                return 360;
                break;
            case DeviceTypePhone6Plus:
                return 400;
                break;
            default:
                return 322;
        }
        
    }
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamedForDevice:@"text-setting-private"];
        UIImageView *imageText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        imageText.image = image;
        [footerView addSubview:imageText];
        
        return footerView;
    }
    else if (section == 2) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 68)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamedForDevice:@"text-setting-camera"];
        UIImageView *imageText = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        imageText.image = image;
        [footerView addSubview:imageText];
        
        return footerView;
    }
    else if (section == 3) {
        return [self createFeedbackFooterView];
    }
    return nil;
}

- (UIView*)createFeedbackFooterView {
    CGFloat intervalY = [self tableView:self.tableView heightForHeaderInSection:0];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 500)];
    footerView.backgroundColor = [UIColor clearColor];
    
    // add feedback image
    UIImage *image = [UIImage imageNamedForDevice:@"text-setting-feedback"];
    CGRect frame = CGRectMake(0, intervalY, image.size.width, image.size.height);
    UIImageView *imageBg = [[UIImageView alloc] initWithFrame:frame];
    imageBg.image = image;
    [footerView addSubview:imageBg];
    
    // add feedback button
    UIImage *normalImage = [UIImage imageNamedForDevice:@"btn-setting-feedback-on"];
    UIImage *highlightImage = [UIImage imageNamedForDevice:@"btn-setting-feedback-hl"];
    frame = CGRectMake((SCREEN_WIDTH - normalImage.size.width) / 2, intervalY + image.size.height * 0.38, normalImage.size.width, normalImage.size.height);
    UIButton *btnFeedback = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFeedback.frame = frame;
    [btnFeedback setImage:normalImage forState:UIControlStateNormal];
    [btnFeedback setImage:highlightImage forState:UIControlStateHighlighted];
    [btnFeedback addTarget:self action:@selector(handleBtnFeedbackTouch:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btnFeedback];
    
    // add rate app button
    normalImage = [UIImage imageNamedForDevice:@"btn-setting-rate-app-on"];
    highlightImage = [UIImage imageNamedForDevice:@"btn-setting-rate-app-hl"];
    frame = CGRectMake((SCREEN_WIDTH - normalImage.size.width) / 2, intervalY + image.size.height * 0.67, normalImage.size.width, normalImage.size.height);
    UIButton *btnRateApp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRateApp.frame = frame;
    [btnRateApp setImage:normalImage forState:UIControlStateNormal];
    [btnRateApp setImage:highlightImage forState:UIControlStateHighlighted];
    [btnRateApp addTarget:self action:@selector(handleBtnRateAppTouch:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btnRateApp];
    
    // add logout button
    normalImage = [UIImage imageNamedForDevice:@"btn-setting-logout-on"];
    highlightImage = [UIImage imageNamedForDevice:@"btn-setting-logout-hl"];
    frame = CGRectMake((SCREEN_WIDTH - normalImage.size.width) / 2, intervalY * 2 + image.size.height, normalImage.size.width, normalImage.size.height);
    UIButton *btnLogout = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogout.frame = frame;
    [btnLogout setImage:normalImage forState:UIControlStateNormal];
    [btnLogout setImage:highlightImage forState:UIControlStateHighlighted];
    [btnLogout addTarget:self action:@selector(handleBtnLogoutTouch:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btnLogout];
    
    return footerView;
}

#pragma mark -
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString * cellText = [[settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([cellText isEqualToString:@"Username"]) {
        [self handleBtnUsernameTouch:nil];
    }
    else if ([cellText isEqualToString:@"Full Name"]) {
        [self handleBtnFullNameTouch:nil];
    }
    else if ([cellText isEqualToString:@"Mobile Number"]) {
        [self handleBtnMobileNumberTouch:nil];
    }
    else if ([cellText isEqualToString:@"Email"]) {
        [self handleBtnEmailTouch:nil];
    }
    else if ([cellText isEqualToString:@"Password"]) {
        [self handleBtnPasswordTouch:nil];
    }
    else if ([cellText isEqualToString:@"Bio"]) {
        [self handleBtnBioTouch:nil];
    }
    
    
    else if ([cellText isEqualToString:@"Push Notifications"]) {
        [self handleBtnPushTouch:nil];
    }
    
    else if ([cellText isEqualToString:@"info@twystapp.co"]) {
        [self handleBtnEmailSupportTouch:nil];
    }
    else if ([cellText isEqualToString:@"Privacy Policy"]) {
        [self handleBtnPolicyTouch:nil];
    }
}

- (void)handleBtnUsernameTouch:(id)sender {
    SettingUsernameViewController * viewController = [[SettingUsernameViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleBtnFullNameTouch:(id)sender {
    SettingFullnameViewController *viewController = [[SettingFullnameViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleBtnMobileNumberTouch:(id)sender {
    MobileNumber1ViewController * viewController = [[MobileNumber1ViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleBtnEmailTouch:(id)sender {
    SettingEmailViewController * viewController = [[SettingEmailViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleBtnPasswordTouch:(id)sender {
    SettingPasswordViewController * viewController = [[SettingPasswordViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleBtnBioTouch:(id)sender {
    SettingBioViewController *viewController = [[SettingBioViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleSwitchValueChanged:(SettingSwitch *)ctrlSwitch {
    if (ctrlSwitch.section == 1) {
        [self actionUpdatePrivateProfile];
    }
    else if (ctrlSwitch.section == 2) {
        [Global getConfig].isSaveVideo = ctrlSwitch.isOn;
    }
    [Global saveConfig];
}

- (void)handleBtnPushTouch:(id)sender {
    SettingPushViewController *viewController = [[SettingPushViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleBtnEmailSupportTouch:(id)sender  {
    [self actionSendEmail];
}

- (void)handleBtnPolicyTouch:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PRIVACY_LINK]];
}

- (void)handleBtnRateAppTouch:(id)sender {
    
}

- (void)handleBtnFeedbackTouch:(id)sender {
    [self actionSendEmail];
}

- (void)handleBtnLogoutTouch:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Cancel", @"Logout", nil];
    alert.tag = 100;
    [alert show];
}

- (void)actionSendEmail {
    if ([MFMailComposeViewController canSendMail])
    {
        // Custom initialization
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSString *supportEmail = DEF_SUPPORT_EMAIL;
        NSArray *toRecipients = [[NSArray alloc] initWithObjects:supportEmail, nil];
        [mailer setToRecipients:toRecipients];
        
        [mailer setMessageBody:@"" isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            AppDelegate *appDelegate = [AppDelegate sharedInstance];
            [[UserWebService sharedInstance] logOutUser:^(BOOL isSucess) {
                NSLog(@"complete logout user: %d", isSucess);
                [[UserLocalServices sharedInstance] logOut];
                [appDelegate clearServices];
            }];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            // Logout
            [appDelegate reloadLandingScreen];
        }
    }
}

#pragma mark - Email Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    BOOL isSent = NO;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            isSent = YES;
            //[_alrtMailSentView show];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [controller dismissViewControllerAnimated:YES completion:nil];
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
