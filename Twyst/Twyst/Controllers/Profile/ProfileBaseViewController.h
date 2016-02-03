//
//  ProfileBaseViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 4/17/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCUser.h"
#import "ProfileActivityView.h"
#import "WDActivityIndicator.h"
#import "BaseViewController.h"
#import "FadeHeaderControllerAnimatedTransitioning.h"

typedef enum {
    ProfileTabCreated = 100,
    ProfileTabLiked,
} ProfileTab;

@interface ProfileBaseViewController : BaseViewController <HeaderProtocol>

////////////////////
// logic members
@property (nonatomic, strong) OCUser *user;
@property (nonatomic, assign) ProfileTab currentTab;
@property (nonatomic, strong) NSMutableArray *arrayCreatedTwysts;
@property (nonatomic, strong) NSMutableArray *arrayLikedTwysts;

@property (nonatomic, assign) NSInteger loadStartIndex;
@property (nonatomic, assign) BOOL isAllLoaded;
@property (nonatomic, retain) NSMutableDictionary *dicLoadStatus;


////////////////////
// ui members
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat subHeaderHeight;
@property (nonatomic, assign) CGFloat headerSwitchOffset;

// avatar
@property (nonatomic, assign) CGFloat avatarImageSize;
@property (nonatomic, assign) CGFloat avatarImageCompressedSize;
@property (nonatomic, assign) CGFloat avatarOffsetX;
@property (nonatomic, assign) CGFloat avatarOffsetY;

// username
@property (nonatomic, assign) CGFloat nameOffsetX;
@property (nonatomic, assign) CGFloat realNameOffsetY;
@property (nonatomic, assign) CGFloat userNameOffsetY;
@property (nonatomic, assign) CGFloat realNameFontSize;
@property (nonatomic, assign) CGFloat userNameFontSize;

// bio
@property (nonatomic, assign) CGFloat bioOffsetY;
@property (nonatomic, assign) CGFloat bioFontSize;

@property (nonatomic, assign) BOOL barIsCollapsed;
@property (nonatomic, assign) BOOL barAnimationComplete;
@property (nonatomic, assign) BOOL needToReload;

///////////////////////////////////////

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *imageCover;
@property (nonatomic, strong) UIImageView *imageAvatar;

// label
@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelRealname;
@property (nonatomic, strong) UILabel *labelBio;

// activity
@property (nonatomic, strong) ProfileActivityView *activityView;

// title
@property (nonatomic, strong) UIView *titleContainer;
@property (nonatomic, strong) UILabel *labelTitleUsername;
@property (nonatomic, strong) UILabel *labelTitleRealname;

@property (nonatomic, strong) UIImage *originCoverImage;
@property (nonatomic, strong) NSMutableDictionary* blurredImageCache;

@property (nonatomic, strong) WDActivityIndicator *activityIndicator;

- (void)configureNavBar;
- (void)refreshTableHeaderView;
- (void)setOriginCoverImage:(UIImage*)image;
- (void)actionShowWrongMessage:(WrongMessageType)type;

- (void)profileDidScroll:(UIScrollView*)scrollView;

- (void)actionGotoCreatedTwysts;
- (void)actionGotoLikedTwysts;

- (void)actionLoadTwysts;

@end
