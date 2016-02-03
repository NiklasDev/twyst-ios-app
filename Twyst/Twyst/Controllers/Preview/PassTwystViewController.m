//
//  PassTwystViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 9/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImage+animatedGIF.h"

#import "UserWebService.h"
#import "FriendManageService.h"

#import "AppDelegate.h"

#import "CustomSearchBar.h"
#import "AddPeopleCell.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"
#import "WDActivityIndicator.h"

#import "PassTwystViewController.h"

@interface PassTwystViewController () <SearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    NSString *_searchKey;
    CustomSearchBar *_searchBar;
    
    UserWebService *_webService;
    FriendManageService *_friendService;
    
    NSArray *_arrFriends;
    NSMutableArray *_dataSource;
    NSMutableArray *_shareFriends;
    
    NSMutableArray *_arrTwysters;
}

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *rightButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UIView *sendBtnContainer;
@property (weak, nonatomic) IBOutlet UIView *loadingContainer;
@property (weak, nonatomic) IBOutlet UIImageView *loadingIndicator;

@property (nonatomic) BOOL twystPassed;

@end

@implementation PassTwystViewController

- (id)init
{
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"PassTwystViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _webService = [UserWebService sharedInstance];
        _friendService = [FriendManageService sharedInstance];
        
        _searchKey = nil;
        _shareFriends = [[NSMutableArray alloc] init];
        _arrFriends = [_friendService friends];
        _dataSource = [[NSMutableArray alloc] init];
        _arrTwysters = [[NSMutableArray alloc] init];
        _twystPassed = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _btnCancel.hidden = !self.isFromPreview;
    _btnHome.hidden = self.isFromPreview;
    
    //add twyst loading gif
    NSURL *gifUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"twyst_loading_purple" ofType:@"gif"]];
    self.loadingIndicator.image = [UIImage animatedImageWithAnimatedGIFURL:gifUrl];
    
    // add search bar
    [self addSearchBar];
    [self actionLoadStringger];
}

#pragma mark - internal methods
- (void)actionCloseView {
    if (self.isFromPreview) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTwistDismissPassModalNotification object:nil userInfo:@{kTwistNotificationShowAlert:@(self.twystPassed)}];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[AppDelegate sharedInstance] backToHomeScreen];
    }
}

- (void)actionLoadStringger {
    self.loadingContainer.hidden = NO;
    [_webService getFriendsInTwyst:_twystId completion:^(NSArray *array) {
        
        for (NSDictionary *stringger in array) {
            NSString *userId = [[stringger objectForKey:@"UserId"] stringValue];
            [_arrTwysters addObject:userId];
        }
        
        [self filterDataSource];
        [self reloadSendButtonStatus];
        
        self.loadingContainer.hidden = YES;
    }];
}

- (void)filterDataSource {
    
    [_dataSource removeAllObjects];
    
    if (_searchKey == nil) {
        [_dataSource addObjectsFromArray:_arrFriends];
    }
    else if ([_searchKey isEqualToString:@""]) {
        // none
    }
    else {
        for (NSDictionary *friendDic in _arrFriends) {
            NSString *userName = [[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"];
            if ([FlipframeUtils isSubstring:_searchKey of:[userName lowercaseString]]) {
                [_dataSource addObject:friendDic];
            }
        }
    }
    
    [self.tableView reloadData];
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

#pragma mark - handle button methods
- (IBAction)handleBtnBackTouch:(id)sender {
    [self actionCloseView];
}

- (IBAction)handleBtnSearchTouch:(id)sender {
    [self showSearchBar];
}

- (IBAction)handleBtnSendTouch:(id)sender {
    
    NSString *friends = [self friendslist];
    
    self.rightButtonContainer.hidden = YES;
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] passTwyst:_twystId friends:friends completion:^(ResponseType response) {
        self.rightButtonContainer.hidden = NO;
        [CircleProcessingView hide];
        if (response == Response_Success) {
            NSLog(@"add people to twyst success");
            self.twystPassed = YES;
            [self actionCloseView];
        }
        else {
            NSLog(@"add people to twyst");
            if (response == Response_Deleted_Twyst) {
                [WrongMessageView showAlert:WrongMessageTypeTwystDeleted target:nil];
            }
            else {
                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
            }
        }
    }];
}

#pragma mark - share stringg methods
- (NSString*) friendslist {
    NSMutableString *friends = nil;
    for (NSString *friendId in _shareFriends) {
        if (friends) {
            [friends appendFormat:@"|%@", friendId];
        }
        else {
            friends = [NSMutableString stringWithString:friendId];
        }
    }
    return friends;
}

#pragma mark - send button show / hide
- (void) reloadSendButtonStatus {
    if ([_shareFriends count]) {
        [self showSendButton];
    }
    else {
        [self hideSendButton];
    }
}

- (void) showSendButton {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat buttonHeight = _sendBtnContainer.frame.size.height;
    
    CGRect destBtnFrame = CGRectMake(0, height - buttonHeight, width, buttonHeight);
    
    CGFloat tableViewHeight = height - UI_NEW_TOP_BAR_HEIGHT;
    tableViewHeight -= buttonHeight;
    CGRect frameTableView = CGRectMake(0, UI_NEW_TOP_BAR_HEIGHT, width, tableViewHeight);
    
    [UIView animateWithDuration:0.2f animations:^{
        _sendBtnContainer.frame = destBtnFrame;
        _tableView.frame = frameTableView;
    }];
}

- (void) hideSendButton {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat buttonHeight = _sendBtnContainer.frame.size.height;
    
    CGRect destBtnFrame = CGRectMake(0, height, width, buttonHeight);
    
    CGFloat tableViewHeight = height - UI_NEW_TOP_BAR_HEIGHT;
    CGRect frameTableView = CGRectMake(0, UI_NEW_TOP_BAR_HEIGHT, width, tableViewHeight);
    
    [UIView animateWithDuration:0.2f animations:^{
        _sendBtnContainer.frame = destBtnFrame;
        _tableView.frame = frameTableView;
    }];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AddPeopleCell heightForCell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView friendCellForRowAtIndexPath:indexPath];
}

- (UITableViewCell*)tableView:(UITableView *)tableView friendCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddPeopleCell * cell = [tableView dequeueReusableCellWithIdentifier:[AddPeopleCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[AddPeopleCell alloc] init];
    }
    
    NSDictionary *friendDic = [_dataSource objectAtIndex:indexPath.row];
    NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
    BOOL selected = [_shareFriends containsObject:friendId];
    BOOL isStringger = [_arrTwysters containsObject:friendId];
    [cell configureFriendCellWithDictionary:friendDic
                             selectedStatus:selected
                                isStringger:isStringger];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        [self handleFriendCellTouch:indexPath.row];
    }
}

- (void)handleFriendCellTouch:(NSInteger)index {
    
    NSDictionary *friendDic = [_dataSource objectAtIndex:index];
    NSString *friendId = [[[friendDic objectForKey:@"OCUser1_friendid"] objectForKey:@"Id"] stringValue];
    
    if ([_shareFriends containsObject:friendId]) {
        [_shareFriends removeObject:friendId];
    }
    else {
        [_shareFriends addObject:friendId];
    }
    
    [self.tableView reloadData];
    [self reloadSendButtonStatus];
}

#pragma mark - scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_searchBar isSearchBarFirstResponder]) {
        [_searchBar resignFriendSearchBar];
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

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
