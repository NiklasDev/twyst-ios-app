//
//  EditVideoViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIView+Animation.h"
#import "UIImage+Device.h"

#import "AppDelegate.h"

#import "UserWebService.h"
#import "FriendManageService.h"
#import "FlipframeFileService.h"
#import "TwystDownloadService.h"
#import "AzureBlobStorageService.h"
#import "IANoticeManageService.h"
#import "FlurryTrackingService.h"

#import "FFullTutorialView.h"

#import "EditVideoView.h"
#import "EditThemeView.h"
#import "EditVideoTrimView.h"
#import "EditVideoCoverView.h"
#import "EditReplyThemeView.h"
#import "HVSpectrumView.h"
#import "BezierInterpView.h"
#import "WrongMessageView.h"
#import "YLProgressBar.h"

#import "ShareViewController.h"
#import "EditVideoViewController.h"
#import "ShareEmptyViewController.h"
#import "PassTwystViewController.h"


@interface EditVideoViewController () <FFullTutorialViewDelegate, EditThemeViewDelegate, BezierInterpViewDelegate, HVSpectrumViewDelegate, EditVideoTrimViewDelegate, EditVideoCoverViewDelegate, AzureStorageServiceDelegate, UIActionSheetDelegate> {
    
    FlipframeVideoModel *_flipframeModel;
    
    EditVideoView *_videoView;
    EditVideoTrimView *_trimView;
    EditVideoCoverView *_coverView;
    
    NSTimer *_progressTimer;
}

@property (weak, nonatomic) IBOutlet UIView *topBarContainer;
@property (weak, nonatomic) IBOutlet UIView *drawTopBarContainer;
@property (weak, nonatomic) IBOutlet UIView *largeImageContainer;
@property (weak, nonatomic) IBOutlet UIView *drawingContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIView *drawButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *editorContainer;
@property (weak, nonatomic) IBOutlet UIView *tutorialContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomBackground;

@property (weak, nonatomic) IBOutlet BezierInterpView *drawView;
@property (weak, nonatomic) IBOutlet HVSpectrumView *spectrumView;

@property (weak, nonatomic) IBOutlet UIButton *btnTrim;
@property (weak, nonatomic) IBOutlet UIButton *btnCover;
@property (weak, nonatomic) IBOutlet UIButton *btnDraw;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;

@property (weak, nonatomic) IBOutlet UIView *viewCreating;
@property (weak, nonatomic) IBOutlet UIImageView *imagePretzel;

@property (weak, nonatomic) IBOutlet UIView *viewReplying;
@property (weak, nonatomic) IBOutlet UIButton *btnReplyCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnReplySend;
@property (weak, nonatomic) IBOutlet UIButton *btnReplyHome;
@property (weak, nonatomic) IBOutlet UIButton *btnReplyPass;
@property (weak, nonatomic) IBOutlet UILabel *labelReplyHelp1;
@property (weak, nonatomic) IBOutlet UILabel *labelReplyHelp2;
@property (weak, nonatomic) IBOutlet UILabel *labelReplyHelp3;
@property (weak, nonatomic) IBOutlet UILabel *labelReplyHelp4;
@property (weak, nonatomic) IBOutlet YLProgressBar *progressReply;

@end

@implementation EditVideoViewController

- (id)initWithParent:(UIViewController*) inParent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"EditVideoViewController-3.5inch" : [FlipframeUtils nibNameForDevice:@"EditVideoViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addKeyboardObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_trimView startTimer];
    
    // play
    [_videoView updateVideoPlayRange];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardObserver];
    [_trimView invalidateTimer];
}

#pragma mark - init view
- (void) initView {
    self.drawView.delegate = self;
    [self.drawView setLineColor:Color(0, 185, 172)];
    self.spectrumView.delegate = self;
    
    // add editor views
    [self startNewSession];
    [self actionShowTutorial];
}

- (void) startNewSession    {
    _flipframeModel = [Global getCurrentFlipframeVideoModel];
    
    [self addVideoView];
    [self addVideoTrimView];
    [self addVideoCoverView];
}

- (void)addVideoView {
    if (_videoView) {
        [_videoView removeFromSuperview];
    }
    
    _videoView = [[EditVideoView alloc] initWithFrame:self.view.bounds];
    _videoView.topBarHeight = self.topBarContainer.frame.size.height;
    _videoView.bottomBarHeight = self.buttonContainer.frame.size.height;
    [self.largeImageContainer addSubview:_videoView];
}

- (void)addVideoTrimView {
    CGRect frame = CGRectMake(0, 0, self.editorContainer.frame.size.width, self.editorContainer.frame.size.height);
    _trimView = [[EditVideoTrimView alloc] initWithFrame:frame];
    _trimView.delegate = self;
    _trimView.videoView = _videoView;
    [self.editorContainer addSubview:_trimView];
    
    self.btnTrim.selected = YES;
}

- (void)addVideoCoverView {
    CGRect frame = CGRectMake(0, 0, self.editorContainer.frame.size.width, self.editorContainer.frame.size.height);
    _coverView = [[EditVideoCoverView alloc] initWithFrame:frame];
    _coverView.delegate = self;
    [self.editorContainer addSubview:_coverView];
    _coverView.alpha = 0.0f;
}

#pragma mark - keyboard related methods
- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    [self actionShowTopBar:NO];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self actionShowTopBar:YES];
}

#pragma mark - internal actions
- (void)actionShowTutorial {
    if ([Global getConfig].isFirstEditVideoTime) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialEditVideoSwipeDown withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
        self.tutorialContainer.hidden = NO;
    }
    else {
        self.tutorialContainer.hidden = YES;
    }
}

- (void)actionShowTopBar:(BOOL)show {
    CGFloat alpha = show ? 1.0f : 0.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.topBarContainer.alpha = alpha;
                         }];
    });
}

- (void)actionGotoEditThemeScreen {
    EditThemeView *themeView = [[EditThemeView alloc] initWithParent:self.view];
    themeView.delegate = self;
    [themeView show];
}

- (void)actionShowReplyTheme {
    EditReplyThemeView *themeView = [[EditReplyThemeView alloc] initWithStringgId:self.twystId];
    [themeView showInView:self.view];
}

- (void)actionGotoCameraScreen {
    if (self.twystId > 0) {
        [[AppDelegate sharedInstance] goBackToCameraScreenToReply:self.twystId];
    }
    else {
        [[AppDelegate sharedInstance] goBackToCameraScreen];
    }
}

- (void)actionGotoShareScreen {
    _flipframeModel.finalPath = [[FlipframeFileService sharedInstance] generateFinalVideoPath];
    [_videoView pauseVideo];
    
    _flipframeModel.frameTime = _flipframeModel.duration * 1000;
    UIViewController *viewController = nil;
    if ([[FriendManageService sharedInstance] getFriendsCount]) {
        viewController = [[ShareViewController alloc] initWithFlipframeVideoModel:_flipframeModel];
    }
    else {
        viewController = [[ShareEmptyViewController alloc] initWithFlipframeVideoModel:_flipframeModel];
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionGotoReplySentScreen {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.labelReplyHelp3.alpha = 0.0f;
                         self.labelReplyHelp4.alpha = 1.0f;
                         self.btnReplyHome.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         self.btnReplyPass.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                     }];
}

- (void)actionReplyToTwyst {
    
    //apply drawing if user is on drawing mode
    [self applyDrawing];
    
    [self startProgressTimer];
    [_flipframeModel serviceCompileFlipframe:^(NSURL*finalUrl) {
        [self stopProgressTimer];
        _flipframeModel.frameTime = _flipframeModel.duration * 1000;
        
        if (finalUrl) {
            // step 1 : upload video to cloud
            _flipframeModel.finalPath = [[FlipframeFileService sharedInstance] generateFinalVideoPath];
            AzureBlobStorageService *storageService = [AzureBlobStorageService sharedInstance];
            storageService.delegate = self;
            [storageService uploadTwystVideo:_flipframeModel.finalPath withTwystId:self.twystId withCompletion:^(BOOL isSuccess1, NSString* fileName) {
                storageService.delegate = nil;
                if (isSuccess1) {
                    // step 3 : reply to stringg
                    NSString *fileNameBody = [fileName stringByDeletingPathExtension];
                    [[UserWebService sharedInstance] addReplyToTwyst:self.twystId imageCount:1 fileName:fileNameBody isMovie:@"true" frameTime:_flipframeModel.frameTime completion:^(ResponseType response, Twyst *twyst) {
                        if (response == Response_Success) {
                            [_progressReply setProgress:1.0f animated:NO];
                            [[TwystDownloadService sharedInstance] addReplyVideoSuccess:self.twystId flipFrameModel:_flipframeModel fileName:fileNameBody twyst:twyst];
                        }
                        [self handleReplyToStringg:response];
                    }];
                }
                else {
                    [self handleReplyToStringg:Response_NetworkError];
                }
            }];
        }
        else {
            [WrongMessageView showAlert:WrongMessageTypeSomethingWentWrong target:nil];
            self.btnReplyCancel.alpha = 1.0f;
        }
    }];
}

- (void)handleReplyToStringg:(ResponseType)response {
    
    if (response == Response_Success) {
        OCUser *user = [Global getOCUser];
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user.UserName, @"username", [NSString stringWithFormat:@"%ld", self.twystId], @"stringgId", nil];
        [FlurryTrackingService logEvent:FlurryCustomEventAddReply param:param];
        [self actionGotoReplySentScreen];
        [[IANoticeManageService sharedInstance] checkIANManually:nil];
    }
    else if (response == Response_Deleted_Twyst) {
        [WrongMessageView showAlert:WrongMessageTypeTwystDeleted target:nil];
        [self hideReplyingView];
    }
    else {
        [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:self.view arrayOffsetY:@[@0, @0, @0]];
        self.btnReplyCancel.alpha = 1.0f;
    }
}

- (BOOL)isReplying {
    return (self.twystId > DEF_INVALID_TWYST_ID);
}

- (void)applyDrawing {
    if (!self.drawingContainer.hidden) {
        if ([self.drawView isChanged]) {
            UIImage *drawResult = [self.drawView incrementalImage];
            [_videoView setDrawingImage:drawResult];
        }
    }
}

- (void)initReplyView {
    self.btnReplyCancel.alpha = 1.0f;
    self.labelReplyHelp1.alpha = 1.0f;
    self.labelReplyHelp2.alpha = 1.0f;
    self.labelReplyHelp3.alpha = 0.0f;
    self.labelReplyHelp4.alpha = 0.0f;
    
    self.progressReply.trackTintColor           = [UIColor colorWithRed:194/255.0f green:194/255.0f blue:194/255.0f alpha:1.0f];
    self.progressReply.progressTintColor        = [UIColor colorWithRed:49/255.0f green:204/255.0f blue:206/255.0f alpha:1.0f];
    self.progressReply.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    self.progressReply.behavior                 = YLProgressBarBehaviorNonStripe;
    [self.progressReply setProgress:0 animated:NO];
    
    self.btnReplySend.alpha = 1.0f;
    self.btnReplyHome.transform = CGAffineTransformMakeScale(0, 0);
    self.btnReplyPass.transform = CGAffineTransformMakeScale(0, 0);
}

#pragma mark internal drawing methods
- (void)actionRemoveDrawing {
    [self.drawView clear];
    [_videoView setDrawingImage:nil];
    [self reloadDrawingButtonStatus];
}

- (void)reloadDrawingButtonStatus {
    self.btnUndo.enabled = [self.drawView isUndoable];
    self.btnClear.enabled = (self.drawView.isChanged || [_flipframeModel isDrawingExists]);
}

- (void)setDrawingColor:(UIColor*)color {
    UIImage *image = [UIImage imageNamedForDevice:@"btn-edit-effect-draw-hl"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.btnDraw setImage:image forState:UIControlStateSelected];
    self.btnDraw.tintColor = color;
    [self.drawView setLineColor:color];
}

- (void)actionShowDrawingOptions:(BOOL)show {
    CGFloat alpha = show ? 1.0f : 0.0f;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.spectrumView.alpha = alpha;
                         self.drawTopBarContainer.alpha = alpha;
                         self.bottomContainer.alpha = alpha;
                     }];
}

#pragma mark show / hide creating view
- (void)showCreatingView {
    self.viewCreating.alpha = 1.0f;
    [self.imagePretzel startPulseAnimation:0.05 duration:0.4];
}

- (void)hideCreatingView {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.viewCreating.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.imagePretzel stopPulseAnimation];
                     }];
}

#pragma mark show / hide replying view
- (void)showReplyingView {
    [self initReplyView];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.viewReplying.alpha = 1.0f;
                     }];
}

- (void)hideReplyingView {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.viewReplying.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [_videoView playVideo];
                     }];
}

#pragma mark progress timer methods
- (void)startProgressTimer {
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                      target:self
                                                    selector:@selector(onProgressTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopProgressTimer {
    [_progressTimer invalidate];
    _progressTimer = nil;
    [_progressReply setProgress:0.4f animated:YES];
}

- (void)onProgressTimer:(id)sender {
    CGFloat progress = MIN(_progressReply.progress + 0.01f, 0.4f);
    [_progressReply setProgress:progress animated:YES];
}

#pragma mark - button handlers
- (void)FullTutorialViewWillDisappear:(FFullTutorialView *)sender {
    if (sender.type == FullTutorialEditVideoSwipeDown) {
        [sender removeFromSuperview];
        self.tutorialContainer.hidden = YES;
        
        if ([Global getConfig].isFirstEditVideoTime) {
            [Global getConfig].isFirstEditVideoTime = NO;
            [Global saveConfig];
        }
    }
}

- (IBAction)handleBtnCloseTouch:(id)sender  {
    [_videoView pauseVideo];
    [self actionGotoCameraScreen];
}

- (IBAction)handleBtnAdvanceTouch:(id)sender  {
    [_videoView pauseVideo];
    
    if ([self isReplying]) {
        [self showReplyingView];
    }
    else {
        [self actionGotoEditThemeScreen];
    }
}

- (IBAction)handleBtnTrimTouch:(id)sender {
    self.bottomBackground.hidden = YES;
    
    BOOL isCoverSelected = self.btnCover.selected;
    CGRect frame = self.bottomContainer.frame;
    if (!self.btnTrim.selected) {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height;
        self.btnTrim.selected = YES;
        self.btnCover.selected = NO;
    }
    else {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height + self.editorContainer.frame.size.height;
        self.btnTrim.selected = NO;
    }
    
    if (!isCoverSelected) {
        _trimView.alpha = 1;
        _coverView.alpha = 0;
    }
    else {
        [_videoView playVideo];
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.bottomContainer.frame = frame;
                         if (isCoverSelected) {
                             _trimView.alpha = 1;
                             _coverView.alpha = 0;
                         }
                     }];
}

- (IBAction)handleBtnCoverTouch:(id)sender {
    self.bottomBackground.hidden = YES;
    
    BOOL isTrimSelected = self.btnTrim.selected;
    CGRect frame = self.bottomContainer.frame;
    if (!self.btnCover.selected) {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height;
        self.btnCover.selected = YES;
        self.btnTrim.selected = NO;
        [_videoView pauseVideo];
        [_coverView startNewSession];
    }
    else {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height + self.editorContainer.frame.size.height;
        self.btnCover.selected = NO;
        [_videoView playVideo];
    }
    
    if (!isTrimSelected) {
        _coverView.alpha = 1;
        _trimView.alpha = 0;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.bottomContainer.frame = frame;
                         if (isTrimSelected) {
                             _coverView.alpha = 1;
                             _trimView.alpha = 0;
                         }
                     }];
}

- (IBAction)handleBtnDrawTouch:(id)sender {
    self.bottomBackground.hidden = YES;
    
    if (self.drawingContainer.hidden) {
        self.drawingContainer.hidden = NO;
        [self.drawView clear];
        [self reloadDrawingButtonStatus];
        self.btnDraw.selected = YES;
    }
    else {
        if ([self.drawView isChanged]) {
            UIImage *drawResult = [self.drawView incrementalImage];
            [_videoView setDrawingImage:drawResult];
        }
        self.drawingContainer.hidden = YES;
        self.btnDraw.selected = NO;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _topBarContainer.alpha = self.drawingContainer.hidden ? 1 : 0;
                         _drawTopBarContainer.alpha = self.drawingContainer.hidden ? 0 : 1;
                         _buttonContainer.alpha = self.drawingContainer.hidden ? 1 : 0;
                         _drawButtonContainer.alpha = self.drawingContainer.hidden ? 0 : 1;
                         _bottomContainer.frame = CGRectMake(0,
                                                             SCREEN_HEIGHT - _buttonContainer.frame.size.height,
                                                             SCREEN_WIDTH,
                                                             _bottomContainer.frame.size.height);
                     } completion:^(BOOL finished) {
                         _btnTrim.selected = NO;
                         _btnCover.selected = NO;
                         [_videoView playVideo];
                     }];
}

- (IBAction)handleBtnUndoTouch:(id)sender {
    [self.drawView undo];
    [self reloadDrawingButtonStatus];
}

- (IBAction)handleBtnClearAllTouch:(id)sender {
    [_videoView pauseVideo];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Clear all", nil];
    actionSheet.tag = SlideUpTypeEditDrawRemove;
    [actionSheet showInView:self.view];
}

- (IBAction)handleBtnDrawCancelTouch:(id)sender {
    [self.drawView clear];
    [self handleBtnDrawTouch:nil];
}

- (IBAction)handleBtnDrawApplyTouch:(id)sender {
    [self handleBtnDrawTouch:nil];
}

- (IBAction)handleBtnReplyCancelTouch:(id)sender {
    [self hideReplyingView];
}

- (IBAction)handleBtnReplySendTouch:(id)sender {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.labelReplyHelp1.alpha = 0.0f;
                         self.labelReplyHelp2.alpha = 0.0f;
                         self.btnReplyCancel.alpha = 0.0f;
                         self.btnReplySend.alpha = 0.0f;
                         self.labelReplyHelp3.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [self actionReplyToTwyst];
                     }];
}

- (IBAction)handleBtnReplyHomeTouch:(id)sender {
    [[AppDelegate sharedInstance] backToHomeScreen];
    [WrongMessageView showMessage:WrongMessageTypeReplySuccessfully inView:[AppDelegate sharedInstance].window];
}

- (IBAction)handleBtnReplyPassTouch:(id)sender {
    PassTwystViewController *viewController = [[PassTwystViewController alloc] init];
    viewController.isFromPreview = NO;
    viewController.twystId = self.twystId;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Bezier view delegate
- (void)bezierInterpViewDrawDidBegin:(id)sender {
    [self actionShowDrawingOptions:NO];
}

- (void)bezierInterpViewDrawDidEnd:(id)sender {
    [self actionShowDrawingOptions:YES];
    [self reloadDrawingButtonStatus];
}

#pragma mark - HVSpectrumViewDelegate
- (void)spectrumColorSelected:(UIColor *)color {
    [self setDrawingColor:color];
}

#pragma mark - edit trim view delegate
- (void)trimViewDidChange:(id)sender {
    [_videoView updateVideoPlayRange];
}

#pragma mark - edit cover view delegate
- (void)coverFrameDidChange {
    [_videoView updateVideoCoverFrame];
}

#pragma mark - edit theme view delegate
- (void)editThemeViewWillDisapper:(id)sender isConfirm:(BOOL)isConfirm {
    if (isConfirm) {
        
        //apply drawing if user is on drawing mode
        [self applyDrawing];
        
        [self showCreatingView];
        
        [_flipframeModel serviceCompileFlipframe:^(NSURL*finalUrl){
            
            [self hideCreatingView];
            
            if (finalUrl) {
                [self actionGotoShareScreen];
            }
            else {
                [WrongMessageView showAlert:WrongMessageTypeSomethingWentWrong target:nil];
                [_videoView playVideo];
            }
        }];
    }
    else {
        [_videoView playVideo];
    }
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case SlideUpTypeEditDrawRemove:
            if (buttonIndex == 0) {
                [self actionRemoveDrawing];
            }
            break;
        default:
            break;
    }
    [_videoView playVideo];
}

#pragma mark - azure storage service delegate
- (void)storageUploading:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    progress = 0.4f + progress * 0.5;
    [_progressReply setProgress:progress animated:YES];
}

#pragma mark - status bar hidden
- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

- (NMTransitionAnimation *)generateIntroAnimation {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self.view];
    
    [animation addEntranceElement:[NMEntranceElementFadeIn animationWithContainerView:self.view elementView:self.topBarContainer]];
    [animation addEntranceElement:[NMEntranceElementFadeIn animationWithContainerView:self.view elementView:self.bottomContainer]];
    
    return animation;
}

@end
