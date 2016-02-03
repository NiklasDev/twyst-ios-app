//
//  TwystPeopleViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "CustomSearchBar.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"

#import "FriendsCell.h"

#import "TwystPeopleViewController.h"
#import "FriendProfileViewController.h"

@interface TwystPeopleViewController () <SearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    NSInteger _start;
    BOOL _isAllLoaded;
    
    NSMutableArray *_dataSource;
    long _selectedUserId;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *rightButtonContainer;

@end

@implementation TwystPeopleViewController

#pragma mark - init

- (id)initWithTwystId:(long)twystId {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"TwystPeopleViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _twystId = twystId;
        _dataSource = [NSMutableArray new];
        _friendService = [FriendManageService sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self actionGetTwysters];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.tableView reloadData];
}

- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - internal methods
- (void)actionGetTwysters {
    if (_isAllLoaded) {
        return;
    }
    
    [[UserWebService sharedInstance] getFriendsInTwyst:_twystId start:_start completion:^(NSArray *twysters) {
        if (twysters) {
            [_dataSource addObjectsFromArray:twysters];
            _start = _dataSource.count;
            if (twysters.count < DEF_PAGE_BUNCH) {
                _isAllLoaded = YES;
            }
            [self.tableView reloadData];
        }
        else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
        }
    }];
}

#pragma mark - internal methods
- (NSDictionary*)getUserDictionary:(NSDictionary*)relationDic {
    return [relationDic objectForKey:@"OCUser1_userid"];
}

- (void)actionSendRequest {
    NSString *friendId = [NSString stringWithFormat:@"%ld", _selectedUserId];
    [CircleProcessingView showInView:self.view];
    self.rightButtonContainer.hidden = YES;
    [_friendService requesetFriend:friendId completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        self.rightButtonContainer.hidden = NO;
        if (isSuccess) {
            [self.tableView reloadData];
        } else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
        }
    }];
}

- (void)actionUnfriend {
    NSString *requestId = [_friendService friendshipId:_selectedUserId];
    [CircleProcessingView showInView:self.view];
    self.rightButtonContainer.hidden = YES;
    [_friendService removeFriend:requestId completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        self.rightButtonContainer.hidden = NO;
        if (isSuccess) {
            [self.tableView reloadData];
        } else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
        }
    }];
}

- (void)actionGotoFriendProfile:(NSDictionary*)friend {
    long friendId = [[friend objectForKey:@"Id"] longValue];
    if (friendId != [Global getOCUser].Id) {
        OCUser *user = [OCUser createNewUserWithDictionary:friend];
        FriendProfileViewController *viewController = [[FriendProfileViewController alloc] init];
        viewController.user = user;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (NSString*)twysterString {
    if (self.twysterCount == 0) {
        self.twysterCount = _dataSource.count;
    }
    return [NSString stringWithFormat:@"%@ PEOPLE", [FlipframeUtils countString:self.twysterCount]];
}

#pragma mark - handle button methods
- (IBAction)handleBtnBackTouch:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionFromRight;
    [transition setType:kCATransitionPush];
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_dataSource.count > 0) {
        switch ([Global deviceType]) {
            case DeviceTypePhone6Plus:
                return 33;
                break;
            default:
                return 30;
                break;
        }
    }
    else {
        return 0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = nil;
    if (_dataSource.count > 0) {
        switch ([Global deviceType]) {
            case DeviceTypePhone6Plus:
                headerView = [self tableView:tableView iPhone6PlusViewForHeaderInSection:section];
                break;
            default:
                headerView = [self tableView:tableView defaultViewForHeaderInSection:section];
                break;
        }
    }
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView defaultViewForHeaderInSection:(NSInteger)section {
    CGRect frameHeader = CGRectMake(0, 0, 320, 30);
    UIView *headerView = [[UIView alloc] initWithFrame:frameHeader];
    headerView.backgroundColor = Color(242, 242, 242);
    
    CGRect frameLabel = CGRectMake(13, 8, 200, 20);
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:frameLabel];
    labelTitle.textColor = Color(116, 117, 132);
    labelTitle.font = [UIFont fontWithName:@"Seravek" size:12];
    [headerView addSubview:labelTitle];
    labelTitle.text = [self twysterString];
    
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView iPhone6PlusViewForHeaderInSection:(NSInteger)section {
    CGRect frameHeader = CGRectMake(0, 0, 320, 34);
    UIView *headerView = [[UIView alloc] initWithFrame:frameHeader];
    headerView.backgroundColor = Color(242, 242, 242);
    
    CGRect frameLabel = CGRectMake(13, 11, 200, 20);
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:frameLabel];
    labelTitle.textColor = Color(116, 117, 132);
    labelTitle.font = [UIFont fontWithName:@"Seravek" size:13];
    [headerView addSubview:labelTitle];
    labelTitle.text = [self twysterString];
    
    return headerView;
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FriendsCell heightForCell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsCell * cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:[FriendsCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[FriendsCell alloc] init];
    }
    NSDictionary *friendDic = [self getUserDictionary:[_dataSource objectAtIndex:indexPath.row]];
    [cell configureResultCell:friendDic index:indexPath.row target:self selector:@selector(handleFriendCellTouch:)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *friendDic = [self getUserDictionary:[_dataSource objectAtIndex:indexPath.row]];
    long friendId = [[friendDic objectForKey:@"Id"] longValue];
    if (friendId != [Global getOCUser].Id && friendId > 1) {
        [self actionGotoFriendProfile:friendDic];
    }
}

- (void)handleFriendCellTouch:(UIButton*)sender {
    NSDictionary *friendDic = [self getUserDictionary:[_dataSource objectAtIndex:sender.tag]];
    NSNumber *friendId = [friendDic objectForKey:@"Id"];
    UserRelationType relationShip = [_friendService getUserRelationTypeShip:friendId];
    _selectedUserId = [friendId longValue];
    
    if (relationShip == UserRelationTypeFriend) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Unfollow"
                                                        otherButtonTitles:nil];
        actionSheet.tag = SlideUpTypeUnfriend;
        [actionSheet showFromTabBar:[AppDelegate sharedInstance].tabBarController.tabBar];
    }
    else if (relationShip == UserRelationTypeNone) {
        id privateProfile = friendDic[@"PrivateProfile"];
        if (![privateProfile isKindOfClass:[NSNull class]] && [privateProfile boolValue]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Send Request", nil];
            actionSheet.tag = SlideUpTypeAddFriend;
            [actionSheet showFromTabBar:[AppDelegate sharedInstance].tabBarController.tabBar];
        } else {
            [self actionSendRequest];
        }
    }
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SlideUpTypeUnfriend) {
        if (buttonIndex == 0) {
            [self actionUnfriend];
        }
    }
    else if (actionSheet.tag == SlideUpTypeAddFriend) {
        if (buttonIndex == 0) {
            [self actionSendRequest];
        }
    }
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self actionGetTwysters];
    }
}

@end
