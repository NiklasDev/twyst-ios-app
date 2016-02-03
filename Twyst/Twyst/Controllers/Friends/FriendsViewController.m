//
//  FriendsViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/5/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"

#import "FriendManageService.h"

#import "FriendsCell.h"
#import "CustomSearchBar.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"
#import "EGORefreshTableHeaderView.h"

#import "FriendsViewController.h"
#import "FindPeopleViewController.h"
#import "InvitePeopleViewController.h"
#import "FriendProfileViewController.h"

#import "UIViewController+FadeHeader.h"

@interface FriendsViewController () <EGORefreshTableHeaderDelegate, SearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    CustomSearchBar *_searchBar;
    
    NSArray *_dataSource;
    
    NSString *_searchString;
    
    FriendDataType _contentType;
    
    FriendManageService *_friendService;
    
    long _selectedFriendId;
    
    EGORefreshTableHeaderView *_refreshFriendsView;
    EGORefreshTableHeaderView *_refreshSearchView;
	BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableViewFriends;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSearch;
@property (weak, nonatomic) IBOutlet UIView *emptySearchResultContainer;
@property (weak, nonatomic) IBOutlet UIView *emptyFriendsContainer;

@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation FriendsViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"FriendsViewController"];
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
    
    _friendService = [FriendManageService sharedInstance];
    
    [self addSearchBar];
    
    //add refresh header view
    [self addEOGRefreshTableHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadContent:_contentType];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _friendService.delegate = nil;
}

#pragma mark - internal methods
- (void)addSearchBar {
    _searchBar = [[CustomSearchBar alloc] initWithTarget:self];
    [self.searchBarContainer addSubview:_searchBar];
}

- (void)addEOGRefreshTableHeader {
    if (_refreshFriendsView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableViewFriends.bounds.size.height, self.view.frame.size.width, self.tableViewFriends.bounds.size.height)];
		view.delegate = self;
		[self.tableViewFriends addSubview:view];
		_refreshFriendsView = view;
	}
	[_refreshFriendsView refreshLastUpdatedDate];
    
    if (_refreshSearchView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableViewSearch.bounds.size.height, self.view.frame.size.width, self.tableViewSearch.bounds.size.height)];
        view.delegate = self;
        [self.tableViewSearch addSubview:view];
        _refreshSearchView = view;
    }
    [_refreshSearchView refreshLastUpdatedDate];
}

#pragma mark - show / hide search bar
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

#pragma mark - public methods
- (void)startNewFriendsSession {
    [self reloadContent:FriendDataTypeFriend];
}

- (void)reloadContent:(FriendDataType)type {
    _contentType = type;
    if (type == FriendDataTypeFriend) {
        [_friendService actionGetFollowing:^(NSArray *friends) {
            [self doneLoadingTableViewData];
            _dataSource = friends;
            [self reloadTableView];
        }];
    }
    else {
        if (IsNSStringValid(_searchString)) {
            [_friendService actionSearchFriends:_searchString completion:^(NSArray *results) {
                [self doneLoadingTableViewData];
                _dataSource = results;
                [self reloadTableView];
            }];
        }
        else {
            _dataSource = nil;
            [self reloadTableView];
        }
    }
}

- (void)reloadTableView {
    if (_contentType == FriendDataTypeFriend) {
        self.tableViewFriends.hidden = NO;
        self.tableViewSearch.hidden = YES;
        _searchString = nil;
        [self.tableViewFriends reloadData];
    }
    else if (_contentType == FriendDataTypeSearchResult) {
        self.tableViewSearch.hidden = NO;
        self.tableViewFriends.hidden = YES;
        [self.tableViewSearch reloadData];
    }
    [self actionEmptyScreen];
}

- (void)actionGotoFindPeople {
    FindPeopleViewController *viewController = [[FindPeopleViewController alloc] init];
    [self pushViewControllerWithFadeAnimation:viewController];
}

- (void)actionGotoInvitePeople {
    FindPeopleViewController *viewController = [[FindPeopleViewController alloc] init];
    [self pushViewControllerWithFadeAnimation:viewController];
}

- (void)actionEmptyScreen {
    BOOL bHide = _dataSource.count;
    switch (_contentType) {
        case FriendDataTypeFriend:
            self.emptyFriendsContainer.hidden = bHide;
            self.emptySearchResultContainer.hidden = YES;
            break;
        case FriendDataTypeSearchResult:
            self.emptyFriendsContainer.hidden = YES;
            self.emptySearchResultContainer.hidden = bHide;
            break;
        default:
            break;
    }
}

- (void)actionSendRequest {
    NSString *friendId = [NSString stringWithFormat:@"%ld", _selectedFriendId];
    self.buttonContainer.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [_friendService requesetFriend:friendId completion:^(BOOL isSuccess) {
        self.buttonContainer.hidden = NO;
        [CircleProcessingView hide];
        if (isSuccess) {
            [self reloadTableView];
        }
        else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
        }
    }];
}

- (void)actionUnfriend {
    NSString *requestId = [_friendService friendshipId:_selectedFriendId];
    self.buttonContainer.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [_friendService removeFriend:requestId completion:^(BOOL isSuccess) {
        self.buttonContainer.hidden = NO;
        [CircleProcessingView hide];
        if (isSuccess) {
            [self reloadTableView];
        }
        else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
        }
    }];
}

#pragma mark - handle button methods
- (IBAction)handleBtnSearchTouch:(id)sender {
    [self showSearchBar];
}

- (IBAction)handleBtnAddFriendTouch:(id)sender {
    [self actionGotoFindPeople];
}

- (IBAction)handleBtnEmptyInviteTouch:(id)sender {
    [self actionGotoInvitePeople];
}

#pragma mark - search bar delegate
- (void)searchBarDidStart {
    _contentType = FriendDataTypeSearchResult;
    [_friendService clearCachedDataWithDataType:FriendDataTypeSearchResult];
    _dataSource = nil;
    [self reloadTableView];
    self.emptySearchResultContainer.hidden = YES;
}

- (void)searchBarDidEndOnExit:(NSString *)searchText {
    if (IsNSStringValid(searchText)) {
        _searchString = searchText;
        [self reloadContent:FriendDataTypeSearchResult];
    }
    else {
        NSLog(@"--- Invalid search string ---");
    }
}

- (void)searchBarDidChanged:(NSString *)searchText {
//    if (IsNSStringValid(searchText)) {
        _searchString = searchText;
        [self reloadContent:FriendDataTypeSearchResult];
//    }
//    else {
//        NSLog(@"--- Invalid search string ---");
//    }
}

- (void)searchBarDidCancel {
    [self hideSearchBar];
    [self reloadContent:FriendDataTypeFriend];
}

#pragma mark - table view delegat

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FriendsCell heightForCell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (_contentType) {
        case FriendDataTypeFriend:
        {
            cell = [self tableView:tableView friendCellForRowIndexPath:indexPath];
        }
            break;
        case FriendDataTypeSearchResult:
        {
            cell = [self tableView:tableView resultCellForRowIndexPath:indexPath];
        }
            break;
        default:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
            break;
    }
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView friendCellForRowIndexPath:(NSIndexPath*)indexPath {
    FriendsCell * cell = [tableView dequeueReusableCellWithIdentifier:[FriendsCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[FriendsCell alloc] init];
    }
    
    NSDictionary *friendDic = [_dataSource objectAtIndex:indexPath.row];
    
    [cell configureFriendCell:friendDic index:indexPath.row target:self selector:@selector(handleFriendCellTouch:)];
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView resultCellForRowIndexPath:(NSIndexPath*)indexPath {
    FriendsCell * cell = [tableView dequeueReusableCellWithIdentifier:[FriendsCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[FriendsCell alloc] init];
    }
    
    NSDictionary *resultDic = [_dataSource objectAtIndex:indexPath.row];
    
    [cell configureSearchResultCell:resultDic];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *friendDic = nil;
    if (_contentType == FriendDataTypeSentRequest) {
        NSDictionary *requestDic = [_dataSource objectAtIndex:indexPath.row];
        long ownerId = [[requestDic objectForKey:@"OwnerId"] longValue];
        if ([Global getOCUser].Id == ownerId) {
            friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
        }
        else {
            friendDic = [requestDic objectForKey:@"OCUser_ownerid"];
        }
    }
    else if (_contentType == FriendDataTypeFriend) {
        NSDictionary *requestDic = [_dataSource objectAtIndex:indexPath.row];
        friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
    }
    else if (_contentType == FriendDataTypeSearchResult) {
        friendDic = [_dataSource objectAtIndex:indexPath.row];
    }
    
    long friendId = [[friendDic objectForKey:@"Id"] longValue];
    if (friendId != [Global getOCUser].Id) {
        OCUser *user = [OCUser createNewUserWithDictionary:friendDic];
        FriendProfileViewController *viewController = [[FriendProfileViewController alloc] init];
        viewController.user = user;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)handleFriendCellTouch:(UIButton*)sender {
    NSDictionary *friendDic = nil;
    if (_contentType == FriendDataTypeFriend) {
        NSDictionary *requestDic = [_dataSource objectAtIndex:sender.tag];
        friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
    }
    else if (_contentType == FriendDataTypeSearchResult) {
        friendDic = [_dataSource objectAtIndex:sender.tag];
    }
    NSNumber *userId = [friendDic objectForKey:@"Id"];
    UserRelationType relationShip = [_friendService getUserRelationTypeShip:userId];
    _selectedFriendId = [userId longValue];
    
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

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource {
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    [_refreshFriendsView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableViewFriends];
    [_refreshSearchView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableViewSearch];
	
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.tableViewFriends]) {
        [_refreshFriendsView egoRefreshScrollViewDidScroll:scrollView];
    }
    else if ([scrollView isEqual:self.tableViewSearch]) {
        [_refreshSearchView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:self.tableViewFriends]) {
        [_refreshFriendsView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    else if ([scrollView isEqual:self.tableViewSearch]) {
        [_refreshSearchView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
    [self reloadContent:_contentType];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    _refreshFriendsView = nil;
    _refreshSearchView = nil;
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
