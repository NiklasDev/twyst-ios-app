//
//  EditPhotoViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 8/12/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIView+Animation.h"
#import "UIImage+Device.h"

#import "AppDelegate.h"

#import "ZipService.h"
#import "UserWebService.h"
#import "FriendManageService.h"
#import "FlipframeFileService.h"
#import "IANoticeManageService.h"
#import "TwystDownloadService.h"
#import "LibraryFlipframeServices.h"
#import "AzureBlobStorageService.h"
#import "FlurryTrackingService.h"

#import "EditBlurView.h"
#import "EditFilterView.h"
#import "WrongMessageView.h"
#import "EditLargeImageView.h"
#import "FFullTutorialView.h"
#import "EditThemeView.h"
#import "HVSpectrumView.h"
#import "BezierInterpView.h"
#import "CircleProcessingView.h"
#import "MNEValueTrackingSlider.h"
#import "YLProgressBar.h"

#import "ShareViewController.h"
#import "ShareEmptyViewController.h"
#import "EditPhotoViewController.h"
#import "EditFramesViewController.h"
#import "PassTwystViewController.h"

@interface EditPhotoViewController () <FFullTutorialViewDelegate, EditBlurViewDelegate, EditFilterViewDelegate, EditThemeViewDelegate, BezierInterpViewDelegate, HVSpectrumViewDelegate, EditLargeImageViewDelegate, AzureStorageServiceDelegate,MNEValueTrackingSliderDelegate, UIActionSheetDelegate>   {
    
    EditFilterView *_filterView;
    EditLargeImageView *_editLargeImageView;
    
    FlipframePhotoModel *_flipframeModel;
    BOOL _isCompletedInit;
    BOOL _buttonWasTouched;
    
    UIView *_rabbitView;
    
    MNEValueTrackingSlider *_slider;
    NSInteger _timeOn;
}

@property (weak, nonatomic) IBOutlet UIImageView *introPreviewImageView;

@property (weak, nonatomic) IBOutlet UIView *topBarContainer;
@property (weak, nonatomic) IBOutlet UIView *drawTopBarContainer;
@property (weak, nonatomic) IBOutlet UIView *largeImageContainer;
@property (weak, nonatomic) IBOutlet UIView *drawingContainer;
@property (weak, nonatomic) IBOutlet UIView *blurContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIView *drawButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *filterContainer;
@property (weak, nonatomic) IBOutlet UIView *tutorialContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomBackground;
@property (weak, nonatomic) IBOutlet UIView *frameTimerContainer;
@property (weak, nonatomic) IBOutlet UILabel *labelFrameTimer;

@property (weak, nonatomic) IBOutlet BezierInterpView *drawView;
@property (weak, nonatomic) IBOutlet HVSpectrumView *spectrumView;

@property (weak, nonatomic) IBOutlet UIButton *btnRabbit;
@property (weak, nonatomic) IBOutlet UIButton *btnSun;
@property (weak, nonatomic) IBOutlet UIButton *btnBlur;
@property (weak, nonatomic) IBOutlet UIButton *btnFilter;
@property (weak, nonatomic) IBOutlet UIButton *btnDraw;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UIButton *btnOrigin;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;
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

@implementation EditPhotoViewController

- (id)initWithParent:(UIViewController*) inParent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"EditPhotoViewController-3.5inch" : [FlipframeUtils nibNameForDevice:@"EditPhotoViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        _timeOn = 3000;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    [self addKeyboardObserver];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardObserver];
}

- (void) viewDidDisappear:(BOOL)animated    {
    [super viewDidDisappear:animated];
}

#pragma mark - init view
- (void) initView {
    _frameTimerContainer.layer.cornerRadius = 4;
    _frameTimerContainer.layer.masksToBounds = YES;
    
    CGRect frame = self.filterContainer.frame;
    frame.origin = CGPointZero;
    _filterView = [[EditFilterView alloc] initWithFrame:frame];
    _filterView.delegate = self;
    [self.filterContainer addSubview:_filterView];
    _filterView.alpha = 0;
    
    self.drawView.delegate = self;
    [self.drawView setLineColor:Color(0, 185, 172)];
    self.spectrumView.delegate = self;
    
    _isCompletedInit = YES;
    _buttonWasTouched = NO;
    [self startNewSession];
    [self initRabbitView];
    [self actionShowTutorial];
}

- (void) startNewSession    {
    if (!_isCompletedInit)
        return;
    
    _flipframeModel = [Global getCurrentFlipframePhotoModel];
    
    [_flipframeModel.inputService startNotify];
    
    [_filterView startNewSession];
    
    [self addEditLargeView];
    
    _btnSun.selected = [_flipframeModel isSun];
}

- (void) addEditLargeView {
    if (_editLargeImageView) {
        [_editLargeImageView removeFromSuperview];
    }
    
    _editLargeImageView = [[EditLargeImageView alloc] initWithFrame:self.view.bounds];
    _editLargeImageView.topBarHeight = self.topBarContainer.frame.size.height;
    _editLargeImageView.bottomBarHeight = self.buttonContainer.frame.size.height;
    _editLargeImageView.timeOn = 3.0f;
    [self.largeImageContainer addSubview:_editLargeImageView];
    _editLargeImageView.delegate = self;
    [_editLargeImageView setSelectedImageIndex:0];
}

- (void)setIntroPreviewImage:(UIImage *)introPreviewImage {
    _introPreviewImage = introPreviewImage;
    [self.introPreviewImageView setImage:introPreviewImage];
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

#pragma mark - Internal Actions
- (void)actionShowTutorial {
    if ([Global getConfig].isFirstEditTime) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialEditPlayback withTarget:self withSelector:nil];
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

- (void)actionGotoEditFrameScreen {
    EditFramesViewController *viewController = [[EditFramesViewController alloc] initWithInputService:_flipframeModel parent:self];
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)actionGotoEditThemeScreen {
    EditThemeView *themeView = [[EditThemeView alloc] initWithParent:self.view];
    themeView.delegate = self;
    [themeView show];
}

- (void)actionGotoShareScreen  {
    UIViewController *viewController = nil;
    FlipframePhotoModel *flipframeModel = [Global getCurrentFlipframePhotoModel];
    flipframeModel.frameTime = _timeOn;
    if ([[FriendManageService sharedInstance] getFriendsCount]) {
        viewController = [[ShareViewController alloc] initWithFlipframePhotoModel:flipframeModel];
    }
    else {
        viewController = [[ShareEmptyViewController alloc] initWithFlipframePhotoModel:flipframeModel];
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionGotoCameraScreen {
    if (self.twystId > 0) {
        [[AppDelegate sharedInstance] goBackToCameraScreenToReply:self.twystId];
    }
    else {
        [[AppDelegate sharedInstance] goBackToCameraScreen];
    }
}

- (void)actionFrameDeleted {
    [_editLargeImageView setSelectedImageIndex:0];
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
    
    // apply drawing if user is on drawing mode
    [self applyDrawing];
    
    [_flipframeModel serviceCompileFlipframe:^{
  
        // step 1 : zip photos
        [_progressReply setProgress:0.1 animated:YES];
        NSString *zipPath = [[FlipframeFileService sharedInstance] generateTwystZipFilePath:self.twystId];
        [[ZipService sharedInstance] zipFilesWithFlipframeModel:_flipframeModel withOutput:zipPath];
        
        // step 2 : upload zip file to cloud
        AzureBlobStorageService *storageService = [AzureBlobStorageService sharedInstance];
        storageService.delegate = self;
        [storageService uploadTwyst:zipPath withTwystId:self.twystId withCompletion:^(BOOL isSuccess1, NSString* fileName) {
            storageService.delegate = nil;
            if (isSuccess1) {
                [_progressReply setProgress:0.9 animated:YES];
                
                // step 3 : reply to stringg
                NSString *fileNameBody = [fileName stringByDeletingPathExtension];
                NSInteger imageCount = _flipframeModel.totalFrames;
                [[UserWebService sharedInstance] addReplyToTwyst:self.twystId imageCount:imageCount fileName:fileNameBody isMovie:@"false" frameTime:_timeOn completion:^(ResponseType response, Twyst *twyst) {
                    if (response == Response_Success) {
                        [_progressReply setProgress:1.0f animated:YES];
                        [[TwystDownloadService sharedInstance] addReplySuccess:self.twystId flipFrameModel:_flipframeModel fileName:fileNameBody twyst:twyst];
                    }
                    [self handleReplyToStringg:response];
                }];
            }
            else {
                [self handleReplyToStringg:Response_NetworkError];
            }
        }];
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
            [_flipframeModel applyDrawingAtIndex:_editLargeImageView.imageIndex drawOverlay:drawResult];
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

- (void)updateFrameTimer:(CGFloat)time {
    _labelFrameTimer.text = [NSString stringWithFormat:@"%.2fs", time];
}

#pragma mark internal drawing methods
- (void)actionRestoreOrigin {
    [_flipframeModel removeDrawingAtIndex:[_editLargeImageView imageIndex]];
    [self.drawView clear];
    [self reloadDrawingButtonStatus];
    [_editLargeImageView reloadImageEffect];
}

- (void)actionApplyAll {
    if ([self.drawView isChanged]) {
        UIImage *drawResult = [self.drawView incrementalImage];
        [CircleProcessingView showInView:self.view];
        [_flipframeModel applyDrawingToAll:drawResult competion:^{
            [CircleProcessingView hide];
            [self.drawView clear];
            [self reloadDrawingButtonStatus];
            [_editLargeImageView reloadImageEffect];
        }];
    }
}

- (void)actionRemoveAll {
    [CircleProcessingView showInView:self.view];
    [_flipframeModel removeAllDrawing:^{
        [CircleProcessingView hide];
        [self.drawView clear];
        [self reloadDrawingButtonStatus];
        [_editLargeImageView reloadImageEffect];
    }];
}

- (void)reloadDrawingButtonStatus {
    self.btnUndo.enabled = [self.drawView isUndoable];
    self.btnOrigin.enabled = (self.drawView.isChanged || [_flipframeModel isDrawAppliedAtIndex:_editLargeImageView.imageIndex]);
    self.btnApply.enabled = self.drawView.isChanged;
    self.btnClear.enabled = (self.drawView.isChanged || [_flipframeModel isDrawAppliedAtIndex:_editLargeImageView.imageIndex]);
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

- (void)actionRemoveBlurEffect {
    NSInteger imageIndex = [_editLargeImageView imageIndex];
    [_flipframeModel serviceRestoreBackUpImageAtIndex:imageIndex];
    [_flipframeModel setBlurAppliedAtIndex:imageIndex isApplied:NO];
    self.btnBlur.selected = NO;
    [_editLargeImageView reloadImageEffect];
}

#pragma mark show / hide creating view
- (void)showCreatingView {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.viewCreating.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [self.imagePretzel startPulseAnimation:0.05 duration:0.4];
                     }];
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
                     }];
}

#pragma mark -
- (void)actionUpdateBlurViews {
    
    NSInteger imageIndex = [_editLargeImageView imageIndex];
    if (self.blurContainer.hidden) {
        self.blurContainer.hidden = NO;
        self.btnRabbit.enabled = NO;
        self.btnSun.enabled = NO;
        self.btnFilter.enabled = NO;
        self.btnDraw.enabled = NO;
        self.btnBlur.selected = YES;
        
        EditBlurView *blurView = [[EditBlurView alloc] initWithTarget:self imageIndex:imageIndex];
        blurView.controlView = self.bottomContainer;
        [blurView showInView:_blurContainer];
        
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _bottomContainer.frame = CGRectMake(0,
                                                                 SCREEN_HEIGHT - _buttonContainer.frame.size.height,
                                                                 SCREEN_WIDTH,
                                                                 _bottomContainer.frame.size.height);
                             self.frameTimerContainer.alpha = 0;
                         } completion:^(BOOL finished) {
                             _btnFilter.selected = NO;
                             _btnRabbit.selected = NO;
                         }];
    }
    else {
        self.blurContainer.hidden = YES;
        self.btnRabbit.enabled = YES;
        self.btnSun.enabled = YES;
        self.btnFilter.enabled = YES;
        self.btnDraw.enabled = YES;
        self.frameTimerContainer.alpha = 1.0f;
        self.btnBlur.selected = [_flipframeModel isBlurAppliedAtIndex:imageIndex];
    }
    [self actionShowTopBar:self.blurContainer.hidden];
}


#pragma mark - button handlers
- (void)FullTutorialViewWillDisappear:(FFullTutorialView *)sender {
    
    [sender removeFromSuperview];
    if (sender.type == FullTutorialEditPlayback) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialEditPhotoSwipeDown withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else if (sender.type == FullTutorialEditPhotoSwipeDown) {
        self.tutorialContainer.hidden = YES;
        
        if ([Global getConfig].isFirstEditTime) {
            [Global getConfig].isFirstEditTime = NO;
            [Global saveConfig];
        }
    }
}

- (IBAction)handleBtnCloseTouch:(id)sender  {
    [self actionGotoCameraScreen];
}

- (IBAction)handleBtnAdvanceTouch:(id)sender  {
    if ([self isReplying]) {
        [self showReplyingView];
    }
    else {
        [self actionGotoEditThemeScreen];
    }
}

- (IBAction)handleBtnFramesTouch:(id)sender {
    [self actionGotoEditFrameScreen];
}

- (IBAction)handleBtnRabbitTouch:(id)sender {
    self.bottomBackground.hidden = YES;
    
    BOOL isFilterSelected = self.btnFilter.selected;
    CGRect frame = self.bottomContainer.frame;
    if (!self.btnRabbit.selected) {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height;
        self.btnRabbit.selected = YES;
        self.btnSun.enabled = YES;
        self.btnBlur.enabled = YES;
        self.btnFilter.enabled = YES;
        self.btnFilter.selected = NO;
        self.btnDraw.enabled = YES;
    }
    else {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height + self.filterContainer.frame.size.height;
        self.btnRabbit.selected = NO;
    }
    
    if (!isFilterSelected) {
        _filterView.alpha = 0;
        _rabbitView.alpha = 1;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.bottomContainer.frame = frame;
                         if (isFilterSelected) {
                             _filterView.alpha = 0;
                             _rabbitView.alpha = 1;
                         }
                     }];
}

- (IBAction)handleBtnSunTouch:(UIButton *)sender  {
    _flipframeModel.isSun = ![_flipframeModel isSun];
    sender.selected = [_flipframeModel isSun];
    
    //update filter
    [_editLargeImageView reloadImageEffect];
}

- (IBAction)handleBtnBlurTouch:(id)sender {
    self.bottomBackground.hidden = YES;
    
    NSInteger imageIndex = [_editLargeImageView imageIndex];
    if ([_flipframeModel isBlurAppliedAtIndex:imageIndex]) {
        [self actionRemoveBlurEffect];
    }
    else {
        [self actionUpdateBlurViews];
    }
}

- (IBAction)handleBtnFilterTouch:(id)sender {
    self.bottomBackground.hidden = YES;
    
    BOOL isRabbitSelected = self.btnRabbit.selected;
    CGRect frame = self.bottomContainer.frame;
    if (!self.btnFilter.selected) {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height;
        self.btnFilter.selected = YES;
        self.btnRabbit.enabled = YES;
        self.btnRabbit.selected = NO;
        self.btnSun.enabled = YES;
        self.btnBlur.enabled = YES;
        self.btnDraw.enabled = YES;
    }
    else {
        frame.origin.y = SCREEN_HEIGHT - frame.size.height + self.filterContainer.frame.size.height;
        self.btnFilter.selected = NO;
    }
    
    if (!isRabbitSelected) {
        _filterView.alpha = 1;
        _rabbitView.alpha = 0;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.bottomContainer.frame = frame;
                         if (isRabbitSelected) {
                             _filterView.alpha = 1;
                             _rabbitView.alpha = 0;
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
            [_flipframeModel applyDrawingAtIndex:_editLargeImageView.imageIndex drawOverlay:drawResult];
            [_editLargeImageView reloadImageEffect];
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
                         _frameTimerContainer.alpha = self.drawingContainer.hidden ? 1 : 0;
                     } completion:^(BOOL finished) {
                         _btnFilter.selected = NO;
                         _btnRabbit.selected = NO;
                     }];
}

- (IBAction)handleBtnUndoTouch:(id)sender {
    [self.drawView undo];
    [self reloadDrawingButtonStatus];
}

- (IBAction)handleBtnOriginTouch:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Revert to original", nil];
    actionSheet.tag = SlideUpTypeEditDrawRemove;
    [actionSheet showInView:self.view];
}

- (IBAction)handleBtnApplyAllTouch:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Apply to all", nil];
    actionSheet.tag = SlideUpTypeEditDrawApplyAll;
    [actionSheet showInView:self.view];
}

- (IBAction)handleBtnClearAllTouch:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Clear all", nil];
    actionSheet.tag = SlideUpTypeEditDrawRemoveAll;
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
                         _flipframeModel.frameTime = _timeOn;
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

#pragma mark - delegate Edit Large Image
- (void) editLargeImageViewDidChange:(NSInteger)selectedIndex isSaved:(BOOL)isSaved {
    if (selectedIndex == 0) {
        [self updateFrameTimer:_editLargeImageView.timeOn];
    }
//    else if (selectedIndex < [_flipframeModel totalFrames] - 1 ) {
        [self.frameTimerContainer bounceAnimation:0.2f];
//    }
    
    self.btnBlur.selected = [_flipframeModel isBlurAppliedAtIndex:selectedIndex];
}

- (void) editLargeImageViewTimer:(CGFloat)time {
    [self updateFrameTimer:time];
}

- (void) editLargeImageViewLongTapDidCancel {
    [self updateFrameTimer:_editLargeImageView.timeOn];
}

#pragma mark - blur effect delegate
- (void)editBlurViewDidCancelTouch {
    [self actionUpdateBlurViews];
}

- (void)editBlurViewDidApplyTouch {
    [_editLargeImageView reloadImageEffect];
    [self actionUpdateBlurViews];
}

#pragma mark - filter view delegate
- (void) editFilderView:(id)sender didSelect:(NSInteger)index {
    [_editLargeImageView reloadImageEffect];
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

#pragma mark - edit theme view delegate
- (void) editThemeViewDidDisapper:(id)sender isConfirm:(BOOL)isConfirm {
    if (isConfirm) {
        
        // apply drawing if user is on drawing mode
        [self applyDrawing];
        
        [self showCreatingView];
        
        [_flipframeModel serviceCompileFlipframe:^{
            
            [self hideCreatingView];
            
            if ([Global getConfig].isSaveVideo) {
                [_flipframeModel serviceEncodeFlipframe];
            }
            [self actionGotoShareScreen];
        }];
    }
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case SlideUpTypeEditDrawRemove:
            if (buttonIndex == 0) {
                [self actionRestoreOrigin];
            }
            break;
        case SlideUpTypeEditDrawApplyAll:
            if (buttonIndex == 0) {
                [self actionApplyAll];
            }
            break;
        case SlideUpTypeEditDrawRemoveAll:
            if (buttonIndex == 0) {
                [self actionRemoveAll];
            }
            break;
        default:
            break;
    }
}

#pragma mark - azure storage service delegate
- (void)storageUploading:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    progress = 0.1f + progress * 0.8;
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

- (void)initRabbitView {
    CGSize size = self.filterContainer.frame.size;
    _rabbitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.filterContainer addSubview:_rabbitView];
    
    UIImageView *imageBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamedForDevice:@"ic-edit-time-on"]];
    imageBackground.frame = CGRectMake(0, 0, size.width, size.height);
    imageBackground.contentMode = UIViewContentModeTop;
    [_rabbitView addSubview:imageBackground];
    
    CGRect sliderFrame = CGRectZero;
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            sliderFrame = CGRectMake(42, 63, 291, 30);
            break;
        case DeviceTypePhone6Plus:
            sliderFrame = CGRectMake(47, 74, 320, 30);
            break;
        default:
            sliderFrame = CGRectMake(40, 60, 244, 30);
            break;
    }
    _slider = [[MNEValueTrackingSlider alloc] initWithFrame:sliderFrame];
    _slider.delegate = self;
    _slider.tintColor = Color(0, 185, 172);
    [_rabbitView addSubview:_slider];
    
    self.btnRabbit.selected = YES;
}

#pragma mark - MNEValueTrackingSlider
- (void)sliderView:(MNEValueTrackingSlider *)slider valueDidChange:(CGFloat)value {
    _timeOn = value * 1000;
    _editLargeImageView.timeOn = value;
    _labelFrameTimer.text = [NSString stringWithFormat:@"%.2fs", value];
}

#pragma mark - Animation

- (NMTransitionAnimation *)generateIntroAnimation {
    NMEntranceTransitionAnimation *animation = [NMEntranceTransitionAnimation animationWithContainerView:self.view];
    
    [animation addEntranceElement:[NMEntranceElementFadeIn animationWithContainerView:self.view elementView:self.topBarContainer]];
    [animation addEntranceElement:[NMEntranceElementFadeIn animationWithContainerView:self.view elementView:self.bottomContainer]];
    [animation addEntranceElement:[NMEntranceElementFadeIn animationWithContainerView:self.view elementView:self.largeImageContainer]];
    
    return animation;
}



@end
