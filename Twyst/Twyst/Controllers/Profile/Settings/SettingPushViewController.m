//
//  SettingPushViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 2/09/15.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "UserWebService.h"
#import "ValidationService.h"

#import "FTextField.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"

#import "SettingPushViewController.h"

@interface SettingPushViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSString *_cellIdentifier;
    NSArray *settings;
    NSArray *headers;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SettingPushViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"SettingPushViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        [self initMembers];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}


#pragma mark - internal methods
- (void)initMembers {
    _cellIdentifier = @"pushSettingCellIdentifier";
    settings = @[
                 @[@"Direct twysts", @"Passes", @"Replies", @"Likes", @"Follows"],
                 ];
    
    headers = @[@"Notify me of:"];
}

- (void)actionUpdateProfile:(NSString*)cellText {
    OCUser *user = [Global getOCUser];
    if ([cellText isEqualToString:@"Replies"]) {
        user.SendReplyNot = !user.SendReplyNot;
    }
    else if ([cellText isEqualToString:@"Likes"]) {
        user.SendLikeNot = !user.SendLikeNot;
    }
    else if ([cellText isEqualToString:@"Passes"]) {
        user.SendPassStringgNot = !user.SendPassStringgNot;
    }
    else if ([cellText isEqualToString:@"Direct twysts"]) {
        user.SendNewStringgNot = !user.SendNewStringgNot;
    }
    else if ([cellText isEqualToString:@"Follows"]) {
        user.SendFriendNot = !user.SendFriendNot;
    }
    
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] updateProfile:user completion:^(NSInteger statusCode) {
        [CircleProcessingView hide];
        [self.tableView reloadData];
        if (statusCode == 0)   {
            NSLog(@"update push notification setting success");
            [Global saveOCUser];
        }   else    {
            NSLog(@"update push notification setting failed");
            [Global recoverOCUser];
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
        }
    }];
}

#pragma mark - table view delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [settings count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[settings objectAtIndex:section] count];
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 48.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            headerView = [self tableView:tableView iPhone6ViewForHeaderInSection:section];
            break;
        case DeviceTypePhone6Plus:
            headerView = [self tableView:tableView iPhone6PlusViewForHeaderInSection:section];
            break;
        default:
            headerView = [self tableView:tableView defaultViewForHeaderInSection:section];
            break;
    }
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView defaultViewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    headerView.backgroundColor = [UIColor clearColor];
    
    NSString *title = [headers objectAtIndex:section];
    if ([title length]) {
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 200, 25)];
        labelTitle.textColor = Color(115, 111, 122);
        labelTitle.font = [UIFont fontWithName:@"Seravek-Bold" size:12.6f];
        labelTitle.text = title;
        [headerView addSubview:labelTitle];
    }
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView iPhone6ViewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 56)];
    headerView.backgroundColor = [UIColor clearColor];
    
    NSString *title = [headers objectAtIndex:section];
    if ([title length]) {
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 200, 25)];
        labelTitle.textColor = Color(115, 111, 122);
        labelTitle.font = [UIFont fontWithName:@"Seravek-Bold" size:14.4f];
        labelTitle.text = title;
        [headerView addSubview:labelTitle];
    }
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView iPhone6PlusViewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 56)];
    headerView.backgroundColor = [UIColor clearColor];
    
    NSString *title = [headers objectAtIndex:section];
    if ([title length]) {
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 25)];
        labelTitle.textColor = Color(115, 111, 122);
        labelTitle.font = [UIFont fontWithName:@"Seravek-Bold" size:15.7f];
        labelTitle.text = title;
        [headerView addSubview:labelTitle];
    }
    
    return headerView;
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
    
    static NSString * cellIdentifier = @"CellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
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
    }
    
    cell.textLabel.text = cellText;
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
    if (imageView) {
        if ([self pushValueForIndex:cellText]) {
            imageView.image = [UIImage imageNamedForDevice:@"ic-cell-setting-option-on"];
        }
        else {
            imageView.image = [UIImage imageNamedForDevice:@"ic-cell-setting-option-off"];
        }
    }
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView defaultCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
    
    // cell text
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.94f];
    cell.textLabel.textColor = Color(46, 39, 52);
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(292, 10, 16, 16);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = 100;
    [cell addSubview:imageView];
    
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
    cell.textLabel.textColor = Color(46, 39, 52);
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(340, 13, 18, 18);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = 100;
    [cell addSubview:imageView];
    
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
    cell.textLabel.textColor = Color(46, 39, 52);
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(379, 14, 21, 21);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.tag = 100;
    [cell addSubview:imageView];
    
    CGRect frameCell = CGRectMake(0, 0, 414, 48);
    UIView *rollover = [[UIView alloc] initWithFrame:frameCell];
    rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
    cell.selectedBackgroundView = rollover;
    
    return cell;
}

#pragma mark -
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString * cellText = [[settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self actionUpdateProfile:cellText];
}

- (BOOL)pushValueForIndex:(NSString*)cellText {
    OCUser *user = [Global getOCUser];
    if ([cellText isEqualToString:@"Replies"]) {
        return user.SendReplyNot;
    }
    else if ([cellText isEqualToString:@"Passes"]) {
        return user.SendPassStringgNot;
    }
    else if ([cellText isEqualToString:@"Direct twysts"]) {
        return user.SendNewStringgNot;
    }
    else if ([cellText isEqualToString:@"Likes"]) {
        return user.SendLikeNot;
    }
    else if ([cellText isEqualToString:@"Follows"]) {
        return user.SendFriendNot;
    }
    return YES;
}

#pragma mark - handle button methods
- (IBAction)onBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
