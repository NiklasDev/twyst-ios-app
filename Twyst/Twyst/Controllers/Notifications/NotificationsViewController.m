//
//  NotificationsViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/5/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "TTwystManager.h"
#import "TTwystNewsManager.h"
#import "TStillframeRegular.h"
#import "TSavedTwystManager.h"
#import "TTwystOwnerManager.h"

#import "IANoticeManageService.h"
#import "TwystDownloadService.h"

#import "StringgNewsCell.h"
#import "WrongMessageView.h"
#import "CircleProcessingView.h"
#import "EGORefreshTableHeaderView.h"

#import "TwystPreviewController.h"
#import "FindPeopleViewController.h"
#import "NotificationsViewController.h"
#import "FriendProfileViewController.h"

@interface NotificationsViewController () <EGORefreshTableHeaderDelegate, IANoticeTwystNewsDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *_arrStringgNews;
    
    TTwystNewsManager *_twystNewsManager;
    IANoticeManageService *_ianService;
    
    BOOL _isTopScreen;
    long _selectedNewsId;
    
    NSMutableArray *_downloadQueue;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noResultContainer;

@end

@implementation NotificationsViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"NotificationsViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        
        _ianService = [IANoticeManageService sharedInstance];
        _twystNewsManager = [TTwystNewsManager sharedInstance];
        _arrStringgNews = [[NSMutableArray alloc] init];
        _selectedNewsId = NSNotFound;
        
        _downloadQueue = [[NSMutableArray alloc] init];
        
        _ianService.newsDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self actionLoadNews];
    [self actionSetNewsBadge];
    [_downloadQueue removeAllObjects];
    
    //add refresh header view
    [self addEOGRefreshTableHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _selectedNewsId = NSNotFound;
    [self actionLoadNews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self removeAllBadge];
    [[AppDelegate sharedInstance] setNotificationBadge:0];
    _isTopScreen = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isTopScreen = NO;
}

#pragma mark - public methods
- (void)actionLoadNews {
    NSArray *news = [_twystNewsManager getAllNews];
    [_arrStringgNews removeAllObjects];
    [_arrStringgNews addObjectsFromArray:news];
    [self actionReloadContentView];
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

- (void)actionShowEmpty {
    if (_arrStringgNews.count) {
        self.noResultContainer.hidden = YES;
    }
    else {
        self.noResultContainer.hidden = NO;
    }
}

- (void)actionReloadContentView {
    [self.tableView reloadData];
    [self actionShowEmpty];
}

- (void)actionSetNewsBadge {
    if (!_isTopScreen) {
        NSInteger newsCount = 0;
        for (TTwystNews *news in _arrStringgNews) {
            if ([news.hasBadge boolValue]) {
                newsCount++;
            }
        }
        [[AppDelegate sharedInstance] setNotificationBadge:newsCount];
    }
}

- (void)removeAllBadge {
    for (TTwystNews *news in _arrStringgNews) {
        if ([news.hasBadge boolValue]) {
            news.hasBadge = [NSNumber numberWithBool:NO];
            [[TTwystNewsManager sharedInstance] saveObject:news];
        }
    }
}

- (void)actionGotoPreview:(Twyst*)twyst {
    TwystPreviewController *viewController = [[TwystPreviewController alloc] init];
    viewController.twyst = twyst;
    [self showPreviewController:viewController];
}

- (void)showPreviewController:(PreviewBaseViewController*)viewController {
    UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    navVC.navigationBarHidden = YES;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
    [self performSelector:@selector(readNotification) withObject:nil afterDelay:0.5f];
}

- (void)actionGotoFriendProfile:(OCUser*)user {
    FriendProfileViewController *viewController = [[FriendProfileViewController alloc] init];
    viewController.user = user;
    [self.navigationController pushViewController:viewController animated:YES];
    [self performSelector:@selector(readNotification) withObject:nil afterDelay:0.5f];
}

- (TTwystNews*)actionGetSelectedNews {
    if (_selectedNewsId == NSNotFound) {
        return nil;
    }
    
    for (TTwystNews *news in _arrStringgNews) {
        long newsId = [news.newsId longValue];
        if (_selectedNewsId == newsId) {
            return news;
        }
    }
    return nil;
}

- (void)readNotification {
    TTwystNews *selectedNews = [self actionGetSelectedNews];
    if (selectedNews) {
        selectedNews.isUnread = [NSNumber numberWithBool:NO];
        [_twystNewsManager saveObject:selectedNews];
        [self actionReloadContentView];
    }
}

#pragma mark - handle button methods
- (IBAction)handleBtnEmptyCreateTouch:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCameraTabDidSelectNotification object:nil];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTwystNews *news = [_arrStringgNews objectAtIndex:indexPath.row];
    return [StringgNewsCell heightForCell:news];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrStringgNews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StringgNewsCell * cell = [tableView dequeueReusableCellWithIdentifier:[StringgNewsCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[StringgNewsCell alloc] init];
    }
    
    TTwystNews *news = [_arrStringgNews objectAtIndex:indexPath.row];
    [cell configureCell:news];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TTwystNews *news = [_arrStringgNews objectAtIndex:indexPath.row];
    _selectedNewsId = [news.newsId longValue];
    
    if ([news.type isEqualToString:@"Follow"]) {
        long senderId = [news.senderId longValue];
        TTwystOwner *owner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:senderId];
        if (owner) {
            OCUser *user = [[TTwystOwnerManager sharedInstance] getOCUserFromTwystOwner:owner];
            [self actionGotoFriendProfile:user];
        }
    }
    else {
        Twyst *twyst = nil;
        long twystId = [news.twystId longValue];
        TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:twystId];
        if (savedTwyst) {
            twyst = [[TSavedTwystManager sharedInstance] getTwystFromTSavedTwyst:savedTwyst];
        }
        else {
            TTwyst *tTwyst = [[TTwystManager sharedInstance] tTwystWithTwystId:twystId];
            if (tTwyst) {
                twyst = [Twyst createNewTwystWithTTwyst:tTwyst];
            }
        }
        if (twyst) {
            [self actionGotoPreview:twyst];
        }
    }
}

#pragma mark - Stringg News Service delegate
- (void)twystNewsDidReceive:(NSArray *)newsArray {
    NSLog(@"===== stringg news received =====\n%@", newsArray);
    for (NSDictionary *newsDic in newsArray) {
        NSString *type = [newsDic objectForKey:@"NewsType"];
        if ([type isEqualToString:@"Like"]) {
            [self handleLikeStringgNews:newsDic];
        }
        if ([type isEqualToString:@"unlike"]) {
            [self handleUnlikeStringgNews:newsDic];
        }
        else if ([type isEqualToString:@"comment"]) {
            [self handleCommentStringgNews:newsDic];
        }
        else if ([type isEqualToString:@"deletecomment"]) {
            [self handleDeleteCommentNews:newsDic];
        }
        else if ([type isEqualToString:@"Pass"]) {
            [self handlePassNews:newsDic];
        }
        else if ([type isEqualToString:@"Reply"]) {
            [self handleReplyNews:newsDic];
        }
        else if ([type isEqualToString:@"Follow"]) {
            [self handleFollowNews:newsDic];
        }
    }
    
    [self actionLoadNews];
    [self actionSetNewsBadge];
}

- (void)handleLikeStringgNews:(NSDictionary*)newsDic {
    long senderId = [[newsDic objectForKey:@"SenderId"] longValue];
    if (senderId != [Global getOCUser].Id) {
        TTwystNews *news = [_twystNewsManager confirmTwystNews:newsDic];
        [_arrStringgNews insertObject:news atIndex:0];
        [self preDownloadTwyst:newsDic];
    }
}

- (void)handleUnlikeStringgNews:(NSDictionary*)newsDic {
    [_twystNewsManager confirmUnlikeTwyst:newsDic];
}

- (void)handleCommentStringgNews:(NSDictionary*)newsDic {
    long senderId = [[newsDic objectForKey:@"SenderId"] longValue];
    if (senderId != [Global getOCUser].Id) {
        [_twystNewsManager confirmCommentTwyst:newsDic];
        [self preDownloadTwyst:newsDic];
    }
}

- (void)handleDeleteCommentNews:(NSDictionary*)newsDic {
    [_twystNewsManager confirmDeleteCommentTwyst:newsDic];
}

- (void)handlePassNews:(NSDictionary*)newsDic {
    [_twystNewsManager confirmTwystNews:newsDic];
}

- (void)handleReplyNews:(NSDictionary*)newsDic {
    long senderId = [[newsDic objectForKey:@"SenderId"] longValue];
    if (senderId != [Global getOCUser].Id) {
        [_twystNewsManager confirmTwystNews:newsDic];
    }
}

- (void)handleFollowNews:(NSDictionary*)newsDic {
    long senderId = [[newsDic objectForKey:@"SenderId"] longValue];
    if (senderId != [Global getOCUser].Id) {
        [_twystNewsManager confirmTwystNews:newsDic];
    }
}

- (void)preDownloadTwyst:(NSDictionary*)newsDic {
    // download stringg if it is not local
    long twystId = [[newsDic objectForKey:@"StringgId"] longValue];
    TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:twystId];
    if (savedTwyst == nil) {
        [_downloadQueue addObject:[newsDic objectForKey:@"StringgId"]];
        NSDictionary *twystDic = [newsDic objectForKey:@"Stringg"];
        Twyst *twyst = [Twyst createNewTwystWithDictionary:twystDic];
        [[TwystDownloadService sharedInstance] downloadTwyst:twyst isUrgent:NO];
        [[TTwystManager sharedInstance] confirmTTwyst:twyst];
    }
}

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0f];
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
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
