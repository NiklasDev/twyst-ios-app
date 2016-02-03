//
//  TwystPreviewController.m
//  Twyst
//
//  Created by Niklas Ahola on 6/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImage+animatedGIF.h"
#import "UIImageView+WebCache.h"

#import "UserWebService.h"

#import "TTwystNewsManager.h"
#import "TTwystOwnerManager.h"
#import "TSavedTwystManager.h"
#import "TwystDownloadService.h"

#import "TStillframeRegular.h"

#import "KKProgressTimer.h"
#import "TwystInfoView.h"
#import "TwystNoticeView.h"
#import "WrongMessageView.h"
#import "FFullTutorialView.h"
#import "TwystPreviewView.h"
#import "CircleProcessingView.h"

#import "TwystPreviewController.h"
#import "PassTwystViewController.h"
#import "AddPeopleViewController.h"
#import "TwystFramesViewController.h"
#import "TwystPeopleViewController.h"
#import "FriendProfileViewController.h"

@interface TwystPreviewController () <FFullTutorialViewDelegate, TwystPreviewDelegate, TwystFramesDelegate, TwystInfoViewDelegate, TwystNoticeViewDelegate, UIActionSheetDelegate> {
    BOOL _isCompleted;

    NSTimer *_timerDownload;
    
    TwystInfoView *_twystInfoView;
    TwystNoticeView *_twystNoticeView;
    TwystPreviewView *_twystPreview;
    
    long _selectedFriendId;
    FriendManageService *_friendService;
}

@property (weak, nonatomic) IBOutlet UIView *loadingTwystContainer;
@property (weak, nonatomic) IBOutlet UIImageView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *previewContainer;
@property (weak, nonatomic) IBOutlet UIView *tutorialContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageCreator;
@property (weak, nonatomic) IBOutlet KKProgressTimer *progressTimer;

@end

@implementation TwystPreviewController

- (id)init {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"TwystPreviewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _friendService = [FriendManageService sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkDownloadTwyst];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self allFramesAreReported]) {
        [self actionReport];
    }
    
    if (![_twystInfoView isVisible]) {
        [_twystPreview play];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopDownloadTimer];
    [_twystPreview pause];
}

#pragma mark - download twyst methods
- (void)checkDownloadTwyst {
    //add twyst loading gif
    NSURL *gifUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"twyst_loading_white" ofType:@"gif"]];
    self.loadingIndicator.image = [UIImage animatedImageWithAnimatedGIFURL:gifUrl];
    
    TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:self.twyst.Id];
    if (savedTwyst) {
        // check if reply is in local already for only reply notification
        self.loadingTwystContainer.hidden = NO;
        [[TSavedTwystManager sharedInstance] checkReplyAndDownload:savedTwyst completion:^(BOOL isDownloaded, NSArray *replies) {
            [Global getInstance].reportedReplies = [[TSavedTwystManager sharedInstance] filterReportedReplies:replies];
            if (isDownloaded) {
                _isCompleted = YES;
                [self actionTwystDidDownload];
            }
            else {
                [self actionDownloadTwyst:self.twyst];
            }
        }];
    }
    else {
        [self actionDownloadTwyst:self.twyst];
    }
}

- (void)actionDownloadTwyst:(Twyst*)twyst {
    [self addNotifications];
    if (self.isFriendTwyst) {
        [[TwystDownloadService sharedInstance] downloadFriendTwyst:twyst isUrgent:YES];
    }
    else {
        [[TwystDownloadService sharedInstance] downloadTwyst:twyst isUrgent:YES];
    }
    [self startDownloadTimer];
}

- (void)actionTwystDidDownload {
    [self removeNotifications];
    [self stopDownloadTimer];
    
    self.loadingTwystContainer.hidden = YES;
    self.savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:self.twyst.Id];
    self.savedTwyst.isUnread = [NSNumber numberWithBool:NO];
    [[TSavedTwystManager sharedInstance] saveObject:self.savedTwyst];
    
    [self initView];
    [self actionShowTutorial];
}

- (void)actionTwystDownloadFailed {
    [self removeNotifications];
    [self stopDownloadTimer];
    
    self.loadingTwystContainer.hidden = YES;
    [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
}

#pragma mark - add / remove notification
- (void) addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDidDownload:)
                                                 name:kTwystDidDownloadNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDownloadFailed:)
                                                 name:kTwystDownloadFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFriendTwystDidDownload:)
                                                 name:kFriendTwystDidDownloadNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFriendTwystDownloadFailed:)
                                                 name:kFriendTwystDownloadFailNotification
                                               object:nil];
}

- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystDidDownloadNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystDownloadFailNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kFriendTwystDidDownloadNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kFriendTwystDownloadFailNotification
                                                  object:nil];
}

- (void)handleTwystDidDownload:(NSNotification*)notification {
    Twyst *twyst = [[notification userInfo] objectForKey:@"Twyst"];
    if (twyst.Id == self.twyst.Id) {
        _isCompleted = YES;
        [self actionTwystDidDownload];
    }
}

- (void)handleTwystDownloadFailed:(NSNotification*)notification {
    Twyst *twyst = [[notification userInfo] objectForKey:@"Twyst"];
    if (twyst.Id == self.twyst.Id) {
        _isCompleted = NO;
        [self actionTwystDownloadFailed];
    }
}

- (void)handleFriendTwystDidDownload:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    if (twyst.Id == self.twyst.Id) {
//        BOOL isComplete = [[notification.userInfo objectForKey:@"isComplete"] boolValue];
//        _isCompleted = isComplete;
        _isCompleted = YES;
        [self actionTwystDidDownload];
    }
}

- (void)handleFriendTwystDownloadFailed:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    if (twyst.Id == self.twyst.Id) {
        _isCompleted = NO;
        [self actionTwystDownloadFailed];
    }
}

#pragma mark - internal methods
- (void)initView {
    //make image creator circle
    _imageCreator.layer.cornerRadius = _imageCreator.frame.size.width / 2;
    _imageCreator.layer.masksToBounds = YES;
    
    //add stringg preview
    [self addTwystPreviewView:_isCompleted];
    
    //add twyst notice view
    [self addTwystNoiceView];
    
    //add twyst info view
    [self addTwystInfoView];
}

- (void)addTwystPreviewView:(BOOL)isComplete {
    _twystPreview = [[TwystPreviewView alloc] initWithFrame:self.view.bounds];
    [_twystPreview setIsComplete:isComplete];
    _twystPreview.delegate = self;
    [_twystPreview enableSwipeGestures];
    [_twystPreview setDataSourceWithSavedTwyst:self.savedTwyst];
    [self.previewContainer insertSubview:_twystPreview atIndex:0];
    [_twystPreview setSelectedImageIndex:0];
}

- (void)addTwystInfoView {
    _twystInfoView = [[TwystInfoView alloc] initWithTwyst:self.savedTwyst];
    _twystInfoView.delegate = self;
    [self.view addSubview:_twystInfoView];
}

- (void)addTwystNoiceView {
    _twystNoticeView = [[TwystNoticeView alloc] initWithTwyst:self.savedTwyst];
    _twystNoticeView.delegate = self;
    [self.view addSubview:_twystNoticeView];
}

- (void)actionShowTutorial {
    if ([Global getConfig].isFirstPreviewTime)  {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialPreviewSkipFrame withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        self.tutorialContainer.hidden = NO;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else {
        [_twystPreview play];
    }
}

- (void)actionViewTwyst {
    void (^block)(BOOL) = ^void(BOOL isSuccess) {};
    long twystId = [self.savedTwyst.twystId longValue];
    [[UserWebService sharedInstance] viewTwyst:twystId completion:block];
}

- (void)actionDelete {
    long twystId = [self.savedTwyst.twystId longValue];
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] deleteUserTwyst:twystId completion:^(ResponseType response) {
        [CircleProcessingView hide];
        if (response == Response_Success) {
            [Global postTwystDidDeleteNotification:self.twyst];
            [[TSavedTwystManager sharedInstance] deleteSavedTwyst:self.savedTwyst];
            [[TTwystNewsManager sharedInstance] deleteNewsWithTwystId:twystId];
            [self actionClosePreview];
        }
        else if (response == Response_Deleted_Twyst) {
            [WrongMessageView showAlert:WrongMessageTypeTwystDeleted target:nil];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

- (void)actionAddPeople {
    AddPeopleViewController *viewController = [[AddPeopleViewController alloc] init];
    viewController.stringgId = [self.savedTwyst.twystId longValue];
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)actionLeave {
    long twystId = [self.savedTwyst.twystId longValue];
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] hideFriendTwyst:twystId completion:^(ResponseType response) {
        [CircleProcessingView hide];
        if (response == Response_Success) {
            [Global postTwystDidLeaveNotification:self.twyst];
            [[TTwystNewsManager sharedInstance] deleteNewsWithTwystId:twystId];
            [self actionClosePreview];
            [WrongMessageView showMessage:WrongMessageTypeSuccessLeaveTwyst inView:[AppDelegate sharedInstance].window];
        }
        else if (response == Response_Deleted_Twyst) {
            [WrongMessageView showAlert:WrongMessageTypeTwystDeleted target:nil];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

- (void)actionReport {
    long twystId = [self.savedTwyst.twystId longValue];
    [CircleProcessingView showInView:self.view];
    [[UserWebService sharedInstance] reportTwyst:twystId completion:^(BOOL isSuccess) {
        [CircleProcessingView hide];
        if (isSuccess) {
            [Global postTwystDidLeaveNotification:self.twyst];
            [[TTwystNewsManager sharedInstance] deleteNewsWithTwystId:twystId];
            [self actionClosePreview];
            [WrongMessageView showMessage:WrongMessageTypeReportConfirmation inView:[AppDelegate sharedInstance].window];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

- (void)actionClosePreview {
    [_twystInfoView releaseInfoView];
    [_twystNoticeView releaseNoticeView];
    [self removeNotifications];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionShowWrongMessage:(WrongMessageType)type {
    [WrongMessageView showMessage:type inView:self.view arrayOffsetY:@[@0, @0, @0]];
}

- (BOOL)allFramesAreReported {
    if (![self.savedTwyst.listStillframeRegular count]) return NO;
    
    BOOL allFramesReported = YES;
    for (TStillframeRegular *stillframeRegular in self.savedTwyst.listStillframeRegular) {
        NSArray *paths = [stillframeRegular.path componentsSeparatedByString:@"/"];
        NSString *replyName = [paths objectAtIndex:2];
        if (![[Global getInstance].reportedReplies containsObject:replyName]) {
            allFramesReported = NO;
            break;
        }
    }
    return allFramesReported;
}

#pragma mark -
- (void)actionGotoFrames {
    TwystFramesViewController *viewController = [[TwystFramesViewController alloc] initWithSavedStringg:self.savedTwyst];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionGotoPeople {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionFromLeft;
    [transition setType:kCATransitionPush];
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
        
    TwystPeopleViewController *viewController = [[TwystPeopleViewController alloc] initWithTwystId:self.twyst.Id];
    viewController.twysterCount = [_twystInfoView getTwysterCount];
    [self.navigationController pushViewController:viewController animated:NO];
}

- (void)actionGotoPass {
    PassTwystViewController *viewController = [[PassTwystViewController alloc] init];
    viewController.isFromPreview = YES;
    viewController.twystId = [self.savedTwyst.twystId longValue];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)actionGotoReply {
    long twystId = [self.savedTwyst.twystId longValue];
    [[AppDelegate sharedInstance] goToCameraScreenToReply:twystId];
}

- (void)actionGotoCreatorProfile {
    long ownerId = [self.savedTwyst.ownerId longValue];
    if (ownerId != [Global getOCUser].Id) {
        TTwystOwner *owner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:ownerId];
        OCUser *user = [[TTwystOwnerManager sharedInstance] getOCUserFromTwystOwner:owner];
        FriendProfileViewController *viewController = [[FriendProfileViewController alloc] init];
        viewController.user = user;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - show info
- (void)showInfoView {
    [_twystPreview pause];
    [_twystInfoView show];
}

#pragma mark - handle timer methods
- (void)startDownloadTimer {
    if (_timerDownload == nil) {
        _timerDownload = [NSTimer scheduledTimerWithTimeInterval:120.0f
                                                          target:self
                                                        selector:@selector(onDownloadTimer:)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)stopDownloadTimer {
    if (_timerDownload) {
        [_timerDownload invalidate];
        _timerDownload = nil;
    }
}

- (void)onDownloadTimer:(id)sender {
    self.loadingTwystContainer.hidden = YES;
    [self stopDownloadTimer];
    [self removeNotifications];
    [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
}

#pragma mark -
#pragma mark - like / twyster related methods
- (void)actionSendRequest {
    NSString *friendId = [NSString stringWithFormat:@"%ld", _selectedFriendId];
    [_friendService requesetFriend:friendId
                        completion:^(BOOL isSuccess) {
                            if (isSuccess) {
                                
                            }
                            else {
                                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
                            }
                        }];
}

- (void)actionUnfriend {
    NSString *requestId = [_friendService friendshipId:_selectedFriendId];
    [_friendService removeFriend:requestId
                      completion:^(BOOL isSuccess) {
                          if (isSuccess) {
                              
                          }
                          else {
                              [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
                          }
                      }];
}

#pragma mark - button handler
- (void)FullTutorialViewWillDisappear:(FFullTutorialView*)sender {
    [sender removeFromSuperview];
    
    if (sender.type == FullTutorialPreviewSkipFrame) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialPreviewSwipeDown withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else if (sender.type == FullTutorialPreviewSwipeDown) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialPreviewSwipeUp withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else if (sender.type == FullTutorialPreviewSwipeUp) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialPreviewSwipeLeft withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else if (sender.type == FullTutorialPreviewSwipeLeft) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialPreviewSwipeRight withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else if (sender.type == FullTutorialPreviewSwipeRight) {
        self.tutorialContainer.hidden = YES;
        [Global getConfig].isFirstPreviewTime = NO;
        [Global saveConfig];
        [_twystPreview play];
    }
}

- (IBAction)handleBtnCloseTouch:(id)sender {
    [self actionClosePreview];
}

- (IBAction)handleTapCreator:(id)sender {
    [_twystPreview pause];
    [_twystNoticeView show];
}

#pragma mark - twyst preview delegate
- (void)twystPreviewDidSwipe:(UISwipeGestureRecognizerDirection)direction {
    switch (direction) {
        case UISwipeGestureRecognizerDirectionUp:
            [self actionClosePreview];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [self showInfoView];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [self actionGotoFrames];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self actionGotoPeople];
            break;
        default:
            break;
    }
}

- (void)twystPreviewDidView:(id)sender {
    [self actionViewTwyst];
}

- (void)twystPreviewDidChange:(NSString *)profilePicName frameTime:(NSTimeInterval)frameTime {
    if (IsNSStringValid(profilePicName)) {
        UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-profile-avatar"];
        [_imageCreator setImageWithURL:ProfileURL(profilePicName) placeholderImage:placeholder];
    }
    
    __block CGFloat i1 = 0;
    [_progressTimer startWithBlock:^CGFloat {
        return i1++ / 30 / frameTime;
    }];
}

- (void)twystPreviewDidPause {
    [_progressTimer pause];
}

- (void)twystPreviewDidResume {
    [_progressTimer resume];
}

#pragma mark - twyst frames delegate
- (void)twystFrameDidSelect:(NSInteger)index {
    [_twystPreview setSelectedImageIndex:index];
}

#pragma mark - twyst info view delegate
- (void)twystInfoViewDidHide {
    [_twystPreview resume];
}

- (void)twystInfoViewMoreDidClick {
    UIActionSheet *actionSheet = nil;
    if ([self isMyTwyst]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Delete"
                                         otherButtonTitles:@"Add People", nil];
        actionSheet.tag = 100;
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Report"
                                         otherButtonTitles:nil];
        actionSheet.tag = 200;
    }
    [actionSheet showInView:self.view];
}

- (void)twystInfoViewReplyDidClick {
    [self actionGotoReply];
}

- (void)twystInfoViewPassDidClick {
    [self actionGotoPass];
}

- (void)twystInfoViewCreatorDidTap {
    [self actionGotoCreatorProfile];
}

#pragma mark - twyst notice view delegate
- (void)twystNoticeViewDidClose {
    [_twystPreview resume];
}

- (void)twystNoticeViewMoreDidClick {
    UIActionSheet *actionSheet = nil;
    if ([self isMyTwyst]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Delete"
                                         otherButtonTitles:nil];
        actionSheet.tag = 300;
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Report"
                                         otherButtonTitles:nil];
        actionSheet.tag = 400;
    }
    [actionSheet showInView:self.view];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            [self actionDelete];
        }
        else if (buttonIndex == 1) {
            [self actionAddPeople];
        }
    }
    else if (actionSheet.tag == 200) {
        if (buttonIndex == 0) {
            [self actionReport];
        }
    }
    else if (actionSheet.tag == 300) {
        if (buttonIndex == 0) {
            [self actionDelete];
        }
    }
    else if (actionSheet.tag == 400) {
        if (buttonIndex == 0) {
            [self actionReport];
        }
    }
}

#pragma mark - status bar hidden
- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
