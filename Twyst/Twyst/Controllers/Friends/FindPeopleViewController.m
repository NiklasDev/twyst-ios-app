//
//  FindPeopleViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "UIImage+Device.h"

#import "AppDelegate.h"
#import "UserWebService.h"
#import "FriendManageService.h"
#import "ContactManageService.h"
#import "FlurryTrackingService.h"

#import "CustomSearchBar.h"

#import "ContactCell.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"
#import "EGORefreshTableHeaderView.h"

#import "FindPeopleViewController.h"
#import "InvitePeopleViewController.h"
#import "FriendProfileViewController.h"

@interface FindPeopleViewController () <EGORefreshTableHeaderDelegate, SearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    
    NSString *_searchKey;
    CustomSearchBar *_searchBar;
    
    NSMutableArray *_friends;
    NSMutableArray *_dataSourceFriends;
    
    FriendManageService *_friendService;
    ContactManageService *_contactService;
    
    long _selectedFriendId;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UIView *loadingContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *rightButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UIView *emptyPeopleContainer;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation FindPeopleViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"FindPeopleViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _friends = [[NSMutableArray alloc] init];
        _dataSourceFriends = [[NSMutableArray alloc] init];
        
        _friendService = [FriendManageService sharedInstance];
        _contactService = [ContactManageService sharedInstance];
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
    
    CGFloat tableHeight = SCREEN_HEIGHT - UI_NEW_TOP_BAR_HEIGHT;
    if ([[AppDelegate sharedInstance] isTabBarVisible]) {
        tableHeight = SCREEN_HEIGHT - UI_NEW_TOP_BAR_HEIGHT - UI_TAB_BAR_HEIGHT;
    }
    self.tableView.frame = CGRectMake(0, UI_NEW_TOP_BAR_HEIGHT, SCREEN_WIDTH, tableHeight);
    
    // add refresh header view
    [self addEOGRefreshTableHeader];
    
    // add search bar
    [self addSearchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onContactDidLoadNotification:)
                                                 name:kContactDidLoadNotification
                                               object:nil];
    
    self.loadingContainer.hidden = _contactService.isContactLoaded;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadFriends];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kContactDidLoadNotification
                                                  object: nil];
}

#pragma mark - internal methods
- (void)addEOGRefreshTableHeader {
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
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

#pragma mark - notification handler
- (void)onContactDidLoadNotification:(NSNotification *)notification {
    [self loadFriends];
}

#pragma mark - load friends methods
- (void)loadFriends {
    if (_contactService.isContactLoaded) {
        self.loadingContainer.hidden = YES;
        self.rightButtonContainer.hidden = YES;
        [CircleProcessingView showInView:self.view];
        NSString *phoneCodes = [_contactService generatePhoneNumberString];
        [[UserWebService sharedInstance] searchFriendByPhoneCode:phoneCodes completion:^(NSArray *friends) {
            [self doneLoadingTableViewData];
            
            if (friends) {
                [self prepareDataSource:friends completion:^{
                    [self filterDataSource];
                    self.rightButtonContainer.hidden = (_friends.count == 0);
                    [CircleProcessingView hide];
                    self.emptyPeopleContainer.hidden = _friends.count;
                }];
            }
            else {
                self.rightButtonContainer.hidden = NO;
                [CircleProcessingView hide];
                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
            }
        }];
    }
}

- (void)prepareDataSource:(NSArray*)friends completion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //sort array
        NSArray *tempArray = [friends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSComparisonResult resut = [(NSString *)[obj1 objectForKey:@"UserName"]
                                        compare:(NSString *)[obj2 objectForKey:@"UserName"]
                                        options:NSCaseInsensitiveSearch];
            return resut;
        }];
        [_friends removeAllObjects];
        [_friends addObjectsFromArray:tempArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)filterDataSource {
    
    [_dataSourceFriends removeAllObjects];
    
    if (_searchKey == nil) {
        [_dataSourceFriends addObjectsFromArray:_friends];
    }
    else if ([_searchKey isEqualToString:@""]) {
        // none
    }
    else {
        for (NSDictionary *friendDic in _friends) {
            NSString *userName = [friendDic objectForKey:@"UserName"];
            NSString *friendPhoneNumber = [friendDic objectForKey:@"Phonenumber"];
            NSString *realName = [NSString stringWithFormat:@"%@ %@", [friendDic objectForKey:@"FirstName"], [friendDic objectForKey:@"LastName"]];
            if ([FlipframeUtils isSubstring:_searchKey of:[userName lowercaseString]]
                || [FlipframeUtils isSubstring:_searchKey of:[realName lowercaseString]]
                || [FlipframeUtils isSubstring:_searchKey of:[friendPhoneNumber lowercaseString]]) {
                [_dataSourceFriends addObject:friendDic];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)actionSendRequest {
    NSString *friendId = [NSString stringWithFormat:@"%ld", _selectedFriendId];
    self.rightButtonContainer.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [_friendService requesetFriend:friendId
                       completion:^(BOOL isSuccess) {
                           self.rightButtonContainer.hidden = NO;
                           [CircleProcessingView hide];
                           if (isSuccess) {
                               [self.tableView reloadData];
                           }
                           else {
                               [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
                           }
                       }];
}

- (void)actionUnfriend {
    NSString *requestId = [_friendService friendshipId:_selectedFriendId];
    self.rightButtonContainer.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [_friendService removeFriend:requestId
                     completion:^(BOOL isSuccess) {
                         self.rightButtonContainer.hidden = NO;
                         [CircleProcessingView hide];
                         if (isSuccess) {
                             [self.tableView reloadData];
                         }
                         else {
                             [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
                         }
                     }];
}

#pragma mark - handle button methods
- (IBAction)handleBtnCloseTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleBtnSearchTouch:(id)sender {
    [self showSearchBar];
}

- (IBAction)handleBtnEmptyInviteTouch:(id)sender {
    InvitePeopleViewController *viewController = [[InvitePeopleViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSourceFriends count];
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactCell heightForCell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView friendCellForRowIndexPath:indexPath];
    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView friendCellForRowIndexPath:(NSIndexPath*)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ContactCell alloc] init];
    }
    
    NSDictionary *friendDic = [_dataSourceFriends objectAtIndex:indexPath.row];
    [cell configureFriendCell:friendDic index:indexPath.row target:self selector:@selector(handleFriendCellTouch:)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *friend = [_dataSourceFriends objectAtIndex:indexPath.row];
    long friendId = [[friend objectForKey:@"Id"] longValue];
    if (friendId != [Global getOCUser].Id) {
        OCUser *user = [OCUser createNewUserWithDictionary:friend];
        FriendProfileViewController *viewController = [[FriendProfileViewController alloc] init];
        viewController.user = user;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - handle cell action
- (void)handleFriendCellTouch:(UIButton*)sender {
    NSDictionary *friendDic = [_dataSourceFriends objectAtIndex:sender.tag];
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

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_searchBar isSearchBarFirstResponder]) {
        [_searchBar resignFriendSearchBar];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
    [self.view endEditing:YES];
	
    [self loadFriends];
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
    [_friends removeAllObjects];
    _friends = nil;
    [_dataSourceFriends removeAllObjects];
    _dataSourceFriends = nil;
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
