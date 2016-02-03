//
//  AppDelegate.m
//  Twyst
//
//  Created by Niklas Ahola on 8/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "UIImage+Device.h"

#import "AppDelegate.h"

#import "FriendManageService.h"
#import "ContactManageService.h"
#import "FlurryTrackingService.h"
#import "IANoticeManageService.h"
#import "TwystDownloadService.h"
#import "AppPermissionService.h"
#import "PushNotificationService.h"

#import "IANLoadingView.h"
#import "WrongMessageView.h"
#import "CameraEnableView.h"
#import "UpdateVersionView.h"

#import "HomeViewController.h"
#import "FriendsViewController.h"
#import "UserProfileViewController.h"
#import "LandingPageViewController.h"
#import "NotificationsViewController.h"

#import "PreviewBaseViewController.h"

#import "NMTransitionManager+Headers.h"

@interface AppDelegate() <VDTabBarDelegate, CameraEnableViewDelegate> {
    NSInteger _selectedTab;
    UIImageView *_loadingView;
    IANLoadingView *_ianLoadinView;
    NSInteger _twystId;
}

@property (strong, nonatomic) CaptureViewController *captureViewController;

@end

@implementation AppDelegate

+ (AppDelegate*) sharedInstance {
    id appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize Push Notification Setting
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
    }
    else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    }

    // Init Global
    [Global startUp];
    
    // add notification observer
    [self addNotifications];
    
    [self configureWindow];
    
    // load contacts from the phone
    [self loadContacts];
    
    [self actionClearBadgeNumber];
    
    [self fixTextFieldDelay];
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application    {
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self checkIAN];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"device token = %@", deviceToken);
    [[Global getConfig] setDeviceToken:deviceToken];
    [[Global getConfig] save];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"---> application: didReceiveRemoteNotification: %@", userInfo);
    IANoticeManageService *ianService = [IANoticeManageService sharedInstance];
    [ianService checkIANManually:nil];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}

#pragma mark - configure app screens
- (void)configureWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.captureViewController = [[CaptureViewController alloc] init];
    
    OCUser *user = [Global getOCUser];
    UIViewController *tmpViewController = nil;
    if (user)    {
        // Check if user forgot password
        if (user.ForgotPass) {
            tmpViewController = [[LandingPageViewController alloc] initWithNewPassword];
        }
        else if (!IsNSStringValid(user.UserName)) {
            tmpViewController = [[LandingPageViewController alloc] initWithUsername];
        }
        else if (user.Verified == NO) {
            tmpViewController = [[LandingPageViewController alloc] initWithVerifyPhone];
        }
        else {
            [self.captureViewController setShouldNotLoadCameraPreview];
            tmpViewController = self.captureViewController;
        }
        
        [self intializeApp];
    }
    else {
        tmpViewController = [[LandingPageViewController alloc] init];
        ((LandingPageViewController*)tmpViewController).isLogoAnimate = YES;
    }
    
    self.mainNavController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
    self.mainNavController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.mainNavController;
    [self.window makeKeyAndVisible];
    
    if ([tmpViewController isEqual:self.captureViewController]) {
        [self.mainNavController presentViewController:self.homeNavController animated:NO completion:nil];
        [self showLoadingView];
    }
}

- (void)configureTabBar {
    HomeViewController * homeVC = [[HomeViewController alloc] init];
    NotificationsViewController *notificationsVC = [[NotificationsViewController alloc] init];
    FriendsViewController *friendsVC = [[FriendsViewController alloc] init];
    UserProfileViewController * profileVC = [[UserProfileViewController alloc] init];
    
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    UINavigationController *notificationsNav = [[UINavigationController alloc] initWithRootViewController:notificationsVC];
    UINavigationController *friendsNav = [[UINavigationController alloc] initWithRootViewController:friendsVC];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
    
    homeNav.navigationBarHidden = YES;
    notificationsNav.navigationBarHidden = YES;
    friendsNav.navigationBarHidden = YES;
    profileNav.navigationBarHidden = YES;
    
    self.tabBarController = [[VDTabBarController alloc] init];
    self.tabBarController.viewControllers = @[homeNav, notificationsNav, friendsNav, profileNav];
    [self.tabBarController setModalPresentationStyle:UIModalPresentationFullScreen];
    self.tabBarController.vdTabBarDelegate = self;
    self.homeNavController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    self.homeNavController.navigationBarHidden = YES;
}

#pragma mark - Screen transition methods
// This method is called after user login
- (void) startApp   {
    [self intializeApp];
    [self.captureViewController startNewSession];
    //self.homeNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.mainNavController presentViewController:self.homeNavController animated:NO completion:^{
        //self.homeNavController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.mainNavController pushViewController:self.captureViewController animated:NO];
    }];
}

- (void) intializeApp {
    // Configure View Hierarchy
    [self configureTabBar];
    
    [self initializeServices];
}

- (void) reloadLandingScreen    {
    [self.captureViewController setShouldNotLoadCameraPreview];
    [self.mainNavController dismissViewControllerAnimated:NO completion:nil];
    
    self.tabBarController = nil;
    self.homeNavController = nil;
    self.mainNavController = nil;
    
    LandingPageViewController *viewController = [[LandingPageViewController alloc] init];
    self.mainNavController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.mainNavController.navigationBarHidden = YES;
    self.window.rootViewController = self.mainNavController;
}

- (void) backToHomeScreen   {
    [self.tabBarController selectTab:0];
    [self.mainNavController presentViewController:self.homeNavController animated:YES completion:^{
        self.mainNavController.viewControllers = @[_captureViewController];
    }];
}

- (void) closeCameraScreen {
    [self.mainNavController presentViewController:self.homeNavController animated:YES completion:^{
        self.mainNavController.viewControllers = @[_captureViewController];
    }];
}

- (void) goBackToCameraScreen   {
    [self.mainNavController popToViewController:_captureViewController animated:YES];
    [_captureViewController startNewSession];
}

- (void) goBackToCameraScreenToReply:(long)twystId   {
    [self.mainNavController popToViewController:_captureViewController animated:YES];
    [self.captureViewController startNewSessionToReply:twystId];
}

- (void) goToCameraScreen {
    UIColor *violetColor = [UIColor colorWithRed:75.0/255.0 green:64.0/255.0 blue:113.0/255.0 alpha:1.0];
    NMColorBurstTransition *transition = [[NMColorBurstTransition alloc] initWithContainerFrom:self.homeNavController.view
                                                                                     burstView:self.tabBarController.tabBar
                                                                                   containerTo:nil
                                                                                    burstColor:violetColor];
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [self.homeNavController dismissViewControllerAnimated:NO completion:^{
            completion();
        }];
        [self.captureViewController startNewSession];
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

- (void) goToCameraScreenToReply:(long)twystId {
    if ([[AppPermissionService sharedInstance] isCameraEnable]
        && [[AppPermissionService sharedInstance] isMicroPhoneEnable]) {
        
        [[self.homeNavController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        [self.captureViewController startNewSessionToReply:twystId];
    }
    else {
        _twystId = twystId;
        [CameraEnableView showInView:self.window target:self];
    }
}

- (void)actionClearBadgeNumber {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - load initial data after login
- (void) initializeServices {
    // initialize friend service
    FriendManageService *friendService = [FriendManageService sharedInstance];
    [friendService startNewFriendSession];
    
    // initialize in app notice service
    IANoticeManageService *ianService = [IANoticeManageService sharedInstance];
#ifdef DEBUG
    [ianService startNewIANSession];
#else
    [ianService checkIANManually:nil];
#endif
    
    // initialize stringg download service
    TwystDownloadService *downloadService = [TwystDownloadService sharedInstance];
    [downloadService startDownloadService];
    
    // register device to receive push notification
    PushNotificationService *pushService = [PushNotificationService sharedInstance];
    [pushService startNewSession];
    
    // start flurry tracking service
    [FlurryTrackingService startNewFlurrySession];
}

#pragma mark - unload after logout
- (void) clearServices {
    FriendManageService *friendService = [FriendManageService sharedInstance];
    [friendService clearCachedData];
    
#ifdef DEBUG
    IANoticeManageService *ianService = [IANoticeManageService sharedInstance];
    [ianService stopIANSession];
#endif
    
    TwystDownloadService *downloadService = [TwystDownloadService sharedInstance];
    [downloadService stopDownloadService];
    
    // unregister device to receive push notification
    PushNotificationService *pushService = [PushNotificationService sharedInstance];
    [pushService endCurrentSession];
}

- (void)loadContacts {
    // load contact list
    ContactManageService *contactService = [ContactManageService sharedInstance];
    [contactService startNewContactSession];
}

#pragma mark - add / remove / handle notification methods
- (void) addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCameraTabSelected:)
                                                 name:kCameraTabDidSelectNotification
                                               object:nil];
}

- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCameraTabDidSelectNotification
                                                  object:nil];
}

- (void) handleCameraTabSelected:(NSNotification *)notification {
    _twystId = DEF_INVALID_TWYST_ID;
    if ([notification.name isEqualToString:kCameraTabDidSelectNotification]) {
        if ([[AppPermissionService sharedInstance] isCameraEnable]
            && [[AppPermissionService sharedInstance] isMicroPhoneEnable]) {
            [self goToCameraScreen];
        }
        else {
            [CameraEnableView showInView:self.window target:self];
        }
    }
}

#pragma mark - drop down tutor delegate
- (void)CameraEnableViewClicked:(CameraEnableView*)sender selectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex == 0) {
        [[AppPermissionService sharedInstance] presentCameraPermissionAlert:^(BOOL granted) {
            if (granted) {
                [self handlePermissionGranted:sender];
            }
        }];
    }
    else if (selectedIndex == 1) {
        [[AppPermissionService sharedInstance] presentMicroPhonePermissionAlert:^(BOOL granted) {
            if (granted) {
                [self handlePermissionGranted:sender];
            }
        }];
    }
}

- (void)CameraEnableViewDidDismiss:(CameraEnableView*)sender {
    if ([[AppPermissionService sharedInstance] isCameraEnable]
        && [[AppPermissionService sharedInstance] isMicroPhoneEnable]) {
        if (_twystId == DEF_INVALID_TWYST_ID) {
            [self goToCameraScreen];
        }
        else {
            [self goToCameraScreenToReply:_twystId];
        }
    }
}

- (void)handlePermissionGranted:(CameraEnableView*)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [sender reloadButtons];
        if ([[AppPermissionService sharedInstance] isCameraEnable]
            && [[AppPermissionService sharedInstance] isMicroPhoneEnable]) {
            [sender hide];
        }
    });
}

#pragma mark - tab bar controller delegate
- (void)didSelectTab:(UIViewController *)selectedViewController tabIndex:(NSInteger)tabIndex {
    if (_selectedTab == tabIndex) {
        // process click selected tab again
        if (_selectedTab == 0) {
            HomeViewController *viewController = (HomeViewController*)[[(UINavigationController*)selectedViewController viewControllers] firstObject];
            [viewController scrollToTop];
        }
    }
    else {
        if (tabIndex == 2) {
            FriendsViewController *viewController = (FriendsViewController*)[[(UINavigationController*)selectedViewController viewControllers] firstObject];
            [viewController startNewFriendsSession];
        }
        else if (tabIndex == 3) {
            [self setFriendBadge:0];
        }
    }
    _selectedTab = tabIndex;
}

#pragma mark - check in app notice when app is active
- (void)checkIAN {
    if ([UIApplication sharedApplication].applicationIconBadgeNumber) {
        [self actionClearBadgeNumber];
        
        [self addIANLoadingView];
        [[IANoticeManageService sharedInstance] checkIANManually:^(BOOL isSuccess) {
            [self hideIANLoadingView];
            if (!isSuccess) {
                [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.window];
            }
        }];
    }
}

- (void)addIANLoadingView {
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:@"IANLoadingView" owner:nil options:nil];
    _ianLoadinView = (IANLoadingView*)[subViews firstObject];
    [self.window addSubview:_ianLoadinView];
}

- (void)hideIANLoadingView {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _ianLoadinView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [_ianLoadinView removeFromSuperview];
                     }];
}

#pragma mark - set tab notification
- (void) setNewTwystBadge:(BOOL)isShow {
    [_tabBarController setNewTwystBadge:isShow];
}

- (void) setNotificationBadge:(NSInteger)badge {
    [_tabBarController setNotificationBadge:badge];
}

- (void) setFriendBadge:(NSInteger)badge {
    if (_selectedTab != 3) {
        [_tabBarController setFriendBadge:badge];
    }
}

#pragma mark - loading view related methods
- (void)showLoadingView {
    self.isHomeLoading = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingView)
                                                 name:kHomeDidLoadNotification
                                               object:nil];
    
    NSString *imageName = ([Global deviceType] == DeviceTypePhone4) ? @"launchImage-3.5inch" : @"launchImage";
    UIImage *image = [UIImage imageNamedForDevice:imageName];
    CGRect bounds = [UIScreen mainScreen].bounds;
    _loadingView = [[UIImageView alloc] initWithFrame:bounds];
    _loadingView.image = image;
    [self.window addSubview:_loadingView];
}

- (void)hideLoadingView {
    self.isHomeLoading = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kHomeDidLoadNotification
                                                  object:nil];
    [UIView animateWithDuration:0.2f
                          delay:0.5f
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         _loadingView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [_loadingView removeFromSuperview];
                     }];
}

#pragma mark -
- (BOOL) isTabBarVisible {
    return (BOOL)[[[self tabBarController] tabBar] window];
}

#pragma mark - update version view 
- (void)showUpdateVersionView {
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:@"UpdateVersionView" owner:nil options:nil];
    UpdateVersionView *updateVersionView = [subViews firstObject];
    [updateVersionView showInView:self.window];
}

#pragma mark - fix text field delay
- (void)fixTextFieldDelay {
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
}

@end
