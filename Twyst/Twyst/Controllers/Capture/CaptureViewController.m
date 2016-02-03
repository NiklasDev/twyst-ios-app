//
//  CaptureViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 6/20/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "AppDelegate.h"

#import "UIImage+Device.h"

#import "PhotoRegularService.h"
#import "AppPermissionService.h"

#import "RCounter.h"
#import "WrongMessageView.h"
#import "CameraUploadView.h"
#import "CameraFocusLayout.h"
#import "CameraCaptureButton.h"
#import "CameraVideoProgressBar.h"

#import "FFullTutorialView.h"
#import "PhotoImportCircleProgress.h"

#import "CaptureViewController.h"
#import "EditPhotoViewController.h"
#import "EditVideoViewController.h"
#import "ELCImagePickerController.h"
#import "CameraDeleteFramesViewController.h"

#import "NMTransitionManager+Headers.h"
#import "EditVideoView.h"
#import "NSBlockTimer.h"

@interface CaptureViewController () <FFullTutorialViewDelegate, CameraCaptureButtonDelegate, CameraFocusLayoutDelegate, PhotoRegularServiceDelegate, CameraUploadViewDelegate, CameraManagerManageDelegate, ELCImagePickerControllerDelegate, UIActionSheetDelegate> {
    
    #warning This is used to avoid openining the camera when it mustn't
    BOOL shouldLoadCameraPreview;
    
    //views
    CameraFocusLayout *_viewCamera;
    CameraUploadView *_cameraUploadView;
    
    //fake camera capture view
    UIView *_flashView;
    
    //camera start animation view
    CGRect _frameTopAniView;
    CGRect _frameBottomAniView;
    UIView *_topAnimationView;
    UIView *_bottomAnimationView;
    
    //camera
    CameraManager *_cameraManager;
    AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
    UIImageView *_viewGhost;
    
    //service
    PhotoRegularService *_photoRegularService;
    
    BOOL _isRegularStarted;
    
    BOOL _isInit;
    
    NSInteger _frameCounter;
    CGFloat _frameCounterFontScale;
    
    long _twystId;        //to reply stringg id : stringg id > 0 when reply mode
}


@property (nonatomic, strong) RCounter *labelFrameCount;
@property (weak, nonatomic) IBOutlet UIView *cameraContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (weak, nonatomic) IBOutlet UIButton *btnFlip;
@property (weak, nonatomic) IBOutlet UIButton *btnGhost;
@property (weak, nonatomic) IBOutlet UIButton *btnFlash;

@property (weak, nonatomic) IBOutlet UIButton *btnUpload;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnAdvance;

@property (weak, nonatomic) IBOutlet UIImageView *menuSeparator;

@property (weak, nonatomic) IBOutlet CameraCaptureButton *btnShutter;
@property (weak, nonatomic) IBOutlet CameraVideoProgressBar *videoProgressBar;

@property (nonatomic, weak) IBOutlet UIView *tutorialContainer;

@property (nonatomic, strong) ELCImagePickerController *imagePicker;

@end

@implementation CaptureViewController

- (void)setShouldNotLoadCameraPreview {
#warning This is used to avoid openining the camera when it mustn't
    shouldLoadCameraPreview = NO;
}

- (id)init {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"CaptureViewController-3.5inch" : [FlipframeUtils nibNameForDevice:@"CaptureViewController"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        shouldLoadCameraPreview = YES;
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
    
    if (shouldLoadCameraPreview) {
        if (!_cameraManager
            && [[AppPermissionService sharedInstance] isCameraEnable]
            && [[AppPermissionService sharedInstance] isMicroPhoneEnable]) {
            [self initCamera];
        }
        
        [self prepareCameraStartAnimation];
        [_cameraManager start];
    }
    shouldLoadCameraPreview = YES;
}

- (void) viewDidAppear:(BOOL)animated   {
    [super viewDidAppear:animated];
    [self performSelector:@selector(actionCameraStartAnimation) withObject:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_cameraManager stop];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_cameraManager stop];
}

- (void) dealloc {
    
}

#pragma Init views
- (void) initView   {
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height;
    self.view.backgroundColor = Color(96, 92, 168);
    
    //MID - preview
    CGRect framePreview = CGRectMake(0, 0, width, height);
    _viewCamera = [[CameraFocusLayout alloc] initWithFrame:framePreview];
    _viewCamera.delegate = self;
    [self.cameraContainer addSubview:_viewCamera];
//    [self initCamera];
    
    //MID - Ghost Image View
    _viewGhost = [[UIImageView alloc] initWithFrame:framePreview];
    _viewGhost.contentMode = UIViewContentModeScaleAspectFill;
    _viewGhost.alpha = 0.3;
    _viewGhost.hidden = YES;
    [self.cameraContainer addSubview:_viewGhost];

    //MID - Camera start animation views
    _frameTopAniView = CGRectMake(0, 0, width, framePreview.size.height / 2);
    _frameBottomAniView = CGRectMake(0, framePreview.size.height / 2, width, framePreview.size.height / 2);
    
    _topAnimationView = [[UIView alloc] initWithFrame:_frameTopAniView];
    _topAnimationView.backgroundColor = [UIColor blackColor];
    [self.cameraContainer addSubview:_topAnimationView];
    
    _bottomAnimationView = [[UIView alloc] initWithFrame:_frameBottomAniView];
    _bottomAnimationView.backgroundColor = [UIColor blackColor];
    [self.cameraContainer addSubview:_bottomAnimationView];

    // camera capture button
    self.btnShutter.delegate = self;
    
    CGRect frameUploadView = CGRectMake(0, 0, width, height);
    _cameraUploadView = [[CameraUploadView alloc] initWithFrame:frameUploadView];
    _cameraUploadView.delegate = self;
    
    //fake flash view
    _flashView = [[UIView alloc] initWithFrame:_viewCamera.bounds];
    _flashView.backgroundColor = [UIColor blackColor];
    _flashView.alpha = 0;
    [self.cameraContainer addSubview:_flashView];
    
    //add frame counter
    [self addFrameCountLabel];
}

- (void) initCamera {
    //init camera
    _cameraManager = [[CameraManager alloc] init];
    BOOL isBack = (self.captureType == CameraCaptureTypeRegular ? YES : NO);
    if (_cameraManager != nil)
    {
        if ([_cameraManager setupSession:isBack])    {
            //create video preview layer
            _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[_cameraManager session]];
            CGRect frame = _viewCamera.bounds;
			[_captureVideoPreviewLayer setFrame:frame];
			_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [_viewCamera.layer addSublayer:_captureVideoPreviewLayer];
            
            _cameraManager.manageDelegate = self;
            if (![_cameraManager supportFlashOn]) {
                self.btnFlash.enabled = NO;
            }
        }
        
        // Photo capture service
        _photoRegularService = [[PhotoRegularService alloc] initWithCameraManager:_cameraManager];
        _photoRegularService.photoBurstDelegate = self;
        
        //start new session
        _isInit = YES;
        [self startNewSession:self.captureType];
    }
}

#pragma mark - Public Methods
- (void) startNewSession {
    _twystId = DEF_INVALID_TWYST_ID;
    [self startNewSession:CameraCaptureTypeRegular];
}

- (void) startNewSessionToReply:(long)twystId {
    _twystId = twystId;
    [self startNewSession:CameraCaptureTypeRegular];
}

- (void) startNewSession:(CameraCaptureType) captureType    {
    self.captureType = captureType;
    _isRegularStarted = NO;
    _frameCounter = 0;
    
    // reset video progress bar
    self.videoProgressBar.hidden = YES;
    [self.view bringSubviewToFront:self.videoProgressBar];
    [self.videoProgressBar setProgress:0];
    
    if (!_isInit)   {
        return;
    }
    
    [self actionStartNewSession];
    [self actionShowTutorial];
}

- (void) actionStartNewSession  {
    //default burst mode
    if (self.captureType == CameraCaptureTypeRegular) {
        [self actionSwitchRegularMode];
    }
}

- (void) actionSwitchRegularMode  {
    [self actionCameraRegularResetAll];
}

//MARK: front flash
- (void) lunchFlash    {
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:VAL_CAMERA_FLASH_OPACITY];
    fadeAnim.toValue = [NSNumber numberWithFloat:0];
    fadeAnim.duration = 0;

    [_flashView.layer addAnimation:fadeAnim forKey:@"opacity"];
}

- (void)actionShowTutorial {
    UIView *view = [self.tutorialContainer viewWithTag:100];
    if (view)
        [view removeFromSuperview];
    
    if ([Global getConfig].isFirstTwystTime) {
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialCameraTapPhoto withTarget:self withSelector:nil];
        tutorialView.tag = 100;
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
        self.tutorialContainer.hidden = NO;
    }
    else {
        [self actionShowReplyTutorial];
    }
}

- (void)actionShowReplyTutorial {
    //tutorial
    if ([Global getConfig].isFirstCameraReplyTime && (_twystId > 0)) {
        if ([self.tutorialContainer viewWithTag:300] == nil) {
            FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialCameraReply withTarget:self withSelector:nil];
            tutorialView.tag = 300;
            tutorialView.delegate = self;
            [self.tutorialContainer addSubview:tutorialView];
        }
        self.tutorialContainer.hidden = NO;
    }
    else {
        self.tutorialContainer.hidden = YES;
    }
}

- (void)addFrameCountLabel {
    CGRect frame = CGRectZero;
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            _frameCounterFontScale = 25.0f / 14.0f;;
            frame = CGRectMake(315, 7, 30, 30);
            break;
        case DeviceTypePhone6Plus:
            _frameCounterFontScale = 29.0f / 14.0f;
            frame = CGRectMake(351, 8, 30, 30);
            break;
        default:
            _frameCounterFontScale = 25.0f / 14.0f;;
            frame = CGRectMake(264, 7, 30, 30);
            break;
    }
    
    self.labelFrameCount = [[RCounter alloc] initWithFrame:frame andNumberOfDigits:2];
    self.labelFrameCount.backgroundColor = [UIColor clearColor];
    self.labelFrameCount.layer.anchorPoint = CGPointMake(0.35, 0.2);
    self.labelFrameCount.transform = CGAffineTransformMakeScale(_frameCounterFontScale, _frameCounterFontScale);
    [self.view addSubview:self.labelFrameCount];
    [self.labelFrameCount updateCounter:0 animate:NO];
}

- (void) actionUpdateCounter:(NSInteger) counter  {
    if (self.captureType == CameraCaptureTypeRegular) {
        if (counter > 0)    {
            //counter bubble in first time
            if (self.labelFrameCount.hidden) {
                [self.labelFrameCount updateCounter:counter animate:NO];
                self.labelFrameCount.transform = CGAffineTransformMakeScale(0, 0);
                self.labelFrameCount.hidden = NO;
                [UIView animateWithDuration:0.2f animations:^{
                    self.labelFrameCount.transform = CGAffineTransformMakeScale(_frameCounterFontScale, _frameCounterFontScale);
                }];
            }
            else {
                [self.labelFrameCount updateCounter:counter animate:YES];
            }
        }   else    {
            self.labelFrameCount.hidden = YES;
        }
        _btnUpload.enabled = (counter < DEF_COUNT_MAX_FRAME);
    }
}

- (void) actionRotate   {
    [_cameraManager toggleCamera];
}

#pragma mark - button handlers
- (void)FullTutorialViewWillDisappear:(FFullTutorialView *)sender {
    if (sender.type == FullTutorialCameraTapPhoto) {
        [sender removeFromSuperview];
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialCameraHoldVideo withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else if (sender.type == FullTutorialCameraHoldVideo) {
        [sender removeFromSuperview];
        FFullTutorialView *tutorialView = [[FFullTutorialView alloc] initWithType:FullTutorialCameraEcho withTarget:self withSelector:nil];
        tutorialView.delegate = self;
        [self.tutorialContainer addSubview:tutorialView];
    }
    else if (sender.type == FullTutorialCameraEcho) {
        [sender removeFromSuperview];
        if ([Global getConfig].isFirstTwystTime)  {
            [Global getConfig].isFirstTwystTime = NO;
            [Global saveConfig];
        }
        [self actionShowReplyTutorial];
    }
    else if (sender.type == FullTutorialCameraReply) {
        [sender removeFromSuperview];
        if ([Global getConfig].isFirstCameraReplyTime)  {
            [Global getConfig].isFirstCameraReplyTime = NO;
            [Global saveConfig];
        }
        self.tutorialContainer.hidden = YES;
    }
}

- (IBAction)handleBtnCloseCameraTouch:(id)sender {
    if (self.captureType == CameraCaptureTypeRegular) {
        [self actionGoHomeScreen];
    }
}

- (IBAction)handleBtnRotateTouch:(id)sender   {
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    [self actionRotate];
}

- (IBAction)handleBtnGhostTouch:(id)sender {
    _viewGhost.hidden = !_viewGhost.hidden;
    if (_viewGhost.hidden) {
        [_btnGhost setImage:[UIImage imageNamedForDevice:@"btn-camera-bat-on"] forState:UIControlStateNormal];
        _viewGhost.image = nil;
    }
    else {
        [_btnGhost setImage:[UIImage imageNamedForDevice:@"btn-camera-bat-hl"] forState:UIControlStateNormal];
    }
}

- (IBAction)handleBtnFlashTouch:(id)sender {
    if ([_cameraManager isFlashOn]) {
        [_btnFlash setImage:[UIImage imageNamedForDevice:@"btn-camera-flash-off"] forState:UIControlStateNormal];
        [_cameraManager flashOff]; 
    }
    else {
        [_btnFlash setImage:[UIImage imageNamedForDevice:@"btn-camera-flash-on"] forState:UIControlStateNormal];
        [_cameraManager flashOn];
    }
}

- (IBAction)handleBtnDeleteTouch:(id)sender   {
    if (self.captureType == CameraCaptureTypeRegular) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Delete Frames", @"Discard All", nil];
        actionSheet.tag = SlideUpTypeCameraRegularDelete;
        [actionSheet showInView:self.view];
    }
}

- (IBAction)handleBtnUploadTouch:(id)sender {
    if (_frameCounter >= DEF_COUNT_MAX_FRAME) {
        if (![WrongMessageView checkIfShowed]) {
            [WrongMessageView showAlert:WrongMessageTypeTwystOverMaxFrames target:nil];
        }
        return;
    }
    
    if (!_cameraUploadView.superview) {
        [_cameraUploadView showInView:self.view];
    }
}

- (IBAction)handleBtnAdvanceTouch:(id)sender    {
    [self actionGotoEditScreenWithRegular];
}

#pragma mark - Camera actions

- (void) actionCameraRegularResetAll {
    [self actionCameraBurstStopAll];
    
    [_photoRegularService prepareNewRegularCapture];
    [self actionUpdateCounter:0];
    _btnUpload.hidden = NO;
    
    _btnDelete.hidden = YES;
    _btnAdvance.hidden = YES;
    
    _viewGhost.image = nil;
    _viewGhost.hidden = YES;
    [_btnGhost setImage:[UIImage imageNamedForDevice:@"btn-camera-bat-on"] forState:UIControlStateNormal];
    _btnGhost.enabled = YES;
    
    [self.btnShutter enableVideoCapturing:YES];
}

- (void) actionCameraRegualrStartFirst {
    _isRegularStarted = YES;
    
    //bubble in delete and advance buttons
    _btnDelete.transform = CGAffineTransformMakeScale(0, 0);
    _btnAdvance.transform = CGAffineTransformMakeScale(0, 0);
    _btnDelete.hidden = NO;
    _btnAdvance.hidden = NO;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         _btnDelete.transform = CGAffineTransformMakeScale(1, 1);
                         _btnAdvance.transform = CGAffineTransformMakeScale(1, 1);
                     }];
    
    [self actionCameraRegularStart];
}

- (void) actionCameraRegularStart {
    [_photoRegularService captureRegularPhoto];
}

- (void) actionCameraBurstStopAll {
    _isRegularStarted = NO;
}

- (void) prepareCameraStartAnimation {
    [_topAnimationView setHidden:NO];
    [_bottomAnimationView setHidden:NO];
    
    [_topAnimationView setFrame:_frameTopAniView];
    [_bottomAnimationView setFrame:_frameBottomAniView];
}

- (void) actionCameraStartAnimation {
    CGRect topDestRect = CGRectMake(0, _frameTopAniView.origin.y - _frameTopAniView.size.height, _frameTopAniView.size.width, _frameTopAniView.size.height);
    CGRect bottomDestRect = CGRectMake(0, _frameBottomAniView.origin.y + _frameBottomAniView.size.height, _frameBottomAniView.size.width, _frameBottomAniView.size.height);
    
    [UIView animateWithDuration:0.2f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [_topAnimationView setFrame:topDestRect];
                         [_bottomAnimationView setFrame:bottomDestRect];
                     }
                     completion:^(BOOL finished) {
                         [_topAnimationView setHidden:YES];
                         [_bottomAnimationView setHidden:YES];
                     }];
}

#pragma mark - camera capture button delegate
- (void)CameraCapturePhoto {
    if (_frameCounter >= DEF_COUNT_MAX_FRAME) {
        if (![WrongMessageView checkIfShowed]) {
            [WrongMessageView showAlert:WrongMessageTypeTwystOverMaxFrames target:nil];
        }
        return;
    }
    
    if ([Global getInstance].isCancelCameraProcessing)  {
        [Global getInstance].isCancelCameraProcessing = NO;
    }
    
    if (self.captureType == CameraCaptureTypeRegular) {
        if (!_isRegularStarted)   {
            [self actionCameraRegualrStartFirst];
        }   else {
            [self actionCameraRegularStart];
        }
    }
}

- (void)CameraCaptureVideoStart {
    self.videoProgressBar.hidden = NO;
    [_cameraManager captureVideoStart];
}

- (void)CameraCaptureVideoEnd {
    [_cameraManager captureVideoEnd];
}

#pragma mark - region Handle go to edit screen
//action goto
- (void) actionGotoEditScreenWithRegular  {
    [[Global getInstance] startNewFlipframeModel:FlipframeInputTypePhotoRegular withService:_photoRegularService];
    [self actionGoToEditScreen];
}

- (void) actionGotoEditScreenWithVideoURL:(NSURL*)videoURL duration:(CGFloat)duration isCapture:(BOOL)isCapture isMirrored:(BOOL)isMirrored {
    [[Global getInstance] startNewFlipframeModel:FlipframeInputTypeVideo withVideoURL:videoURL duration:duration isCapture:isCapture isMirrored:isMirrored];
    [self actionGotoEditVideoScreen];
}

- (void) actionGoToEditScreen   {
    EditPhotoViewController *editPhotoViewController = [[EditPhotoViewController alloc] initWithParent:self];
    editPhotoViewController.twystId = _twystId;
    [editPhotoViewController view]; // force view to load
    UIImage *currentPreview = [self captureCurrentPreview];
    editPhotoViewController.introPreviewImage = currentPreview;
    
    NMSimpleTransition *transition = [[NMSimpleTransition alloc] init];
    transition.fromAnimation = [self generateCapturePhotoOutroAnimation:currentPreview];
    transition.toAnimation = [editPhotoViewController generateIntroAnimation];
    
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [self.navigationController pushViewController:editPhotoViewController animated:NO];
        completion();
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

- (void) actionGotoEditVideoScreen {
    EditVideoViewController *editVideoViewController = [[EditVideoViewController alloc] initWithParent:self];
    editVideoViewController.twystId = _twystId;
    [editVideoViewController view]; // force view to load
    
    NMSimpleTransition *transition = [[NMSimpleTransition alloc] init];
    transition.fromAnimation = [self generateCaptureVideoOutroAnimation];
    transition.toAnimation = [editVideoViewController generateIntroAnimation];
    [transition setTransitionBlock:^(void(^completion)(void)) {
        [self.navigationController pushViewController:editVideoViewController animated:NO];
        completion();
    }];
    [[NMTransitionManager sharedInstance] beginTransition:transition];
}

- (void) actionGoHomeScreen  {
    //disable all
    [Global getInstance].isCancelCameraProcessing = YES;
    [[AppDelegate sharedInstance] closeCameraScreen];
}

#pragma mark - Transitions

- (NMCustomTransitionAnimation *)generateCapturePhotoOutroAnimation:(UIImage *)currentPreview {
    
    UIImageView *freezedPreviewImageView = [[UIImageView alloc] initWithImage:currentPreview];
    freezedPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
    freezedPreviewImageView.frame = self.cameraContainer.frame;
    [self.view insertSubview:freezedPreviewImageView aboveSubview:self.cameraContainer];
    freezedPreviewImageView.alpha = 0.0;
    
    NMCustomTransitionAnimation *cameraAnimation = [NMCustomTransitionAnimation animationWithContainerView:self.view];
    [cameraAnimation setAnimationBlock:^(void(^completion)(void)) {
        [UIView animateWithDuration:0.5 animations:^{
            [self setMenuItemsHidden:YES];
            freezedPreviewImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            completion();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self setMenuItemsHidden:NO];
                [freezedPreviewImageView removeFromSuperview];
            });
        }];
    }];
    
    return cameraAnimation;
}

- (NMCustomTransitionAnimation *)generateCaptureVideoOutroAnimation {
    
    NSURL *videoUrl = [Global getCurrentFlipframeVideoModel].videoURL;
    UIImageView *freezedPreviewImageView = [[UIImageView alloc] initWithImage:[_cameraManager getVideoThumbnail:videoUrl]];
    freezedPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
    freezedPreviewImageView.frame = self.cameraContainer.frame;
    [self.view insertSubview:freezedPreviewImageView aboveSubview:self.cameraContainer];
    freezedPreviewImageView.alpha = 0.0;
    
    self.videoProgressBar.hidden = YES;
    NMCustomTransitionAnimation *cameraAnimation = [NMCustomTransitionAnimation animationWithContainerView:self.view];
    [cameraAnimation setAnimationBlock:^(void(^completion)(void)) {
        [UIView animateWithDuration:0.5 animations:^{
            [self setMenuItemsHidden:YES];
            freezedPreviewImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            completion();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self setMenuItemsHidden:NO];
                [freezedPreviewImageView removeFromSuperview];
            });
        }];
    }];
    
    return cameraAnimation;
/*    NMCustomTransitionAnimation *cameraAnimation = [NMCustomTransitionAnimation animationWithContainerView:self.view];
    [cameraAnimation setAnimationBlock:^(void(^completion)(void)) {
        
        CGFloat duration = 1.0;
        
        [UIView animateWithDuration:duration animations:^{
            [self setMenuItemsHidden:YES];
        } completion:^(BOOL finished) {
        }];
                
        EditVideoView *videoView = [[EditVideoView alloc] initWithFrame:self.view.bounds];
        videoView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:videoView aboveSubview:self.cameraContainer];
        [videoView playReverseVideoWithDuration:duration completion:^{
            self.videoProgressBar.hidden = YES;
            completion();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self setMenuItemsHidden:NO];
                [videoView removeFromSuperview];
            });
        } progress:^(CGFloat totalTime, CGFloat currentTime) {
            [self captureVideoDuration:currentTime];
        }];
    }];
    
    return cameraAnimation;*/
}

- (UIImage *)captureCurrentPreview {
    FlipframePhotoModel *flipframePhotoModel = [Global getCurrentFlipframePhotoModel];
    return [flipframePhotoModel serviceGetFullImageAtIndex:0];
}

- (void)setMenuItemsHidden:(BOOL)hidden {
    CGFloat alpha = hidden ? 0.0 : 1.0;
    self.labelFrameCount.alpha = alpha;
    self.btnClose.alpha = alpha;
    self.btnGhost.alpha = alpha;
    self.btnFlash.alpha = alpha;
    self.btnUpload.alpha = alpha;
    self.btnDelete.alpha = alpha;
    self.btnAdvance.alpha = alpha;
    self.btnShutter.alpha = alpha;
    self.btnFlip.alpha = alpha;
    self.menuSeparator.alpha = alpha;
}

#pragma mark - handle to go delete frames
- (void) actionDeleteRegularFrames {
    CameraDeleteFramesViewController * deleteFrameViewController = [[CameraDeleteFramesViewController alloc] initWithInputService:_photoRegularService];
    [self.navigationController presentViewController:deleteFrameViewController animated:YES completion:nil];
}

#pragma mark - Delegate Camera manager
- (void) reverseCamera:(AVCaptureDevicePosition)position {
    [_viewCamera reverseCamera];
}

- (void) adjustFocusDidFinish {
    [_viewCamera adjustFocusDidFinish];
}

- (void) captureVideoDidFinish:(NSURL*)videoURL duration:(NSTimeInterval)duration {
    [self.btnShutter changeButtonState:CameraButtonStateNormal];
    if (duration < 1.0f) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Ooops, your video must be at least 1 second long. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [self startNewSession:_captureType];
    }
    else {
        BOOL isMirrored = ![_cameraManager checkIfCameraBack];
        [self actionGotoEditScreenWithVideoURL:videoURL duration:duration isCapture:YES isMirrored:isMirrored];
    }
}

- (void) captureVideoDuration:(NSTimeInterval)duration {
    CGFloat progress = duration / DEF_VIDEO_MAX_LEN;
    [self.videoProgressBar setProgress:progress];
}

#pragma mark - camera focus preview touch delegate
- (void) cameraPreviewDidTouch:(CGPoint)point   {
    [_cameraManager focus:point];
}

#pragma mark - action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SlideUpTypeCameraRegularDelete) {
        if (buttonIndex == 0) {
            [self actionDeleteRegularFrames];
        }
        else if (buttonIndex == 1) {
            [_photoRegularService deleteAllFrames];
        }
    }
}

#pragma mark - burst delegate
- (void) photoRegularServiceUpdateCounter:(NSInteger) counter   {
    _frameCounter = counter;
    [self actionUpdateCounter:_frameCounter];
}

- (void) photoRegularServiceCaptureNew    {
    [self lunchFlash];
    [self.btnShutter enableVideoCapturing:NO];
}

- (void) photoRegularServiceNotifyAllSegmentDeleted   {
    [self actionCameraRegularResetAll];
}

- (void) photoRegularServiceCaptureWithRawImage:(UIImage *)rawImage {
    if (_viewGhost.hidden == NO)
    {
        rawImage = [self fixOrientation:rawImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_viewGhost setImage:rawImage];
        });
    }
}

- (void) photoRegularServiceCaptureResult:(UIImage *)image {
    
}

- (void) photoRegularServicePhotoDidImport {
    _viewGhost.image = nil;
    //_btnUpload.hidden = YES;
    _btnDelete.hidden = NO;
    _btnAdvance.hidden = NO;
}

#pragma mark - Fix Image Orientation To Ghost Effect
- (UIImage *) fixOrientation:(UIImage *)image {
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        {
            image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationRight];
        }
            break;
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationRightMirrored:
        {
            image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationLeftMirrored];
        }
            break;
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
        {
            // Do nothing
        }
            break;
        default:
            break;
    }
    return image;
}

#pragma mark - upload view delegate
- (void) uploadVideoDidTouch {
    ELCImagePickerController *elcImagePicker = [[ELCImagePickerController alloc] initImagePicker];
    elcImagePicker.imagePickerDelegate = self;
    elcImagePicker.maximumImagesCount = 1;
    elcImagePicker.mediaTypes = @[(NSString*)kUTTypeMovie];
    [self.navigationController presentViewController:elcImagePicker animated:YES completion:nil];
}

- (void) uploadPhotoDidTouch {
    NSInteger maximumImagesCount = DEF_COUNT_MAX_FRAME - _frameCounter;
    ELCImagePickerController *elcImagePicker = [[ELCImagePickerController alloc] initImagePicker];
    elcImagePicker.returnsOriginalImage = YES;
    elcImagePicker.imagePickerDelegate = self;
    elcImagePicker.maximumImagesCount = maximumImagesCount;
    [self.navigationController presentViewController:elcImagePicker animated:YES completion:nil];
}

#pragma mark - ELC image picker controller delegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([picker.mediaTypes containsObject:((NSString*)kUTTypeMovie)]) {
        [self actionImportVideoFromCameraRoll:info];
    }
    else {
        [self actionImportPhotoFromCameraRoll:info];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Import photo methods
- (void)actionImportPhotoFromCameraRoll:(NSArray *)assets {
    [_photoRegularService fetchPhotosFromCameraRoll:assets];
    dispatch_async(dispatch_get_main_queue(), ^{
        [PhotoImportCircleProgress startWithParent:self.view
                                 withImportService:_photoRegularService Completion:^{
                                     
                                 }];
    });
}

- (void)actionImportVideoFromCameraRoll:(NSArray*)assets {
    ALAsset *asset = [assets firstObject];
    CGFloat duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    NSURL *assetURL = [assetRep url];
    [self actionGotoEditScreenWithVideoURL:assetURL duration:duration isCapture:NO isMirrored:NO];
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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

@end
