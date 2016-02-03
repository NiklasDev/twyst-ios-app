//
//  LandingFriendView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "AppDelegate.h"

#import "UserWebService.h"
#import "ValidationService.h"
#import "FriendManageService.h"

#import "CustomSearchBar.h"
#import "WrongMessageView.h"

#import "ContactCell.h"
#import "LandingFriendView.h"
#import "LandingTopBarView.h"

#import "NMTransitionManager+Headers.h"

@interface LandingFriendView() <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, SearchBarDelegate> {
    NSString *_searchKey;
    CustomSearchBar *_searchBar;

    NSMutableArray *_friendsArray;
    NSMutableArray *_dataSourceFriends;
    
    long _selectedFriendId;
}

@property (nonatomic, strong) UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LandingFriendView

+ (LandingFriendView*)friendViewWithParent:(LandingPageViewController *)parent friends:(NSArray *)friends {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"LandingFriendView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    LandingFriendView *friendView = [subViews firstObject];
    friendView.parentViewController = parent;
    [friendView initView:friends];
    return friendView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)customizeTopBar:(LandingTopBarView *)topBar {
    CGRect frameSkip = CGRectZero;
    CGRect frameSearch = CGRectZero;
    CGRect frameSearchBar = CGRectZero;
    CGFloat skipFontSize = 0;
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            frameSkip = CGRectMake(7, 22, 48, 40);
            frameSearch = CGRectMake(326, 22, 40, 40);
            frameSearchBar = CGRectMake(0, 20, SCREEN_WIDTH, 44);
            skipFontSize = 17;
            break;
        case DeviceTypePhone6Plus:
            frameSkip = CGRectMake(9, 26, 48, 40);
            frameSearch = CGRectMake(362, 27, 40, 40);
            frameSearchBar = CGRectMake(0, 24, SCREEN_WIDTH, 44);
            skipFontSize = 18.8;
            break;
        default:
            frameSkip = CGRectMake(6, 22, 48, 40);
            frameSearch = CGRectMake(275, 22, 40, 40);
            frameSearchBar = CGRectMake(0, 20, SCREEN_WIDTH, 44);
            skipFontSize = 16;
            break;
    }
    
    UIButton *btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSkip.frame = frameSkip;
    [btnSkip setTitle:@"Skip" forState:UIControlStateNormal];
    [btnSkip setTitleColor:Color(58, 50, 88) forState:UIControlStateNormal];
    [btnSkip setTitleColor:Color(91, 87, 111) forState:UIControlStateHighlighted];
    [btnSkip setTitleColor:ColorRGBA(58, 50, 88, 0.2) forState:UIControlStateDisabled];
    btnSkip.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:skipFontSize];
    [btnSkip addTarget:self action:@selector(handleBtnSkipTouch:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnSkip];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = frameSearch;
    [btnSearch setImage:[UIImage imageNamedForDevice:@"btn-landing-top-search-on"] forState:UIControlStateNormal];
    [btnSearch setImage:[UIImage imageNamedForDevice:@"btn-landing-top-search-hl"] forState:UIControlStateHighlighted];
    [btnSearch addTarget:self action:@selector(handleBtnSearchTouch:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:btnSearch];
    
    self.searchBarContainer = [[UIView alloc] initWithFrame:frameSearchBar];
    self.searchBarContainer.backgroundColor = [UIColor clearColor];
    self.searchBarContainer.alpha = 0;
    [topBar addSubview:self.searchBarContainer];
    
    _searchBar = [[CustomSearchBar alloc] initWithTarget:self];
    [self.searchBarContainer addSubview:_searchBar];
}

#pragma mark - internal actions
- (void)initView:(NSArray*)friends {

    //sort array
    NSArray *tempArray = [friends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult resut = [(NSString *)[obj1 objectForKey:@"UserName"]
                                    compare:(NSString *)[obj2 objectForKey:@"UserName"]
                                    options:NSCaseInsensitiveSearch];
        return resut;
    }];
    _friendsArray = [NSMutableArray arrayWithArray:tempArray];
    _dataSourceFriends = [NSMutableArray new];
    
    [self filterDataSource];
}

- (void)filterDataSource {
    
    [_dataSourceFriends removeAllObjects];
    
    if (_searchKey == nil) {
        [_dataSourceFriends addObjectsFromArray:_friendsArray];
    }
    else if ([_searchKey isEqualToString:@""]) {
        // none
    }
    else {
        for (NSDictionary *friendDic in _friendsArray) {
            NSString *userName = [friendDic objectForKey:@"UserName"];
            if ([FlipframeUtils isSubstring:_searchKey of:[userName lowercaseString]]) {
                [_dataSourceFriends addObject:friendDic];
            }
        }
    }
    
    self.tableView.alpha = 0.0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [UIView animateWithDuration:0.3 delay:0.1 options:0 animations:^{
            self.tableView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    });
}

- (void)actionStartApp {
    NMSimpleTransition *transition = [[NMSimpleTransition alloc] init];
    transition.fromAnimation = [NMColorFadeInTransitionAnimation animationWithContainerView:self.parentViewController.view color:[UIColor whiteColor]];
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [[AppDelegate sharedInstance] startApp];
        completion();
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

- (void)actionSendRequest {
    NSString *friendId = [NSString stringWithFormat:@"%ld", _selectedFriendId];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[FriendManageService sharedInstance] requesetFriend:friendId
                        completion:^(BOOL isSuccess) {
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                            if (isSuccess) {
                                [self.tableView reloadData];
                            }
                            else {
                                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self];
                            }
                        }];
}

- (void)actionUnfriend {
    NSString *requestId = [[FriendManageService sharedInstance] friendshipId:_selectedFriendId];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[FriendManageService sharedInstance] removeFriend:requestId
                      completion:^(BOOL isSuccess) {
                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                          if (isSuccess) {
                              [self.tableView reloadData];
                          }
                          else {
                              [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self];
                          }
                      }];
}

#pragma mark - button handler
- (void)handleBtnSkipTouch:(id)sender {
    [self actionStartApp];
}

- (void)handleBtnSearchTouch:(id)sender {
    [self showSearchBar];
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

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSourceFriends count];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactCell heightForCell];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ContactCell alloc] init];
    }
    
    NSDictionary *friendDic = [_dataSourceFriends objectAtIndex:indexPath.row];
    [cell configureFriendCell:friendDic index:indexPath.row target:self selector:@selector(handleFriendCellTouch:)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - handle cell action
- (void)handleFriendCellTouch:(UIButton*)sender {
    NSDictionary *friendDic = [_dataSourceFriends objectAtIndex:sender.tag];
    NSNumber *userId = [friendDic objectForKey:@"Id"];
    UserRelationType relationShip = [[FriendManageService sharedInstance] getUserRelationTypeShip:userId];
    _selectedFriendId = [userId longValue];
    
    if (relationShip == UserRelationTypeFriend) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Unfollow"
                                                        otherButtonTitles:nil];
        actionSheet.tag = SlideUpTypeUnfriend;
        [actionSheet showInView:self];
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
            [actionSheet showInView:self];
        } else {
            [self actionSendRequest];
        }
    }
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
