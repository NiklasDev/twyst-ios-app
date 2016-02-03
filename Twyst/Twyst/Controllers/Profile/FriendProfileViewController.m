//
//  FriendProfileViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 4/17/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "TTwystOwnerManager.h"
#import "TSavedTwystManager.h"

#import "PhotoHelper.h"
#import "UserWebService.h"
#import "FriendManageService.h"
#import "FlipframeFileService.h"
#import "TwystDownloadService.h"

#import "WDActivityIndicator.h"
#import "FullProfileImageView.h"
#import "CircleProcessingView.h"

#import "ExtraTagButton.h"
#import "ProfileFeedCell.h"
#import "ProfileEmptyCell.h"

#import "TwystPreviewController.h"
#import "FriendProfileViewController.h"

@interface FriendProfileViewController () <UIActionSheetDelegate> {
    UserRelationType _relationShip;
    
    UserWebService *_webService;
    FlipframeFileService *_fileService;
    TwystDownloadService *_downloadService;
    
    UITapGestureRecognizer *_tapGestureAvatar;
    
    BOOL _isLoading;
    NSArray *_dataSource;
    
//
    CGRect _frameAction;
    CGRect _frameDecline;
}

@property (nonatomic, strong) UIButton *btnAction;
@property (nonatomic, strong) UIButton *btnDecline;

@end

@implementation FriendProfileViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addTapGestures];
    [self loadCoverPicture];
    [self loadProfilePicture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadSubHeaderView];
    
    if (self.user.PrivateProfile && _relationShip != UserRelationTypeFriend) {
        [self.tableView reloadData];
    }
    else {
        [self actionLoadTwysts];
    }
}

#pragma mark - override methods
- (void)initMembers {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            self.headerHeight = 129.0;
            self.avatarImageSize = 81;
            self.avatarImageCompressedSize = 44;
            self.avatarOffsetY = 52;
            self.avatarOffsetX = 10;
            self.nameOffsetX = 15;
            self.realNameOffsetY = 57;
            self.userNameOffsetY = 81;
            self.realNameFontSize = 18.6;
            self.userNameFontSize = 13;
            self.bioOffsetY = 105;
            self.bioFontSize = 15;
            
            _frameAction = CGRectMake(307.5, 6, 60, 40);
            _frameDecline = CGRectMake(253, 6, 60, 40);
            break;
            
        case DeviceTypePhone6Plus:
            self.headerHeight = 142.0;
            self.avatarImageSize = 90;
            self.avatarImageCompressedSize = 50;
            self.avatarOffsetY = 59;
            self.avatarOffsetX = 11;
            self.nameOffsetX = 17;
            self.realNameOffsetY = 64;
            self.userNameOffsetY = 91;
            self.realNameFontSize = 20.8;
            self.userNameFontSize = 14;
            self.bioOffsetY = 117;
            self.bioFontSize = 16.4;
            
            _frameAction = CGRectMake(343, 9, 60, 40);
            _frameDecline = CGRectMake(280, 9, 60, 40);
            break;
            
        default:
            self.headerHeight = 110.0;
            self.avatarImageSize = 70;
            self.avatarImageCompressedSize = 40;
            self.avatarOffsetY = 45.5;
            self.avatarOffsetX = 8;
            self.nameOffsetX = 13;
            self.realNameOffsetY = 48.5;
            self.userNameOffsetY = 69;
            self.realNameFontSize = 16.6;
            self.userNameFontSize = 12.6;
            self.bioOffsetY = 90;
            self.bioFontSize = 13.4;
            
            _frameAction = CGRectMake(258, 2, 60, 40);
            _frameDecline = CGRectMake(210, 2, 60, 40);
            break;
    }
    
    // change subheader height according bio
    if (IsNSStringValid(self.user.Bio)) {
        CGSize bioSize = [self.user.Bio stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:self.bioFontSize] lineSpace:4 constrainedToWidth:SCREEN_WIDTH - self.nameOffsetX * 2];
        self.subHeaderHeight = self.bioOffsetY + bioSize.height + self.bioFontSize;
    }
    else {
        self.subHeaderHeight = self.bioOffsetY + self.bioFontSize / 2;
    }
    
    self.barIsCollapsed = false;
    self.barAnimationComplete = false;
    
    _webService = [UserWebService sharedInstance];
    _fileService = [FlipframeFileService sharedInstance];
    _downloadService = [TwystDownloadService sharedInstance];
}

- (void)configureNavBar {
    [super configureNavBar];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(0, 0, 50, 40);
    [btnBack setImage:[UIImage imageNamedForDevice:@"btn-profile-back-on"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamedForDevice:@"btn-profile-back-hl"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(handleBtnBackTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
}

- (UIView*) createSubHeaderView {
    UIView* view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self.view;
    
    UILabel* realNameLabel = [UILabel new];
    realNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    realNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.FirstName, self.user.LastName];
    realNameLabel.textColor = Color(49, 47, 60);
    [realNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:self.realNameFontSize]];
    views[@"realNameLabel"] = realNameLabel;
    [view addSubview:realNameLabel];
    self.labelRealname = realNameLabel;
    
    UILabel* userNameLabel = [UILabel new];
    userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    userNameLabel.text = self.user.UserName;
    userNameLabel.textColor = Color(74, 71, 90);
    [userNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.userNameFontSize]];
    views[@"userNameLabel"] = userNameLabel;
    [view addSubview:userNameLabel];
    self.labelUsername = userNameLabel;
    
    UILabel* bioLabel = [UILabel new];
    bioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if (IsNSStringValid(self.user.Bio)) {
        bioLabel.attributedText = [NSString formattedString:@[self.user.Bio] fonts:@[[UIFont fontWithName:@"HelveticaNeue" size:self.bioFontSize]] colors:nil lineSpace:4];
    }
    bioLabel.textColor = Color(49, 47, 60);
    bioLabel.numberOfLines = 0;
    views[@"bioLabel"] = bioLabel;
    [view addSubview:bioLabel];
    self.labelBio = bioLabel;
    
    self.btnAction = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAction.frame = _frameAction;
    [self.btnAction addTarget:self action:@selector(handleBtnActionTouch:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnAction];
    
    self.btnDecline = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDecline.frame = _frameDecline;
    [self.btnDecline setImage:[UIImage imageNamedForDevice:@"btn-friend-profile-decline"] forState:UIControlStateNormal];
    [self.btnDecline addTarget:self action:@selector(handleBtnDeclineTouch:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnDecline];
    
    NSArray* constraints;
    NSString* format;
    
    format = [NSString stringWithFormat:@"|-%.0f-[realNameLabel]", self.nameOffsetX];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"V:|-%.0f-[realNameLabel]", self.realNameOffsetY];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"|-%.0f-[userNameLabel]", self.nameOffsetX];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"V:|-%.0f-[userNameLabel]", self.userNameOffsetY];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"|-%.0f-[bioLabel]-%.0f-|", self.nameOffsetX, self.nameOffsetX];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = [NSString stringWithFormat:@"V:|-%.0f-[bioLabel]", self.bioOffsetY];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    return view;
}

- (void)reloadSubHeaderView {
    
    NSNumber *userId = [NSNumber numberWithLong:self.user.Id];
    _relationShip = [[FriendManageService sharedInstance] getUserRelationTypeShip:userId];
    
    [self.activityView setActivities:self.user relation:_relationShip];
    
    switch (_relationShip) {
        case UserRelationTypeNone:
        {
            [self.btnAction setImage:[UIImage imageNamedForDevice:@"btn-friend-profile-follow"] forState:UIControlStateNormal];
            self.btnDecline.hidden = YES;
        }
            break;
        case UserRelationTypeFriend:
        {
            [self.btnAction setImage:[UIImage imageNamedForDevice:@"btn-friend-profile-following"] forState:UIControlStateNormal];
            self.btnDecline.hidden = YES;
        }
            break;
        case UserRelationTypeRequested:
        {
            [self.btnAction setImage:[UIImage imageNamedForDevice:@"btn-friend-profile-pending"] forState:UIControlStateNormal];
            self.btnDecline.hidden = YES;
        }
            break;
        case UserRelationTypeReceived:
        {
            [self.btnAction setImage:[UIImage imageNamedForDevice:@"btn-friend-profile-following"] forState:UIControlStateNormal];
            self.btnDecline.hidden = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - internal methods
- (void)addTapGestures {
    _tapGestureAvatar = [UITapGestureRecognizer new];
    [_tapGestureAvatar addTarget:self action:@selector(handleTapAvatar:)];
    self.imageAvatar.userInteractionEnabled = YES;
    [self.imageAvatar addGestureRecognizer:_tapGestureAvatar];
}

- (void)removeTapGestures {
    [self.imageAvatar removeGestureRecognizer:_tapGestureAvatar];
}

#pragma mark - reload content
- (void)actionLoadTwysts {
    if (self.currentTab == ProfileTabCreated) {
        if (self.arrayCreatedTwysts.count) {
            _dataSource = self.arrayCreatedTwysts;
            [self.tableView reloadData];
        }
        else {
            [self actionLoadCreatedTwysts];
        }
    }
    else if (self.currentTab == ProfileTabLiked) {
        if (self.arrayLikedTwysts.count) {
            _dataSource = self.arrayLikedTwysts;
            [self.tableView reloadData];
        }
        else {
            [self actionLoadLikedTwysts];
        }
    }
}

- (void)actionLoadMoreTwysts {
    if (!_isLoading) {
        if (self.currentTab == ProfileTabCreated) {
            [self actionLoadCreatedTwysts];
        }
        else if (self.currentTab == ProfileTabLiked) {
            [self actionLoadLikedTwysts];
        }
    }
}

- (void)actionLoadCreatedTwysts {
    if (self.isAllLoaded == NO) {

        _isLoading = YES;
        [self.tableView reloadData];
        
        [[UserWebService sharedInstance] getFriendProfile:self.user.Id start:self.loadStartIndex completion:^(NSDictionary *friendInfo) {
            
            _isLoading = NO;
            if ([friendInfo isKindOfClass:[NSDictionary class]]) {
                NSArray *friendTwysts = [friendInfo objectForKey:@"stringgs"];
                if (friendTwysts) {
                    NSMutableArray *twysts = [NSMutableArray new];
                    for (NSDictionary *twystDic in friendTwysts) {
                        Twyst *twyst = [Twyst createNewTwystWithDictionary:twystDic];
                        [twysts addObject:twyst];
                    }
                    [self.arrayCreatedTwysts addObjectsFromArray:twysts];
                    self.loadStartIndex = self.arrayCreatedTwysts.count;
                    if (friendTwysts.count < DEF_HOME_FEED_BUNCH) {
                        self.isAllLoaded = YES;
                    }
                    _dataSource = self.arrayCreatedTwysts;
                }
            }
            else {
                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
            }
            [self.tableView reloadData];
        }];
    }
}

- (void)actionLoadLikedTwysts {
    if (self.isAllLoaded == NO) {
        
        _isLoading = YES;
        [self.tableView reloadData];
        
        [[UserWebService sharedInstance] getUserLikedTwysts:self.user.Id start:self.loadStartIndex completion:^(NSArray *likedTwysts) {
            
            _isLoading = NO;
            if (likedTwysts) {
                [self.arrayLikedTwysts addObjectsFromArray:likedTwysts];
                self.loadStartIndex = self.arrayLikedTwysts.count;
                if (likedTwysts.count < DEF_HOME_FEED_BUNCH) {
                    self.isAllLoaded = YES;
                }
                _dataSource = self.arrayLikedTwysts;
            }
            else {
                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
            }
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - friend manage methods
- (void)actionRemoveRequest {
    FriendManageService *friendService = [FriendManageService sharedInstance];
    NSString *requestId = [friendService sentRequestId:self.user.Id];
    if (requestId) {
        [CircleProcessingView showInView:self.view];
        [friendService cancelRequest:requestId completion:^(BOOL isSuccess) {
            [CircleProcessingView hide];
            if (isSuccess) {
                [self reloadSubHeaderView];
            }
            else {
                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
            }
        }];
    }
}

- (void)actionSendRequest {
    FriendManageService *friendService = [FriendManageService sharedInstance];
    NSString *friendId = [NSString stringWithFormat:@"%ld", self.user.Id];
    [CircleProcessingView showInView:self.view];
    [friendService requesetFriend:friendId completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            [self reloadSubHeaderView];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

- (void)actionUnfriend {
    FriendManageService *friendService = [FriendManageService sharedInstance];
    NSString *requestId = [friendService friendshipId:self.user.Id];
    [CircleProcessingView showInView:self.view];
    [friendService removeFriend:requestId completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            [self reloadSubHeaderView];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

- (void)actionAcceptRequest {
    FriendManageService *friendService = [FriendManageService sharedInstance];
    NSString *requestId = [friendService receivedRequestId:self.user.Id];
    [CircleProcessingView showInView:self.view];
    [friendService acceptRequest:requestId completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            [self reloadSubHeaderView];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

- (void)actionDeclineRequest {
    FriendManageService *friendService = [FriendManageService sharedInstance];
    NSString *requestId = [friendService receivedRequestId:self.user.Id];
    [CircleProcessingView showInView:self.view];
    [friendService declineRequest:requestId completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            [self reloadSubHeaderView];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

#pragma mark - handle button methods
- (void)handleBtnBackTouch:(UIButton*)sender {
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTapAvatar:(UITapGestureRecognizer*)sender {
    if (IsNSStringValid(self.user.ProfilePicName)) {
        FullProfileImageView *fullImageView = [[FullProfileImageView alloc] initWithProfileName:self.user.ProfilePicName];
        [fullImageView showInView:[AppDelegate sharedInstance].window];
    }
}

- (void)handleBtnActionTouch:(id)sender {
    switch (_relationShip) {
        case UserRelationTypeNone:
            if (self.user.PrivateProfile) {
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
            break;
        case UserRelationTypeFriend:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:@"Remove"
                                                            otherButtonTitles:nil];
            actionSheet.tag = SlideUpTypeUnfriend;
            [actionSheet showFromTabBar:[AppDelegate sharedInstance].tabBarController.tabBar];
        }
            break;
        case UserRelationTypeRequested:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:@"Remove"
                                                            otherButtonTitles:nil];
            actionSheet.tag = SlideUpTypeCancelRequest;
            [actionSheet showFromTabBar:[AppDelegate sharedInstance].tabBarController.tabBar];
        }
            break;
        case UserRelationTypeReceived:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Accept", nil];
            actionSheet.tag = SlideUpTypeAcceptFriend;
            [actionSheet showFromTabBar:[AppDelegate sharedInstance].tabBarController.tabBar];
        }
            break;
        default:
            break;
    }
}

- (void)handleBtnDeclineTouch:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Decline"
                                                    otherButtonTitles:nil];
    actionSheet.tag = SlideUpTypeDeclineFriend;
    [actionSheet showFromTabBar:[AppDelegate sharedInstance].tabBarController.tabBar];
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
    else if (actionSheet.tag == SlideUpTypeAcceptFriend) {
        if (buttonIndex == 0) {
            [self actionAcceptRequest];
        }
    }
    else if (actionSheet.tag == SlideUpTypeDeclineFriend) {
        if (buttonIndex == 0) {
            [self actionDeclineRequest];
        }
    }
    else if (actionSheet.tag == SlideUpTypeCancelRequest) {
        if (buttonIndex == 0) {
            [self actionRemoveRequest];
        }
    }
}

#pragma mark - load profile / cover image
- (void)loadProfilePicture {
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-profile-avatar"];
    __weak typeof(self) weakSelf = self;
    [self.imageAvatar setImageWithURL:ProfileURL(self.user.ProfilePicName) placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            weakSelf.imageAvatar.image = [PhotoHelper cropCircleImage:image size:weakSelf.imageAvatar.frame.size];
        }
    }];
}

- (void)loadCoverPicture {
    UIImage *placeholder = [UIImage imageNamedForDevice:@"ic-friend-profile-default-cover"];
    [self setOriginCoverImage:placeholder];
    
    if (IsNSStringValid(self.user.CoverPhoto)) {
        __weak typeof(self) weakSelf = self;
        [self.imageCover setImageWithURL:ProfileURL(self.user.CoverPhoto) placeholderImage:placeholder options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                [weakSelf setOriginCoverImage:image];
            }
        }];
    }
    else {
        self.imageCover.image = placeholder;
    }
}

#pragma mark - table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = _dataSource.count;
    if (count == 0) {
        return 1;
    }
    else {
        if (self.isAllLoaded) {
            return count / 2 + count % 2;
        }
        else {
            return count / 2 + count % 2 + 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = _dataSource.count;
    if (count == 0) {
        return [ProfileEmptyCell heightForCell:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
    }
    else {
        if (indexPath.row == (count + 1) / 2) {
            return 44;
        }
        else {
            return [ProfileFeedCell heightForCell];
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = _dataSource.count;
    if (count == 0) {
        ProfileEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:[ProfileEmptyCell reuseIdentifier]];
        if (cell == nil) {
            cell = [[ProfileEmptyCell alloc] init];
        }
        
        if (_isLoading) {
            [cell showProfileLoading:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
        }
        else {
            if (self.user.PrivateProfile) {
                [cell showFriendPrivate:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
            }
            else {
                [cell showFriendNoPosts:self.headerHeight + self.subHeaderHeight + [ProfileActivityView heightForView]];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        UITableViewCell *cell = nil;
        if (indexPath.row >= (count + 1) / 2) {
            cell = [self tableView:tableView loadingCellForRowAtIndexPath:indexPath];
        }
        else {
            ProfileFeedCell *feedCell = [tableView dequeueReusableCellWithIdentifier:[ProfileFeedCell reuseIdentifier]];
            if (feedCell == nil) {
                feedCell = [[ProfileFeedCell alloc] initWithTarget:self selector:@selector(handleFeedCellTouch:)];
            }
            
            NSInteger leftIndex = indexPath.row * 2;
            Twyst *leftTwyst = (leftIndex < _dataSource.count) ? [_dataSource objectAtIndex:leftIndex] : nil;
            
            NSInteger rightIndex = indexPath.row * 2 + 1;
            Twyst *rightTwyst = (rightIndex < _dataSource.count) ? [_dataSource objectAtIndex:rightIndex] : nil;
            
            [feedCell configureCell:leftTwyst leftIndex:leftIndex rightTwyst:rightTwyst rightIndex:rightIndex];
            cell = feedCell;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView loadingCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwystLoadingCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwystLoadingCell"];
        cell.backgroundColor = [UIColor clearColor];
        
        WDActivityIndicator *indicator = [[WDActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        indicator.indicatorStyle = WDActivityIndicatorStyleGradientPurple;
        [indicator startAnimating];
        [cell addSubview:indicator];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)handleFeedCellTouch:(ExtraTagButton*)sender {
    NSInteger index = sender.extraTag;
    [self actionSelectTwyst:index];
}

#pragma mark - show stringg preview
- (void)actionSelectTwyst:(NSInteger)index {
    Twyst *twyst = [_dataSource objectAtIndex:index];
    [self actionGotoPreview:twyst];
}

- (void)actionGotoPreview:(Twyst*)twyst {
    TwystPreviewController *viewController = [[TwystPreviewController alloc] init];
    viewController.twyst = twyst;
    viewController.isFriendTwyst = YES;
    [self showPreviewController:viewController];
}

- (void)showPreviewController:(PreviewBaseViewController*)viewController {
    UINavigationController * navVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    navVC.navigationBarHidden = YES;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    [self profileDidScroll:scrollView];
    
    CGFloat bottomInset = scrollView.contentInset.bottom;
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height - bottomInset;
    if ((NSInteger)bottomEdge == (NSInteger)scrollView.contentSize.height) {
        NSLog(@"--- scroll view reaches to the bottom ---");
        if (self.loadStartIndex) {
            [self actionLoadMoreTwysts];
        }
    }
}

#pragma mark - status bar hidden
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [self removeTapGestures];
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
