//
//  BaseFollowsViewController.m
//  Twyst
//
//  Created by Nahuel Morales on 8/5/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseFollowsViewController.h"
#import "AppDelegate.h"

#import "CustomSearchBar.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"

#import "FriendsCell.h"

#import "FriendProfileViewController.h"

@interface BaseFollowsViewController () <SearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    NSString *_searchKey;
    CustomSearchBar *_searchBar;
    
    NSMutableArray *_dataSource;
    NSMutableArray *_arrayPeople;
    long _selectedUserId;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyContainer;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UIView *rightButtonContainer;

@end

@implementation BaseFollowsViewController

#pragma mark - abstract

- (void)actionLoadArrayPeople:(void(^)(NSArray*))completion {
    assert(false);
}

#pragma mark - init

- (id)initWithOCUser:(OCUser*)user {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"BaseFollowsViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _user = user;
        _searchKey = nil;
        _dataSource = [NSMutableArray new];
        _arrayPeople = [NSMutableArray new];
        _friendService = [FriendManageService sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add search bar
    [self addSearchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self loadContent];
}

#pragma mark - show / hide search bar
- (void)addSearchBar {
    _searchBar = [[CustomSearchBar alloc] initWithTarget:self];
    [self.searchBarContainer addSubview:_searchBar];
}

- (void)showSearchBar {
    CGFloat width = SCREEN_WIDTH;
    CGRect frame = CGRectMake(width / 2, 0, width / 2, UI_TOP_BAR_HEIGHT);
    _searchBar.frame = frame;
    _searchBarContainer.alpha = 1.0f;
    frame = CGRectMake(0, 0, width, UI_TOP_BAR_HEIGHT);
    
    [_searchBar focusFriendSearchBar];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _searchBar.frame = frame;
                     }];
}

- (void)hideSearchBar {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _searchBarContainer.alpha = 0.0f;
                     }];
}

#pragma mark - internal methods
- (void)loadContent {
    [CircleProcessingView showInView:self.view];
    self.rightButtonContainer.hidden = YES;
    
    [self actionLoadArrayPeople:^(NSArray *array) {
        [CircleProcessingView hide];
        self.rightButtonContainer.hidden = NO;
        if (array) {
            [_arrayPeople removeAllObjects];
            [_arrayPeople addObjectsFromArray:array];
            [self filterDataSource];
            [self reloadTableView];
        } else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
            self.emptyContainer.hidden = NO;
        }
    }];
}

- (void)reloadTableView {
    [self.tableView reloadData];
    if (_dataSource.count) {
        self.emptyContainer.hidden = YES;
        self.rightButtonContainer.hidden = NO;
    }
    else {
        self.emptyContainer.hidden = NO;
        self.rightButtonContainer.hidden = YES;
    }
}

- (void)filterDataSource {
    
    [_dataSource removeAllObjects];
    
    if (_searchKey == nil) {
        [_dataSource addObjectsFromArray:_arrayPeople];
    }
    else if ([_searchKey isEqualToString:@""]) {
        // none
    }
    else {
        for (NSDictionary *relationDic in _arrayPeople) {
            NSDictionary *userDic = [self getUserDictionary:relationDic];
            NSString *userName = [userDic objectForKey:@"UserName"];
            if ([FlipframeUtils isSubstring:_searchKey of:[userName lowercaseString]]) {
                [_dataSource addObject:relationDic];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (NSDictionary*)getUserDictionary:(NSDictionary*)relationDic {
    if (self.user.Id == [[relationDic objectForKey:@"OwnerId"] longValue]) {
        return [relationDic objectForKey:@"OCUser1_friendid"];
    }
    else if (self.user.Id == [[relationDic objectForKey:@"FriendId"] longValue]) {
        return [relationDic objectForKey:@"OCUser_ownerid"];
    }
    return nil;
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

#pragma mark - handle button methods
- (IBAction)handleBtnBackTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleBtnSearchTouch:(id)sender {
    [self showSearchBar];
}

#pragma mark - table view delegate
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

#pragma mark - search bar delegate
- (void)searchBarDidStart {
    if (_searchKey == nil) {
        _searchKey= @"";
        [self filterDataSource];
    }
}

- (void)searchBarDidChanged:(NSString *)searchText {
    _searchKey = [searchText lowercaseString];
    [self filterDataSource];
}

- (void)searchBarDidClear {
    _searchKey = @"";
    [self filterDataSource];
}

- (void)searchBarDidCancel {
    [self hideSearchBar];
    _searchKey = nil;
    [self filterDataSource];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_searchBar isSearchBarFirstResponder]) {
        [_searchBar resignFriendSearchBar];
    }
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
