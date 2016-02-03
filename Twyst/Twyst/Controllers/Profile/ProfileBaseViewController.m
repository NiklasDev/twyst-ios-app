//
//  ProfileBaseViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 4/17/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImage+ImageEffects.h"

#import "PhotoHelper.h"
#import "AppDelegate.h"
#import "WrongMessageView.h"
#import "ContactManageService.h"

#import "FollowersViewController.h"
#import "FollowingViewController.h"
#import "ProfileBaseViewController.h"

@interface ProfileBaseViewController() <ProfileActivityDelegate, UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, strong) UIView *customTitleView;
@property (nonatomic, strong) UIImageView *imageTitleCover;

@end

@implementation ProfileBaseViewController

- (id)init {
    self = [super init];
    if (self) {
        self.currentTab = ProfileTabCreated;
        self.arrayCreatedTwysts = [NSMutableArray new];
        self.arrayLikedTwysts = [NSMutableArray new];
        
        self.loadStartIndex = 0;
        self.isAllLoaded = NO;
        self.dicLoadStatus = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMembers];
    
    [self addActivityIndicator];
    
    [self configureNavBar];
    
    [self addTableView];
    
    [self addTableHeaderView];
    
    [self initActivityView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fillBlurredImageCache];
    });
    
    [self addTitleView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.needToReload) {
        self.needToReload = NO;
        [self refreshTableHeaderView];
    }
}

- (void)addActivityIndicator {
    _activityIndicator = [[WDActivityIndicator alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, 30, 21, 21)];
    _activityIndicator.indicatorStyle = WDActivityIndicatorStyleGradientPurple;
    [[AppDelegate sharedInstance].window addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    _activityIndicator.hidden = YES;
}

- (void)addTableView {
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    tableView.delaysContentTouches = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = Color(231, 230, 236);
    self.tableView = tableView;
    [self.view addSubview:tableView];
}

- (void)addTableHeaderView {
    
    self.tableView.tableHeaderView = nil;
//    [self.view removeConstraints:self.view.constraints];
    
    UIApplication* sharedApplication = [UIApplication sharedApplication];
    CGFloat kStatusBarHeight = sharedApplication.statusBarFrame.size.height;
    CGFloat kNavBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    _headerSwitchOffset = _headerHeight - /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight)  - kStatusBarHeight - kNavBarHeight;
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self.view;
    
    views[@"tableView"] = self.tableView;
    
    UIImage* defaultCoverImage = [UIImage imageNamedForDevice:@"ic-friend-profile-default-cover"];
    _originCoverImage = defaultCoverImage;
    
    UIImageView* coverImageView = [[UIImageView alloc] initWithImage:defaultCoverImage];
    coverImageView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    coverImageView.clipsToBounds = true;
    self.imageCover = coverImageView;
    views[@"headerImageView"] = coverImageView;
    
    /* Not using autolayout for this one, because i don't really have control on how the table view is setting up the items.*/
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                                       _headerHeight - /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) + _subHeaderHeight)];
    [tableHeaderView addSubview:coverImageView];
    
    UIView* subHeaderPart = [self createSubHeaderView];
    subHeaderPart.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    [tableHeaderView insertSubview:subHeaderPart belowSubview:coverImageView];
    views[@"subHeaderPart"] = subHeaderPart;
    
    
    
    [self.tableView setTableHeaderView:tableHeaderView];
    
    
    
    UIView* avatarImageView = [self createAvatarImage];
    avatarImageView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    views[@"avatarImageView"] = avatarImageView;
    [tableHeaderView addSubview:avatarImageView];
    
    /*
     * At this point tableHeader views are ordered like this:
     * 0 : subHeaderPart
     * 1 : headerImageView
     * 2 : avatarImageView
     */
    
    /* This is important, or section header will 'overlaps' the navbar */
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    
    //Now Let's do the layout
    NSArray* constraints;
    NSLayoutConstraint* constraint;
    NSString* format;
    NSDictionary* metrics = @{
                              @"headerHeight" : [NSNumber numberWithFloat:_headerHeight- /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) ],
                              @"minHeaderHeight" : [NSNumber numberWithFloat:(kStatusBarHeight + kNavBarHeight)],
                              @"avatarSize" :[NSNumber numberWithFloat:_avatarImageSize],
                              @"avatarCompressedSize" :[NSNumber numberWithFloat:_avatarImageCompressedSize],
                              @"subHeaderHeight" :[NSNumber numberWithFloat:_subHeaderHeight],
                              };
    
    // ===== Table view should take all available space ========
    
    format = @"|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    format = @"V:|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    
    
    // ===== Header image view should take all available width ========
    
    format = @"|-0-[headerImageView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    format = @"|-0-[subHeaderPart]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    
    // ===== Header image view should not be smaller than nav bar and stay below navbar ========
    
    format = @"V:[headerImageView(>=minHeaderHeight)]-(subHeaderHeight@750)-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    format = @"V:|-(headerHeight)-[subHeaderPart(subHeaderHeight)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    // ===== Header image view should stick to top of the 'screen'  ========
    
    NSLayoutConstraint* magicConstraint = [NSLayoutConstraint constraintWithItem:coverImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0];
    [self.view addConstraint: magicConstraint];
    
    
    
    // ===== avatar should stick to left with default margin spacing  ========
    CGFloat offsetx = SCREEN_WIDTH / 2 - self.avatarOffsetX - self.avatarImageSize / 2;
    NSLayoutConstraint *centerXConstraint =
    [NSLayoutConstraint constraintWithItem:avatarImageView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:tableHeaderView
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:-offsetx];
    [self.view addConstraint:centerXConstraint];
    
    // === avatar is square
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:avatarImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0];
    [self.view addConstraint: constraint];
    
    
    // ===== avatar size can be between avatarSize and avatarCompressedSize
    format = @"V:[avatarImageView(<=avatarSize@760,>=avatarCompressedSize@800)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:(kStatusBarHeight + kNavBarHeight)];
    constraint.priority = 790;
    [self.view addConstraint: constraint];
    
    
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:subHeaderPart attribute:NSLayoutAttributeTop multiplier:1.0f constant:self.avatarOffsetY];
    constraint.priority = 801;
    [self.view addConstraint: constraint];
}

- (void)initActivityView {
    if (!self.activityView) {
        self.activityView = [[ProfileActivityView alloc] init];
        self.activityView.delegate = self;
    }
}

- (void)refreshTableHeaderView {
    [self initMembers];
    [self addTableHeaderView];
}

#pragma mark - Table view data source
- (CGFloat)tableView:tableView heightForHeaderInSection:(NSInteger)section {
    return [ProfileActivityView heightForView];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.activityView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark -

- (void) configureNavBar {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self switchToExpandedHeader];
}

- (void)switchToExpandedHeader {
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = nil;
    
    _barAnimationComplete = false;
    self.imageCover.image = self.originCoverImage;
    self.imageTitleCover.image = nil;
    
    //Inverse Z-Order of avatar Image view
    [self.tableView.tableHeaderView exchangeSubviewAtIndex:2 withSubviewAtIndex:1];
    
    self.customTitleView.frame = CGRectMake(0, 64, SCREEN_WIDTH, 44);
}

- (void)switchToMinifiedHeader {
    _barAnimationComplete = false;
    
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    //Setting the view transform or changing frame origin has no effect, only this call does
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:60 forBarMetrics:UIBarMetricsDefault];
    
    //Inverse Z-Order of avatar Image view
    [self.tableView.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
}


#pragma mark - UIScrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self profileDidScroll:scrollView];
}

- (void)profileDidScroll:(UIScrollView*)scrollView {
    CGFloat yPos = scrollView.contentOffset.y;
    if (yPos > _headerSwitchOffset && !_barIsCollapsed) {
        [self switchToMinifiedHeader];
        _barIsCollapsed = true;
    } else if (yPos < _headerSwitchOffset && _barIsCollapsed) {
        [self switchToExpandedHeader];
        _barIsCollapsed = false;
    }
    
    //appologies for the magic numbers
    if (yPos > _headerSwitchOffset +self.realNameOffsetY && yPos <= _headerSwitchOffset +40 +self.realNameOffsetY){
        CGFloat delta = (40 - (yPos-_headerSwitchOffset) +self.realNameOffsetY);
        self.customTitleView.frame = CGRectMake(0, 22 + delta, SCREEN_WIDTH, 44);
        self.imageTitleCover.image = [self blurWithImageAt:((60-delta)/60.0)];
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:delta forBarMetrics:UIBarMetricsDefault];
    }
    
    if(!_barAnimationComplete && yPos > _headerSwitchOffset +40 +self.realNameOffsetY) {
        self.customTitleView.frame = CGRectMake(0, 20, SCREEN_WIDTH, 44);
        self.imageTitleCover.image = [self blurWithImageAt:1.0];
        _barAnimationComplete = true;
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)saveLoadStatus {
    NSDictionary *dicStatus = @{@"startIndex":[NSNumber numberWithInteger:self.loadStartIndex],
                                @"isAllLoaded":[NSNumber numberWithBool:self.isAllLoaded]};
    [self.dicLoadStatus setObject:dicStatus forKey:@(self.currentTab)];
}

- (void)loadLoadStatus {
    NSDictionary *dicStatus = [self.dicLoadStatus objectForKey:@(self.currentTab)];
    if (dicStatus) {
        self.loadStartIndex = [[dicStatus objectForKey:@"startIndex"] integerValue];
        self.isAllLoaded = [[dicStatus objectForKey:@"isAllLoaded"] boolValue];
    }
    else {
        self.loadStartIndex = 0;
        self.isAllLoaded = NO;
    }
}

#pragma mark - privates

- (UIView*) createAvatarImage {
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self.view;
    
    UIView *avatarContainer = [UIView new];
    avatarContainer.backgroundColor = [UIColor clearColor];
    views[@"avatarContainer"] = avatarContainer;
    
    UIImageView *maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamedContentFile:@"ic-profile-avatar-mask"]];
    maskView.translatesAutoresizingMaskIntoConstraints = NO;
    maskView.contentMode = UIViewContentModeScaleToFill;
    views[@"maskView"] = maskView;
    [avatarContainer addSubview:maskView];
    
    UIImageView* avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamedContentFile:@"ic-profile-avatar"]];
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    avatarView.contentMode = UIViewContentModeScaleToFill;
    views[@"imageAvatar"] = avatarView;
    [avatarContainer addSubview:avatarView];
    self.imageAvatar = avatarView;
    
    NSArray* constraints;
    NSString* format;
    
    format = @"|-0-[maskView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [avatarContainer addConstraints:constraints];
    
    format = @"V:|-0-[maskView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [avatarContainer addConstraints:constraints];
    
    format = @"|-3-[imageAvatar]-3-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [avatarContainer addConstraints:constraints];
    
    format = @"V:|-3-[imageAvatar]-3-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [avatarContainer addConstraints:constraints];
    
    return avatarContainer;
}

- (void)addTitleView {
    if(!self.customTitleView){
        CGRect bounds = [UIScreen mainScreen].bounds;
        
        // realname
        UILabel *realNameLabel = [UILabel new];
        realNameLabel.frame = CGRectMake(0, 0, bounds.size.width, 25);
        realNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.FirstName, self.user.LastName];
        realNameLabel.textAlignment = NSTextAlignmentCenter;
        realNameLabel.numberOfLines =1;
        realNameLabel.textColor = [UIColor whiteColor];
        realNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        self.labelTitleRealname = realNameLabel;
        
        // username
        UILabel *userNameLabel = [UILabel new];
        userNameLabel.frame = CGRectMake(0, 20, bounds.size.width, 20);
        userNameLabel.text = self.user.UserName;
        userNameLabel.textAlignment = NSTextAlignmentCenter;
        userNameLabel.numberOfLines =1;
        userNameLabel.textColor = [UIColor whiteColor];
        userNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.labelTitleUsername = userNameLabel;
        
        // wrapper
        UIView *wrapper = [UIView new];
        wrapper.frame = CGRectMake(0, 64, bounds.size.width, 44);
        [wrapper addSubview:userNameLabel];
        [wrapper addSubview:realNameLabel];
        self.customTitleView  = wrapper;
        
        // image title cover
        UIImageView *titleCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 64)];
        titleCover.image = nil;
        titleCover.backgroundColor = [UIColor clearColor];
        self.imageTitleCover = titleCover;
        
        // custom title view container
        UIView *titleContainer = [UIView new];
        titleContainer.frame = CGRectMake(0, 0, bounds.size.width, 64);
        titleContainer.clipsToBounds = YES;
        [titleContainer addSubview:titleCover];
        [titleContainer addSubview:wrapper];
        [self.view addSubview:titleContainer];
        self.titleContainer = titleContainer;
    }
}

- (UIImage *)blurWithImageAt:(CGFloat)percent {
    NSNumber* keyNumber = @0;
    if(percent <= 0.2){
        keyNumber = @1;
    } else if(percent <= 0.4) {
        keyNumber = @2;
    } else if(percent <= 0.6) {
        keyNumber = @3;
    } else if(percent <= 0.8) {
        keyNumber = @4;
    } else if(percent <= 1.0) {
        keyNumber = @5;
    }
    UIImage* image = [_blurredImageCache objectForKey:keyNumber];
    if(image == nil){
        //TODO if cache not yet built, just compute and put in cache
        return _originCoverImage;
    }
    return image;
}

- (UIImage *)blurWithImageEffects:(UIImage *)image andRadius: (CGFloat) radius {
    return [image applyBlurWithRadius:radius tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}

- (void) fillBlurredImageCache {
    CGFloat maxBlur = 20;
    UIImage *smallImage = [PhotoHelper cropImage:_originCoverImage size:CGSizeMake(SCREEN_WIDTH, 64)];
    self.blurredImageCache = [NSMutableDictionary new];
    for (int i = 0; i <= 5; i++) {
        self.blurredImageCache[[NSNumber numberWithInt:i]] = [self blurWithImageEffects:smallImage andRadius:(maxBlur * i/5.0f)];
    }
}

- (void) setOriginCoverImage:(UIImage*)image {
    _originCoverImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fillBlurredImageCache];
    });
}

- (void)actionShowWrongMessage:(WrongMessageType)type {
    [WrongMessageView showMessage:type inView:self.view arrayOffsetY:@[@0, @0, @0]];
}

- (void)actionGotoFollowing {
    FollowingViewController *viewController = [[FollowingViewController alloc] initWithOCUser:self.user];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionGotoFollowers {
    FollowersViewController *viewController = [[FollowersViewController alloc] initWithOCUser:self.user];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionGotoCreatedTwysts {
    if (self.currentTab != ProfileTabCreated) {
        [self saveLoadStatus];
        self.currentTab = ProfileTabCreated;
        [self loadLoadStatus];
        [self actionLoadTwysts];
    }
}

- (void)actionGotoLikedTwysts {
    if (self.currentTab != ProfileTabLiked) {
        [self saveLoadStatus];
        self.currentTab = ProfileTabLiked;
        [self loadLoadStatus];
        [self actionLoadTwysts];
    }
}

- (void)actionLoadTwysts {
    
}

#pragma mark - override methods
- (void)initMembers {
    _headerHeight = 100.0;
    _subHeaderHeight = 100.0;
    _avatarImageSize = 70;
    _barIsCollapsed = false;
    _barAnimationComplete = false;
}

- (UIView*) createSubHeaderView {
    return [UIView new];
}

#pragma mark - profile activity delegate
- (void)profileActivity:(ProfileActivityView *)activityView itemTouch:(NSInteger)index {
    switch (index) {
        case 0:
            [self actionGotoCreatedTwysts];
            break;
        case 1:
            [self actionGotoLikedTwysts];
            break;
        case 2:
            [self actionGotoFollowers];
            break;
        case 3:
            [self actionGotoFollowing];
            break;
        default:
            break;
    }
}

#pragma mark - status bar hidden
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && self.view.window){
        
    }
}

- (void)dealloc{
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
    _originCoverImage = nil;
    _blurredImageCache = nil;
    _arrayCreatedTwysts = nil;
    _arrayLikedTwysts = nil;
    _dicLoadStatus = nil;
}

@end
