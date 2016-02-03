//
//  HomeViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 5/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "UIImage+Device.h"
#import "UIImage+animatedGIF.h"

#import "AppDelegate.h"

#import "TTwystNewsManager.h"
#import "TTwystOwnerManager.h"
#import "TStillframeRegular.h"
#import "TSavedTwystManager.h"

#import "UserWebService.h"
#import "IANoticeManageService.h"
#import "TwystDownloadService.h"
#import "LibraryFlipframeServices.h"

#import "HomeEmptyCell.h"
#import "HomeTwystCell.h"

#import "WrongMessageView.h"
#import "WDActivityIndicator.h"
#import "CircleProcessingView.h"
#import "EGORefreshTableHeaderView.h"

#import "HomeViewController.h"
#import "TwystPreviewController.h"
#import "LibraryPreviewController.h"
#import "InvitePeopleViewController.h"

#import "NMTransitionManager+Headers.h"

#import "Constant.h"

typedef enum {
    HomeDataTypeNone = 100,
    HomeDataTypePrivate,
    HomeDataTypeTwysted,
    HomeDataTypeSaved,
} HomeDataType;

@interface HomeViewController () <IANoticeNotificationDelegate, EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {
    HomeDataType _dataType;
    
    NSInteger _startIndex;
    BOOL _isPrivateAllLoaded;
    BOOL _isPrivateLoadFailed;
    
    NSDate *_startTime;
    BOOL _isTwystedAllLoaded;
    BOOL _isTwystedLoadFailed;
    
    NSMutableArray *_arrayTwysted;
    NSMutableArray *_arrayPrivate;
    NSMutableArray *_arraySaved;
    
    UserWebService *_webService;
    IANoticeManageService *_ianService;
    TwystDownloadService *_downloadService;
    
    BOOL _isTopScreen;
    
    NSInteger _newDirectCount;
    
    EGORefreshTableHeaderView *_refreshViewPrivate;
    EGORefreshTableHeaderView *_refreshViewTwysted;
    EGORefreshTableHeaderView *_refreshViewSaved;
    BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPrivate;
@property (weak, nonatomic) IBOutlet UITableView *tableViewTwysted;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSaved;

@property (weak, nonatomic) IBOutlet UIView *directHeaderView;
@property (weak, nonatomic) IBOutlet UIView *homeHeaderView;
@property (weak, nonatomic) IBOutlet UIView *savedHeaderView;

@property (weak, nonatomic) IBOutlet UIView *loadingContainer;
@property (weak, nonatomic) IBOutlet UIImageView *loadingIndicator;

@property (weak, nonatomic) IBOutlet UIView *privateNewTwyst;
@property (weak, nonatomic) IBOutlet UIView *twystedNewTwyst;

@property (weak, nonatomic) IBOutlet UILabel *labelNewDirect;

@end

@implementation HomeViewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"HomeViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _startIndex = 0;
        _startTime = nil;
        _newDirectCount = 0;
        
        _webService = [UserWebService sharedInstance];
        _downloadService = [TwystDownloadService sharedInstance];
        _ianService = [IANoticeManageService sharedInstance];
        _ianService.notificationDelegate = self;
        
        _dataType = HomeDataTypeTwysted;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self addNotifications];
    [self reloadContent:HomeDataTypeTwysted forced:YES];
    [self registerForNotifications];
}

- (void)registerForNotifications {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kTwistDismissPassModalNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      [strongSelf dismissViewControllerAnimated:YES completion:nil];
                                                      if([notification.userInfo[kTwistNotificationShowAlert] boolValue]) {
                                                          [WrongMessageView showMessage:WrongMessageTypePassSuccessfully inView:[[AppDelegate sharedInstance] window] arrayOffsetY:@[@0, @0, @0]];
                                                      }
                                                  }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTableView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // set top screen
    _isTopScreen = YES;
    
    // hide launch image
    if ([AppDelegate sharedInstance].isHomeLoading) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:kHomeDidLoadNotification object:nil];
        });

    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isTopScreen = NO;
}

- (UIView *)headerView {
    if (!self.directHeaderView.hidden) {
        return self.directHeaderView;
    } else if (!self.homeHeaderView.hidden) {
        return self.homeHeaderView;
    } else if (!self.savedHeaderView.hidden) {
        return self.savedHeaderView;
    }
    return nil;
}

#pragma mark - public methods
- (void) scrollToTop {
    [self.tableViewPrivate setContentOffset:CGPointZero animated:YES];
    [self.tableViewTwysted setContentOffset:CGPointZero animated:YES];
    [self.tableViewSaved setContentOffset:CGPointZero animated:YES];
}

#pragma mark - internal methods
- (void)initView {
    self.scrollView.delaysContentTouches = NO;
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 3, self.scrollView.contentSize.height)];
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
    
    self.labelNewDirect.layer.cornerRadius = self.labelNewDirect.frame.size.height / 2;
    self.labelNewDirect.layer.masksToBounds = YES;
    
    //add twyst loading gif
    NSURL *gifUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"twyst_loading_purple" ofType:@"gif"]];
    self.loadingIndicator.image = [UIImage animatedImageWithAnimatedGIFURL:gifUrl];
    
    //add refresh header view
    [self addEOGRefreshTableHeader];
}

- (void)addEOGRefreshTableHeader {
    // add pull-to-refresh view to table view of private twyst
    if (_refreshViewPrivate == nil) {
        EGORefreshTableHeaderView *viewPrivate = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableViewPrivate.bounds.size.height, self.view.frame.size.width, self.tableViewPrivate.bounds.size.height)];
        viewPrivate.delegate = self;
        [self.tableViewPrivate addSubview:viewPrivate];
        _refreshViewPrivate = viewPrivate;
    }
    
    // add pull-to-refresh view to table view of twysted twyst
    if (_refreshViewTwysted == nil) {
        EGORefreshTableHeaderView *viewTwysted = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableViewTwysted.bounds.size.height, self.view.frame.size.width, self.tableViewTwysted.bounds.size.height)];
        viewTwysted.delegate = self;
        [self.tableViewTwysted addSubview:viewTwysted];
        _refreshViewTwysted = viewTwysted;
    }
    
    // add pull-to-refresh view to table view of saved twyst
    if (_refreshViewSaved == nil) {
        EGORefreshTableHeaderView *viewSaved = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableViewSaved.bounds.size.height, self.view.frame.size.width, self.tableViewSaved.bounds.size.height)];
        viewSaved.delegate = self;
        [self.tableViewSaved addSubview:viewSaved];
        _refreshViewSaved = viewSaved;
    }
    
    [_refreshViewPrivate refreshLastUpdatedDate];
    [_refreshViewTwysted refreshLastUpdatedDate];
    [_refreshViewSaved refreshLastUpdatedDate];
}

- (void)actionSelectTwyst:(NSInteger)index {
    Twyst *twyst = nil;
    switch (_dataType) {
        case HomeDataTypeTwysted:
            if (index >= _arrayTwysted.count) {
                return;
            }
            twyst = [_arrayTwysted objectAtIndex:index];
            break;
        case HomeDataTypePrivate:
            if (index >= _arrayPrivate.count) {
                return;
            }
            twyst = [_arrayPrivate objectAtIndex:index];
            break;
        default:
            break;
    }
    [self actionGotoPreview:twyst];
}

- (void)actionSelectSavedTwyst:(NSInteger)index {
    
    // Get thumbnail view
    HomeTwystCell *cell = (HomeTwystCell *)[_tableViewSaved cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UIImageView *thumbView = cell.imageThumb;
    UIImage *thumbImage = thumbView.image;
    
    // config viewcontroller
    FFlipframeSavedLibrary *flipframeLibrary = [_arraySaved objectAtIndex:index];
    LibraryPreviewController *viewController = [[LibraryPreviewController alloc] init];
    viewController.flipframeLibrary = flipframeLibrary;
    
    UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    navVC.navigationBarHidden = YES;
    [navVC view]; // force view to load
    
    // present with custom animation
    NMEntranceTransitionAnimation *previewAnimation = [NMEntranceTransitionAnimation animationWithContainerView:viewController.view];
    [previewAnimation addEntranceElement:[NMEntranceElementTop animationWithContainerView:viewController.view elementView:viewController.btnBack]];
    [previewAnimation addEntranceElement:[NMEntranceElementBottom animationWithContainerView:viewController.view elementView:viewController.bottomBar]];
    
    NMSimpleTransition *transition = [[NMSimpleTransition alloc] init];
    transition.fromAnimation = [NMImageBurstTransitionAnimation animationWithContainerView:self.tabBarController.view burstView:thumbView image:thumbImage];
    transition.toAnimation = previewAnimation;
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [self.navigationController presentViewController:navVC animated:NO completion:completion];
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

- (void)actionGotoPreview:(Twyst*)twyst {
    TwystPreviewController *viewController = [[TwystPreviewController alloc] init];
    viewController.twyst = twyst;
    [self showPreviewController:viewController];
}

- (void)showPreviewController:(PreviewBaseViewController*)viewController {
    UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    navVC.navigationBarHidden = YES;
    
    NMSimpleTransition *transition = [[NMSimpleTransition alloc] init];
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [self.navigationController presentViewController:navVC animated:NO completion:completion];
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

#pragma mark - content manage methods
- (void)refreshTableView {
    switch (_dataType) {
        case HomeDataTypeTwysted:
            [self.tableViewTwysted reloadData];
            break;
        case HomeDataTypePrivate:
            [self.tableViewPrivate reloadData];
            break;
        case HomeDataTypeSaved:
            [self.tableViewSaved reloadData];
            break;
        default:
            break;
    }
}

- (void)reloadContent:(HomeDataType)dataType forced:(BOOL)forced {
    if (forced == NO && _dataType == dataType) {
        return;
    }
    _dataType = dataType;
    
    //refresh when click tab
    switch (_dataType) {
        case HomeDataTypeTwysted:
            _startTime = nil;
            _isTwystedAllLoaded = NO;
            [self actionGetTwysted];
            break;
        case HomeDataTypePrivate:
            _startIndex = 0;
            _isPrivateAllLoaded = NO;
            [self actionGetPrivate];
            break;
        case HomeDataTypeSaved:
            [self actionGetSaved];
            break;
        default:
            break;
    }
}

- (void)loadMoreContent:(HomeDataType)dataType {
    switch (_dataType) {
        case HomeDataTypeTwysted:
            [self actionGetTwysted];
            break;
        case HomeDataTypePrivate:
            [self actionGetPrivate];
            break;
        default:
            break;
    }
}
- (void)actionGetTwysted {
    if (_isTwystedAllLoaded) {
        return;
    }
    
    NSDate *startTime = nil;
    if (_startTime == nil) {
        startTime = [[Global getInstance] localDateToUTCDate:[NSDate date]];
    }
    else {
        startTime = _startTime;
    }
    
    // show shine effect loading view first time
    if (_arrayTwysted == nil) {
        _arrayTwysted = [NSMutableArray new];
        [self showLoadingView];
    }
    
    [_webService getFeeds:startTime bunch:DEF_HOME_FEED_BUNCH completion:^(NSArray *feeds) {
        [self doneLoadingTableViewData];
        
        if (feeds) {
            if (_startTime == nil) {
                [_arrayTwysted removeAllObjects];
            }
            if (feeds.count) {
                for (Twyst *twyst in feeds) {
                    if (![[TSavedTwystManager sharedInstance] isSavedTwystWithTwystId:twyst.Id]) {
                        [_downloadService downloadTwyst:twyst isUrgent:NO];
                    }
                }
                
                BOOL isNew = NO;
                for (Twyst *twyst in feeds) {
                    [self addTwystToDataSource:HomeDataTypeTwysted twyst:twyst isAscending:NO isNew:&isNew];
                }
                
                Twyst *lastTwyst = [feeds lastObject];
                _startTime = lastTwyst.ActionTimeStamp;
            }
            
            if (feeds.count < DEF_HOME_FEED_BUNCH) {
                _isTwystedAllLoaded = YES;
            }
            _isTwystedLoadFailed = NO;
        }
        else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
            [_arrayTwysted removeAllObjects];
            
            _isTwystedLoadFailed = YES;
        }
        [self.tableViewTwysted reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self hideLoadingView];
        });

    }];
}

- (void)actionGetPrivate {
    if (_isPrivateAllLoaded) {
        return;
    }
    
    // show simple loading view first time
    if (_arrayPrivate == nil) {
        _arrayPrivate = [NSMutableArray new];
        [self showLoadingView];
        self.tableViewPrivate.hidden = NO;
    }
    
    _isPrivateLoadFailed = NO;
    [self.tableViewPrivate reloadData];
    
    [[UserWebService sharedInstance] getPrivateTwysts:_startIndex bunch:DEF_HOME_FEED_BUNCH completion:^(NSArray *privates) {
        [self doneLoadingTableViewData];
        [self hideLoadingView];
        if (privates) {
            if (_startIndex == 0) {
                [_arrayPrivate removeAllObjects];
            }
            
            BOOL isNew = NO;
            for (Twyst *twyst in privates) {
                [self addTwystToDataSource:HomeDataTypePrivate twyst:twyst isAscending:NO isNew:&isNew];
            }
            
            _startIndex = _arrayPrivate.count;
            if (privates.count < DEF_HOME_FEED_BUNCH) {
                _isPrivateAllLoaded = YES;
            }
            _isPrivateLoadFailed = NO;
        }
        else {
            [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view];
            [_arrayPrivate removeAllObjects];
            _isPrivateLoadFailed = YES;
        }
        [self.tableViewPrivate reloadData];
    }];
}

- (void)actionGetSaved {
    
    // show simple loading view first time
    if (_arraySaved == nil) {
        _arraySaved = [NSMutableArray new];
        [self showLoadingView];
        self.tableViewSaved.hidden = NO;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *savedItems = [[LibraryFlipframeServices sharedInstance] loadAllSavedFlipframeForProfile];
        [_arraySaved removeAllObjects];
        for (FFlipframeSavedLibrary *savedItem in savedItems) {
            [_arraySaved addObject:savedItem];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneLoadingTableViewData];
            [self hideLoadingView];
            [self.tableViewSaved reloadData];
        });
    });
}

#pragma mark - data manage methods
- (NSInteger)addTwystToDataSource:(HomeDataType)type twyst:(Twyst*)activeTwyst isAscending:(BOOL)isAscending isNew:(BOOL*)isNew {
    NSMutableArray *dataSource = nil;
    if (type == HomeDataTypePrivate) dataSource = _arrayPrivate;
    else if (type == HomeDataTypeTwysted) dataSource = _arrayTwysted;

    NSInteger count = dataSource.count;
    if (isAscending) {
        for (NSInteger i = 0; i < count; i++) {
            Twyst *twyst = [dataSource objectAtIndex:i];
            NSComparisonResult result = [twyst.DateFinalized compare:activeTwyst.DateFinalized];
            if (result == NSOrderedAscending) {
                [dataSource insertObject:activeTwyst atIndex:i];
                *isNew = YES;
                return i;
            }
            else if (result == NSOrderedSame) {
                [dataSource replaceObjectAtIndex:i withObject:activeTwyst];
                *isNew = NO;
                return i;
            }
        }
        [dataSource addObject:activeTwyst];
        *isNew = YES;
        return count;
    }
    else {
        for (NSInteger i = count - 1; i >= 0; i--) {
            Twyst *twyst = [dataSource objectAtIndex:i];
            NSComparisonResult result = [twyst.DateFinalized compare:activeTwyst.DateFinalized];
            if (result == NSOrderedDescending) {
                [dataSource insertObject:activeTwyst atIndex:i + 1];
                *isNew = YES;
                return i + 1;
            }
            else if (result == NSOrderedSame) {
                [dataSource replaceObjectAtIndex:i withObject:activeTwyst];
                *isNew = NO;
                return i;
            }
        }
        [dataSource insertObject:activeTwyst atIndex:0];
        *isNew = YES;
        return 0;
    }
}

- (NSInteger)deleteTwystFromDataSource:(HomeDataType)type twyst:(Twyst*)activeTwyst {
    NSInteger index = NSNotFound;
    NSMutableArray *dataSource = nil;
    if (type == HomeDataTypePrivate) dataSource = _arrayPrivate;
    else if (type == HomeDataTypeTwysted) dataSource = _arrayTwysted;
    
    NSInteger count = dataSource.count;
    for (NSInteger i = 0; i < count; i++) {
        Twyst *twyst = [dataSource objectAtIndex:i];
        if (twyst.Id == activeTwyst.Id) {
            [dataSource removeObjectAtIndex:i];
            index = i;
            break;
        }
    }
    return index;
}

#pragma mark - button handlers
- (IBAction)handleBtnRightArrowTouch:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
}

- (IBAction)handleBtnPrivateTouch:(id)sender {
    self.labelNewDirect.hidden = YES;
    _newDirectCount = 0;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)handleBtnSavedTouch:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, 0) animated:YES];
}

- (IBAction)handleBtnLeftArrowTouch:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
}

- (IBAction)handlePrivateNewTwystTouch:(id)sender {
    [self.tableViewPrivate setContentOffset:CGPointZero animated:YES];
    [self hideNewTwystDropDown:self.privateNewTwyst];
}

- (IBAction)handleTwystedNewTwystTouch:(id)sender {
    [self.tableViewTwysted setContentOffset:CGPointZero animated:YES];
    [self hideNewTwystDropDown:self.twystedNewTwyst];
}

- (void)handleBtnEmptyCreateTouch:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCameraTabDidSelectNotification object:nil];
}

- (void)handleBtnEmptyInviteTouch:(id)sender {
    InvitePeopleViewController *viewController = [[InvitePeopleViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableViewTwysted]) {
        NSInteger count = _arrayTwysted.count;
        if (count == 0) {
            return 1;
        }
        else {
            if (_isTwystedLoadFailed || _isTwystedAllLoaded) {
                return count;
            }
            else {
                return count + 1;
            }
        }
    }
    else if ([tableView isEqual:self.tableViewPrivate]) {
        NSInteger count = _arrayPrivate.count;
        if (count == 0) {
            return 1;
        }
        else {
            if (_isPrivateAllLoaded) {
                return count;
            }
            else {
                return count + 1;
            }
        }
    }
    else if ([tableView isEqual:self.tableViewSaved]) {
        return MAX(1, _arraySaved.count);
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if ([tableView isEqual:self.tableViewTwysted]) {
        NSInteger count = _arrayTwysted.count;
        if (count == 0) {
            return [HomeEmptyCell heightForCell];
        }
        else {
            if (indexPath.row == _arrayTwysted.count) {
                return 44;
            }
            else {
                Twyst *twyst = [_arrayTwysted objectAtIndex:indexPath.row];
                return [HomeTwystCell heightForCell:twyst];
            }
        }
    }
    else if ([tableView isEqual:self.tableViewPrivate]) {
        NSInteger count = _arrayPrivate.count;
        if (count == 0) {
            return [HomeEmptyCell heightForCell];
        }
        else {
            if (indexPath.row == count) {
                return 44;
            }
            else {
                Twyst *twyst = [_arrayPrivate objectAtIndex:indexPath.row];
                return [HomeTwystCell heightForCell:twyst];
            }
        }
        
    }
    else if ([tableView isEqual:self.tableViewSaved]) {
        if (_arraySaved.count) {
            FFlipframeSavedLibrary *twyst = [_arraySaved objectAtIndex:indexPath.row];
            return [HomeTwystCell heightForSavedCell:twyst];
        }
        else {
            return [HomeEmptyCell heightForCell];
        }
    }
    else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell = nil;
    if ([tableView isEqual:self.tableViewTwysted]) {
        cell = [self tableView:tableView twystedCellForRowAtIndexPath:indexPath];
    }
    else if ([tableView isEqual:self.tableViewPrivate]) {
        cell = [self tableView:tableView privateCellForRowAtIndexPath:indexPath];
    }
    else if ([tableView isEqual:self.tableViewSaved]) {
        cell = [self tableView:tableView savedCellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView twystedCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSInteger count = _arrayTwysted.count;
    if (count == 0) {
        HomeEmptyCell *emptyCell = (HomeEmptyCell*)[tableView dequeueReusableCellWithIdentifier:[HomeEmptyCell reuseIdentifier]];
        if (emptyCell == nil) {
            emptyCell = [[HomeEmptyCell alloc] init];
        }
        [emptyCell showEmptyHome:self selector:@selector(handleBtnEmptyCreateTouch:)];
        cell = emptyCell;
    }
    else {
        if (indexPath.row == _arrayTwysted.count) {
            cell = [self tableView:tableView loadingCellForRowAtIndexPath:indexPath];
        }
        else {
            HomeTwystCell *listCell = (HomeTwystCell*)[tableView dequeueReusableCellWithIdentifier:[HomeTwystCell reuseIdentifier]];
            if (listCell == nil) {
                listCell = [[HomeTwystCell alloc] init];
            }
            Twyst *twyst = [_arrayTwysted objectAtIndex:indexPath.row];
            [listCell configureCell:twyst];
            cell = listCell;
        }
    }
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView privateCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSInteger count = _arrayPrivate.count;
    if (count == 0) {
        HomeEmptyCell *emptyCell = (HomeEmptyCell*)[tableView dequeueReusableCellWithIdentifier:[HomeEmptyCell reuseIdentifier]];
        if (emptyCell == nil) {
            emptyCell = [[HomeEmptyCell alloc] init];
        }
        [emptyCell showEmptyDirect:self selector:@selector(handleBtnEmptyInviteTouch:)];
        cell = emptyCell;
    }
    else {
        if (indexPath.row == count) {
            cell = [self tableView:tableView loadingCellForRowAtIndexPath:indexPath];
        }
        else {
            HomeTwystCell *listCell = (HomeTwystCell*)[tableView dequeueReusableCellWithIdentifier:[HomeTwystCell reuseIdentifier]];
            if (listCell == nil) {
                listCell = [[HomeTwystCell alloc] init];
            }
            Twyst *twyst = [_arrayPrivate objectAtIndex:indexPath.row];
            [listCell configureCell:twyst];
            cell = listCell;
        }
    }
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView savedCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (_arraySaved.count == 0) {
        HomeEmptyCell *emptyCell = (HomeEmptyCell*)[tableView dequeueReusableCellWithIdentifier:[HomeEmptyCell reuseIdentifier]];
        if (emptyCell == nil) {
            emptyCell = [[HomeEmptyCell alloc] init];
        }
        [emptyCell showEmptySaved:self selector:@selector(handleBtnEmptyCreateTouch:)];
        cell = emptyCell;
    }
    else {
        HomeTwystCell *listCell = (HomeTwystCell*)[tableView dequeueReusableCellWithIdentifier:[HomeTwystCell reuseIdentifier]];
        if (listCell == nil) {
            listCell = [[HomeTwystCell alloc] init];
        }
        FFlipframeSavedLibrary *twyst = [_arraySaved objectAtIndex:indexPath.row];
        [listCell configureSavedCell:twyst];
        cell = listCell;
    }
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView loadingCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwystLoadingCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwystLoadingCell"];
        
        WDActivityIndicator *indicator = [[WDActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        indicator.indicatorStyle = WDActivityIndicatorStyleGradientPurple;
        [indicator startAnimating];
        [cell addSubview:indicator];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[HomeEmptyCell class]]) {
        if (_dataType == HomeDataTypeSaved) {
            [self actionSelectSavedTwyst:indexPath.row];
        }
        else {
            [self actionSelectTwyst:indexPath.row];
        }
    }
}

#pragma mark - show / hide feed loading
- (void)showLoadingView {
    self.loadingContainer.hidden = NO;
}

- (void)hideLoadingView {
    self.loadingContainer.hidden = YES;
}

#pragma mark - show / hide new twyst drop down
- (void)showNewTwystDropDown:(UIView*)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (view.hidden) {
            view.hidden = NO;
            
            CGFloat topBarHeight = UI_NEW_TOP_BAR_HEIGHT;
            CGRect frame = view.frame;
            [UIView animateWithDuration:0.2 animations:^{
                view.frame = CGRectMake(frame.origin.x,
                                        topBarHeight + 21,
                                        frame.size.width,
                                        frame.size.height);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    view.frame = CGRectMake(frame.origin.x,
                                            topBarHeight + 11,
                                            frame.size.width,
                                            frame.size.height);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        view.frame = CGRectMake(frame.origin.x,
                                                topBarHeight + 14,
                                                frame.size.width,
                                                frame.size.height);
                    }];
                }];
            }];
        }
    });
}

- (void)hideNewTwystDropDown:(UIView*)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!view.hidden) {
            CGRect frame = view.frame;
            [UIView animateWithDuration:0.2 animations:^{
                view.frame = CGRectMake(frame.origin.x,
                                        UI_NEW_TOP_BAR_HEIGHT - frame.size.height,
                                        frame.size.width,
                                        frame.size.height);
            } completion:^(BOOL finished) {
                view.hidden = YES;
            }];
        }
    });
}

#pragma mark - Notification service delegate
- (void)notificationDidReceive:(NSArray*)noteArray {
    NSLog(@"===== notification received =====\n%@", noteArray);
    for (NSDictionary *noteDic in noteArray) {
        NSString *type = [noteDic objectForKey:@"Type"];
        NSDictionary *twystDic = [noteDic objectForKey:@"Stringg"];
        Twyst *activeTwyst = [Twyst createNewTwystWithDictionary:twystDic];
        
        if ([type isEqualToString:@"deleted"]) {
            [self handleDeleteNotificationReceived:activeTwyst];
        }
        else if ([type isEqualToString:@"new twyst"] ||
                 [type isEqualToString:@"passed"]) {
            activeTwyst.PassedBy = [noteDic objectForKey:@"NoticeText"];
            [self handleCreateNotificationReceived:activeTwyst];
        }
        else if ([type isEqualToString:@"reply"]) {
            long senderId = [[noteDic objectForKey:@"SenderId"] longValue];
            long recieverId = [[noteDic objectForKey:@"RecieverId"] longValue];
            if (senderId != recieverId) {
                [self handleReplyNotificationReceived:activeTwyst];
            }
        }
    }
}

#pragma mark - add / remove / handle notification methods
- (void) addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDidCreate:)
                                                 name:kTwystDidCreateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDidReply:)
                                                 name:kTwystDidReplyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDidDelete:)
                                                 name:kTwystDidDeleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDidLeave:)
                                                 name:kTwystDidLeaveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLibraryItemDidChange:)
                                                 name:kLibraryItemDidSaveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLibraryItemDidChange:)
                                                 name:kLibraryItemDidDeleteNotification
                                               object:nil];
}

- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystDidCreateNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystDidReplyNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystDidDeleteNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystDidLeaveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLibraryItemDidSaveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLibraryItemDidDeleteNotification
                                                  object:nil];
}

- (void)handleTwystDidCreate:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    [self handleCreateNotificationReceived:twyst];
}

- (void)handleTwystDidReply:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    BOOL isNew = NO;
    if ([twyst.Visibility isEqualToString:@"private"]) {
        [self addTwystToDataSource:HomeDataTypePrivate twyst:twyst isAscending:YES isNew:&isNew];
    }
    else {
        [self addTwystToDataSource:HomeDataTypeTwysted twyst:twyst isAscending:YES isNew:&isNew];
    }
}

- (void)handleTwystDidDelete:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    [self handleDeleteNotificationReceived:twyst];
}

- (void)handleTwystDidLeave:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    [self handleDeleteNotificationReceived:twyst];
}

- (void)handleLibraryItemDidChange:(NSNotification*)notification {
    [self actionGetSaved];
}

#pragma mark -
- (void)handleDeleteNotificationReceived:(Twyst*)activeTwyst {
    if ([activeTwyst.Visibility isEqualToString:@"private"]) {
        NSInteger index = [self deleteTwystFromDataSource:HomeDataTypePrivate twyst:activeTwyst];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if ([self checkIfDeleteCellAnimate:HomeDataTypePrivate]) {
                [self deleteRows:@[indexPath] tableView:self.tableViewPrivate];
            }
            else {
                [self.tableViewPrivate reloadData];
            }
        }
    }
    else {
        NSInteger index = [self deleteTwystFromDataSource:HomeDataTypeTwysted twyst:activeTwyst];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if ([self checkIfDeleteCellAnimate:HomeDataTypeTwysted]) {
                [self deleteRows:@[indexPath] tableView:self.tableViewTwysted];
            }
            else {
                [self.tableViewTwysted reloadData];
            }
        }
    }
    
    // delete saved twyst and notifications
    TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:activeTwyst.Id];
    if (savedTwyst) {
        [[TSavedTwystManager sharedInstance] deleteSavedTwyst:savedTwyst];
    }
    [[TTwystNewsManager sharedInstance] deleteNewsWithTwystId:activeTwyst.Id];
}

- (void)handleCreateNotificationReceived:(Twyst*)activeTwyst {
    [_downloadService downloadTwyst:activeTwyst isUrgent:NO];
    
    BOOL isNew = NO;
    if ([activeTwyst.Visibility isEqualToString:@"private"]) {
        NSInteger index = [self addTwystToDataSource:HomeDataTypePrivate twyst:activeTwyst isAscending:YES isNew:&isNew];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if (isNew) {
                if ([self checkIfInsertCellAnimate:HomeDataTypePrivate]) {
                    [self insertRows:@[indexPath] tableView:self.tableViewPrivate];
                }
                else {
                    [self.tableViewPrivate reloadData];
                }
                
                // show new twyst dropdown
                if (self.tableViewPrivate.contentOffset.y > 30) {
                    [self showNewTwystDropDown:self.privateNewTwyst];
                    [[AppDelegate sharedInstance] setNewTwystBadge:YES];
                }
                
                if (_dataType != HomeDataTypePrivate && activeTwyst.ownerId != [Global getOCUser].Id) {
                    self.labelNewDirect.hidden = NO;
                    _newDirectCount ++;
                    self.labelNewDirect.text = [NSString stringWithFormat:@"%ld", (long)_newDirectCount];
                }
            }
            else {
                [self updateRow:indexPath tableView:self.tableViewPrivate twyst:activeTwyst];
            }
        }
    }
    else {
        NSInteger index = [self addTwystToDataSource:HomeDataTypeTwysted twyst:activeTwyst isAscending:YES isNew:&isNew];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if (isNew) {
                if ([self checkIfInsertCellAnimate:HomeDataTypeTwysted]) {
                    [self insertRows:@[indexPath] tableView:self.tableViewTwysted];
                }
                else {
                    [self.tableViewTwysted reloadData];
                }
                
                // show new twyst dropdown
                if (self.tableViewTwysted.contentOffset.y > 30) {
                    [self showNewTwystDropDown:self.twystedNewTwyst];
                    [[AppDelegate sharedInstance] setNewTwystBadge:YES];
                }
            }
            else {
                [self updateRow:indexPath tableView:self.tableViewTwysted twyst:activeTwyst];
            }
        }
    }
}

- (void)handleReplyNotificationReceived:(Twyst*)activeTwyst {
    TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:activeTwyst.Id];
    if (savedTwyst) {
        savedTwyst.isUnread = [NSNumber numberWithBool:YES];
        [[TSavedTwystManager sharedInstance] saveObject:savedTwyst];
    }
    
    BOOL isNew = NO;
    if ([activeTwyst.Visibility isEqualToString:@"private"]) {
        NSInteger index = [self addTwystToDataSource:HomeDataTypePrivate twyst:activeTwyst isAscending:YES isNew:&isNew];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if (isNew) {
                if ([self checkIfInsertCellAnimate:HomeDataTypePrivate]) {
                    [self insertRows:@[indexPath] tableView:self.tableViewPrivate];
                }
                else {
                    [self.tableViewPrivate reloadData];
                }
            }
            else {
                [self updateRow:indexPath tableView:self.tableViewPrivate twyst:activeTwyst];
            }
        }
    }
    else {
        NSInteger index = [self addTwystToDataSource:HomeDataTypeTwysted twyst:activeTwyst isAscending:YES isNew:&isNew];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            if (isNew) {
                if ([self checkIfInsertCellAnimate:HomeDataTypeTwysted]) {
                    [self insertRows:@[indexPath] tableView:self.tableViewTwysted];
                }
                else {
                    [self.tableViewTwysted reloadData];
                }
            }
            else {
                [self updateRow:indexPath tableView:self.tableViewTwysted twyst:activeTwyst];
            }
        }
    }
}

- (BOOL)checkIfInsertCellAnimate:(HomeDataType)type {
    if (type == HomeDataTypePrivate) {
        return (_arrayPrivate.count > 1);
    }
    else if (type == HomeDataTypeTwysted) {
        return (_arrayTwysted.count > 1);
    }
    return NO;
}

- (BOOL)checkIfDeleteCellAnimate:(HomeDataType)type {
    if (type == HomeDataTypePrivate) {
        return (_arrayPrivate.count > 0);
    }
    else if (type == HomeDataTypeTwysted) {
        return (_arrayTwysted.count > 0);
    }
    return NO;
}

#pragma mark -
- (void)insertRows:(NSArray*)rows tableView:(UITableView*)tableView {
    if (_isTopScreen) {
//        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
//        [tableView endUpdates];
    }
    else {
        [tableView reloadData];
    }
}

- (void)deleteRows:(NSArray*)rows tableView:(UITableView*)tableView {
    if (_isTopScreen) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
    else {
        [tableView reloadData];
    }
}

- (void)updateRow:(NSIndexPath*)indexPath tableView:(UITableView*)tableView twyst:(Twyst*)twyst {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HomeTwystCell class]]) {
        [(HomeTwystCell*)cell updateCell:twyst];
    }
}

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource:(EGORefreshTableHeaderView*)view {
	_reloading = YES;
}

- (void)doneLoadingTableViewData {
	_reloading = NO;
    [_refreshViewPrivate egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableViewPrivate];
    [_refreshViewTwysted egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableViewTwysted];
    [_refreshViewSaved egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableViewSaved];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    if ([scrollView isEqual:self.scrollView]) {
        if (contentOffset.x < 0) {
            contentOffset.x = 0;
            [self.scrollView setContentOffset:contentOffset];
        }
        else if (contentOffset.x > SCREEN_WIDTH * 2) {
            contentOffset.x = SCREEN_WIDTH * 2;
            [self.scrollView setContentOffset:contentOffset];
        }
        
        [self updateHeaders];
    }
    if ([scrollView isEqual:self.tableViewPrivate]) {
        [_refreshViewPrivate egoRefreshScrollViewDidScroll:scrollView];
        [self hideNewTwystDropDown:self.privateNewTwyst];
        if (contentOffset.y <= 0) {
            [[AppDelegate sharedInstance] setNewTwystBadge:NO];
        }
        [self scrollViewDidReachBottom:self.tableViewPrivate];
    }
    else if ([scrollView isEqual:self.tableViewTwysted]) {
        [_refreshViewTwysted egoRefreshScrollViewDidScroll:scrollView];
        [self hideNewTwystDropDown:self.twystedNewTwyst];
        if (contentOffset.y <= 0) {
            [[AppDelegate sharedInstance] setNewTwystBadge:NO];
        }
        [self scrollViewDidReachBottom:self.tableViewTwysted];
    }
    else if ([scrollView isEqual:self.tableViewSaved]) {
        [_refreshViewSaved egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.scrollView]) {
        [self handleDidScrollEnded];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *) scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:self.scrollView]) {
        if (!decelerate) {
            [self handleDidScrollEnded];
        }
    }
    else if ([scrollView isEqual:self.tableViewPrivate]) {
        [_refreshViewPrivate egoRefreshScrollViewDidEndDragging:scrollView];
    }
    else if ([scrollView isEqual:self.tableViewTwysted]) {
        [_refreshViewTwysted egoRefreshScrollViewDidEndDragging:scrollView];
    }
    else if ([scrollView isEqual:self.tableViewSaved]) {
        [_refreshViewSaved egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.scrollView]) {
        [self handleDidScrollEnded];
    }
}

- (void)handleDidScrollEnded {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGPoint contentOffset = self.scrollView.contentOffset;
    if (contentOffset.x < bounds.size.width / 2) {
        contentOffset.x = 0;
    }
    else if (contentOffset.x < bounds.size.width * 3 / 2) {
        contentOffset.x = bounds.size.width;
    }
    else {
        contentOffset.x = bounds.size.width * 2;
    }
    [self.scrollView setContentOffset:contentOffset];
    
    _dataType = HomeDataTypeNone;
    if (contentOffset.x == 0) {
        _dataType = HomeDataTypePrivate;
        if (_arrayPrivate == nil) {
            [self reloadContent:HomeDataTypePrivate forced:YES];
        }
    }
    else if (contentOffset.x == SCREEN_WIDTH) {
        _dataType = HomeDataTypeTwysted;
    }
    else if (contentOffset.x == SCREEN_WIDTH * 2) {
        _dataType = HomeDataTypeSaved;
        if (_arraySaved == nil) {
            [self reloadContent:HomeDataTypeSaved forced:YES];
        }
    }
}

- (void)scrollViewDidReachBottom:(UIScrollView*)scrollView {
    CGFloat bottomInset = scrollView.contentInset.bottom;
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height - bottomInset;
    if (bottomEdge == scrollView.contentSize.height) {
        NSLog(@"--- scroll view reaches to the bottom ---");
        if ([scrollView isEqual:self.tableViewTwysted]) {
            if (_startTime) {
                [self loadMoreContent:_dataType];
            }
        }
        else if ([scrollView isEqual:self.tableViewPrivate]) {
            if (_startIndex && !_isPrivateLoadFailed) {
                [self loadMoreContent:_dataType];
            }
        }
    }
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource:view];
    [self reloadContent:_dataType forced:YES];
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

#pragma mark - Headers

- (void)updateHeaders {
    CGFloat offset = self.scrollView.contentOffset.x;
    CGFloat screenWidth = SCREEN_WIDTH;
    
    CGFloat directHeaderAlpha = ((screenWidth - offset)/screenWidth);
    directHeaderAlpha = fmaxf(0.0, fminf(1.0, directHeaderAlpha));
    
    CGFloat homeHeaderAlpha = offset <= screenWidth ? (offset/screenWidth) : (((2.0*screenWidth) - offset) /screenWidth);
    homeHeaderAlpha = fmaxf(0.0, fminf(1.0, homeHeaderAlpha));
    
    CGFloat savedHeaderAlpha = (offset - screenWidth)/screenWidth;
    savedHeaderAlpha = fmaxf(0.0, fminf(1.0, savedHeaderAlpha));
    
    self.directHeaderView.alpha = powf(directHeaderAlpha, 4);
    self.homeHeaderView.alpha = powf(homeHeaderAlpha, 4);
    self.savedHeaderView.alpha = powf(savedHeaderAlpha, 4);

    self.directHeaderView.hidden = directHeaderAlpha == 0;
    self.homeHeaderView.hidden = homeHeaderAlpha == 0;
    self.savedHeaderView.hidden = savedHeaderAlpha == 0;
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
    [self removeNotifications];
}

@end
