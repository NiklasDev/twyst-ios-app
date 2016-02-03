//
//  AppDelegate.h
//  Twyst
//
//  Created by Niklas Ahola on 8/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDTabBarController.h"
#import "CaptureViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) VDTabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *mainNavController;
@property (strong, nonatomic) UINavigationController *homeNavController;

@property (nonatomic, assign) BOOL isHomeLoading;

+ (AppDelegate*) sharedInstance;

- (void) startApp;
- (void) reloadLandingScreen;

// go to first tab of home screen
- (void) backToHomeScreen;

// go to home screen
- (void) closeCameraScreen;

// go back to camera screen from edit screen
- (void) goBackToCameraScreen;
- (void) goBackToCameraScreenToReply:(long)twystId;

// go to camera screen from home
- (void) goToCameraScreen;
- (void) goToCameraScreenToReply:(long)twystId;

- (void) initializeServices;
- (void) clearServices;

- (void) setNewTwystBadge:(BOOL)isShow;
- (void) setNotificationBadge:(NSInteger)badge;
- (void) setFriendBadge:(NSInteger)badge;

- (BOOL) isTabBarVisible;

// show update version view
- (void)showUpdateVersionView;

@end