//
//  TwystPreviewView.m
//  Twyst
//
//  Created by Niklas Ahola on 8/27/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImage+animatedGIF.h"

#import "TTwystOwner.h"
#import "TTwystOwnerManager.h"
#import "TStillframeRegular.h"
#import "TSavedTwystManager.h"

#import "FlipframeFileService.h"
#import "TwystDownloadService.h"

#import "TwystPreviewView.h"
#import "WDActivityIndicator.h"

@interface TwystPreviewView() <UIGestureRecognizerDelegate> {
    FFlipframeSavedLibrary *_flipframeLibrary;
    TSavedTwyst *_savedTwyst;
    
    NSInteger _dataSourceType;
    NSArray *_dataSource;
    
    CGRect _frameMovieNormal;
    
    UIImageView *_previewView;
    UIView *_videoContainer;
    UIView *_loadMoreView;
    
    NSTimeInterval _frameTime;
    
    NSTimer *_touchTimer;
    NSTimeInterval _lastUpdated;
    NSTimeInterval _pauseTimeInterval;
    
    id _videoObserver;
    
    BOOL _isLoadMore;
    BOOL _isViewStart;
    BOOL _isMovie;
    
    UITapGestureRecognizer *_tapGesture;
    UISwipeGestureRecognizer *_swipeUpGesture;
    UISwipeGestureRecognizer *_swipeDownGesture;
    UISwipeGestureRecognizer *_swipeLeftGesture;
    UISwipeGestureRecognizer *_swipeRightGesture;
}

@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerLayer *videoLayer;

@property (nonatomic, strong) AVPlayer *preloadVideoPlayer;
@property (nonatomic, strong) AVPlayerLayer *preloadVideoLayer;

@end

@implementation TwystPreviewView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        frame.origin.y = 0;
        _frameMovieNormal = frame;
        _isViewStart = NO;
        _isComplete = YES;
        
        [self initView];
    }
    
    return self;
}

- (void)initView {
    self.backgroundColor = Color(18, 18, 18);
    
    _previewView = [[UIImageView alloc] initWithFrame:_frameMovieNormal];
    _previewView.contentMode = UIViewContentModeScaleAspectFill;
    _previewView.clipsToBounds = YES;
    [self addSubview:_previewView];
    
    _videoContainer = [[UIView alloc] initWithFrame:_frameMovieNormal];
    _videoContainer.backgroundColor = Color(18, 18, 18);
    [self addSubview:_videoContainer];
    
    [self initGes];
    [self addNotifications];
}

- (void) dealloc {
    [self removeGes];
    [self removeNotifications];
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - setter
- (void)setIsComplete:(BOOL)isComplete {
    _isComplete = isComplete;
    if (!_isComplete) {
        _loadMoreView = [[UIView alloc] initWithFrame:_frameMovieNormal];
        _loadMoreView.backgroundColor = [UIColor clearColor];
        _loadMoreView.hidden = YES;
        [self addSubview:_loadMoreView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_frameMovieNormal];
        imageView.image = [UIImage imageNamedContentFile:@"ic-black-transparent-overlay"];
        [_loadMoreView addSubview:imageView];
        
        UIImageView *imageIndicator = [[UIImageView alloc] initWithFrame:[self frameTwystGif]];
        NSURL *gifUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"twyst_loading_white" ofType:@"gif"]];
        imageIndicator.image = [UIImage animatedImageWithAnimatedGIFURL:gifUrl];
        [_loadMoreView addSubview:imageView];
    }
}

- (CGRect)frameTwystGif {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            return CGRectMake(159, 209, 56, 43);
            break;
        case DeviceTypePhone6Plus:
            return CGRectMake(179, 232, 56, 43);
            break;
        default:
            return CGRectMake(132, 174, 56, 43);
            break;
    }
}

#pragma mark - public methods
- (void)enableSwipeGestures {
    _swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipePreview:)];
    _swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:_swipeUpGesture];
    
    _swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipePreview:)];
    _swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:_swipeDownGesture];
    
    _swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipePreview:)];
    _swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:_swipeLeftGesture];
    
    _swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipePreview:)];
    _swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:_swipeRightGesture];
}

- (void)setDataSourceWithFlipframeLibrary:(FFlipframeSavedLibrary *)flipframeLibrary {
    _dataSourceType = 2;
    _flipframeLibrary = flipframeLibrary;
    
    FFlipframeSaved *flipframeSaved = [_flipframeLibrary flipframeSaved];
    NSSet *setStillframes = flipframeSaved.libraryTwyst.listStillframeRegular;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    _dataSource = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (void)setDataSourceWithSavedTwyst:(TSavedTwyst*)savedTwyst {
    _dataSourceType = 3;
    _savedTwyst = savedTwyst;
    
    NSSet *setStillframes = savedTwyst.listStillframeRegular;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *arrStillframes = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    _dataSource = arrStillframes;
    
    if ([self isSinglePhotoTwyst]) {
        [self actionCheckPreviewDidStart];
    }
}

- (void)setSelectedImageIndex:(long)indexl {
    _imageIndex = indexl;
    [self actionLoadFrame:self.imageIndex];
}

- (void)reloadSelectedImage {
    [self actionLoadFrame:self.imageIndex];
}

- (UIImage*)getActiveFrame {
    return _previewView.image;
}

- (UIImage*) getPreviewSnapShot {
    if (_isMovie) {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self.videoPlayer.currentItem.asset];
        generator.maximumSize = CGSizeMake(DEF_TWYST_VIDEO_WIDTH, DEF_TWYST_VIDEO_HEIGHT);
        generator.appliesPreferredTrackTransform = YES;
        CGImageRef cgIm = [generator copyCGImageAtTime:self.videoPlayer.currentTime
                                            actualTime:nil
                                                 error:nil];
        UIImage *image = [UIImage imageWithCGImage:cgIm];
        CGImageRelease(cgIm);
        
        return image;
    }
    else {
        return _previewView.image;
    }
}

- (void)pause {
    [self invalidateTimer];
    if (_isMovie && self.videoPlayer.rate == 1.0f) {
        [self.videoPlayer pause];
    }
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    _pauseTimeInterval = now - _lastUpdated;
    [self.delegate twystPreviewDidPause];
}

- (void)play {
    [self startTimer];
    if (_isMovie && self.videoPlayer.rate == 0.0f) {
        [self.videoPlayer play];
    }
}

- (void)resume {
    [self resumeTimer];
    if (_isMovie && self.videoPlayer.rate == 0.0f) {
        [self.videoPlayer play];
    }
    
    [self.delegate twystPreviewDidResume];
}

#pragma mark - add / remove gestures
- (void)initGes {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPreview:)];
    _tapGesture.delegate = self;
    
    [self addGestureRecognizer:_tapGesture];
}

- (void)removeGes {
    [self removeGestureRecognizer:_tapGesture];
    
    if (_swipeUpGesture)
        [self removeGestureRecognizer:_swipeUpGesture];
    if (_swipeDownGesture)
        [self removeGestureRecognizer:_swipeDownGesture];
    if (_swipeLeftGesture)
        [self removeGestureRecognizer:_swipeLeftGesture];
    if (_swipeRightGesture)
        [self removeGestureRecognizer:_swipeRightGesture];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:_tapGesture]) {
        return ![self isSinglePhotoTwyst];
    }
    return YES;
}

- (void)handleTapPreview:(UITapGestureRecognizer*)tapGesture {
    [self actionLoadNextImage];
}

- (void)handleSwipePreview:(UISwipeGestureRecognizer*)swipeGesture {
    if ([self.delegate respondsToSelector:@selector(twystPreviewDidSwipe:)]) {
        [self.delegate twystPreviewDidSwipe:swipeGesture.direction];
    }
}

#pragma mark - internal methods for data source
- (NSInteger)totalFrames {
    return [_dataSource count];
}

#pragma mark - internal actions
- (BOOL)isSinglePhotoTwyst {
    if ([self totalFrames] == 1) {
        TStillframeRegular *stillframe = [_dataSource firstObject];
        if ([stillframe.isMovie boolValue] == NO) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSingleVideoTwyst {
    if ([self totalFrames] == 1) {
        TStillframeRegular *stillframe = [_dataSource firstObject];
        if ([stillframe.isMovie boolValue] == YES) {
            return YES;
        }
    }
    return NO;
}

- (void)actionCheckPreviewDidStart {
    if (_isViewStart == NO) {
        _isViewStart = YES;
        if ([self.delegate respondsToSelector:@selector(twystPreviewDidView:)]) {
            [self.delegate twystPreviewDidView:self];
        }
    }
}

- (void)actionLoadNextImage  {
    [self actionCheckPreviewDidStart];
    
    self.imageIndex += 1;
    if (self.imageIndex >= [self totalFrames]) {
        if (_isComplete) {
            self.imageIndex = 0;
        }
        else {
            // load more
            [self actionLoadMore];
            [self invalidateTimer];
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self actionLoadFrame:_imageIndex];
    });
    _lastUpdated = [NSDate timeIntervalSinceReferenceDate];
}

- (void)actionLoadFrame:(NSInteger)index {
    if ([_dataSource count] <= index) {
        return;
    }
    
    FlipframeFileService *fileService = [FlipframeFileService sharedInstance];
    TStillframeRegular *stillframe = [_dataSource objectAtIndex:index];
    
    _frameTime = [stillframe.frameTime integerValue] / 1000.0f;
    NSLog(@"frame time = %.3f", _frameTime);
    
    // check if reported
    NSArray *paths = [stillframe.path componentsSeparatedByString:@"/"];
    NSString *replyName = [paths objectAtIndex:2];
    if ([[Global getInstance].reportedReplies containsObject:replyName]) {
        _previewView.image = [UIImage imageNamedForDevice:@"ic-frame-reported"];
        _previewView.hidden = NO;
        [self removeMoviePlayer];
        return;
    }
    
    _isMovie = [stillframe.isMovie boolValue];
    if (_isMovie) {
        _previewView.hidden = YES;
        [self removeMoviePlayer];
        
        NSString *fullPath = [[FlipframeFileService sharedInstance] generateFullDocPath:stillframe.path];
        NSURL *videoUrl = [NSURL fileURLWithPath:fullPath];
        [self addMoviePlayer:videoUrl];
    }
    else {
        _previewView.hidden = NO;
        [self removeMoviePlayer];
        @autoreleasepool {
            NSString *fullPath = [fileService generateFullDocPath:stillframe.path];
            NSData *data = [NSData dataWithContentsOfFile:fullPath];
            _previewView.image = [UIImage imageWithData:data];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(twystPreviewDidChange:frameTime:)]) {
        long userId = [stillframe.userId longValue];
        TTwystOwner *owner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:userId];
        [self.delegate twystPreviewDidChange:owner.profilePicName frameTime:_frameTime];
    }
}

- (void)actionLoadMore {
    [self showLoadMore:YES];
    Twyst *twyst = [[TSavedTwystManager sharedInstance] getTwystFromTSavedTwyst:_savedTwyst];
    [[TwystDownloadService sharedInstance] downloadFriendTwyst:twyst isUrgent:YES];
}

- (void)showLoadMore:(BOOL)show {
    _loadMoreView.hidden = !show;
}

- (void)addMoviePlayer:(NSURL*)videoUrl {
    if (self.preloadVideoPlayer) {
        self.videoPlayer = self.preloadVideoPlayer;
    }
    else {
        self.videoPlayer = [AVPlayer playerWithURL:videoUrl];
        self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    
    if (self.preloadVideoLayer) {
        self.videoLayer = self.preloadVideoLayer;
    }
    else {
        self.videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        self.videoLayer.frame = self.bounds;
        self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    [_videoContainer.layer addSublayer:self.videoLayer];
    _videoContainer.hidden = NO;
    
    [self.videoPlayer play];
    
    [self actionCheckPreviewDidStart];
    
    __weak typeof(self) weakSelf = self;
    CMTime endTime = self.videoPlayer.currentItem.asset.duration;
    _videoObserver = [self.videoPlayer addBoundaryTimeObserverForTimes:@[ [NSValue valueWithCMTime:endTime] ]
                                                                 queue:dispatch_get_main_queue()
                                                            usingBlock:^{
                                                                [weakSelf actionLoadNextImage];
                                                            }];
}

- (void)removeMoviePlayer {
    if (_videoObserver) {
        [self.videoPlayer removeTimeObserver:_videoObserver];
        _videoObserver = nil;
    }
    [self.videoPlayer pause];
    [self.videoLayer removeFromSuperlayer];
    _videoContainer.hidden = YES;
}

#pragma mark - add / remove / handle notification methods
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDidDownload:)
                                                 name:kFriendTwystDidDownloadNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDownloadFailed:)
                                                 name:kFriendTwystDownloadFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystFrameReported:)
                                                 name:kTwystFrameReportNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kFriendTwystDidDownloadNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kFriendTwystDownloadFailNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystFrameReportNotification
                                                  object:nil];
}

- (void)handleTwystDidDownload:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    long twystId = [_savedTwyst.twystId longValue];
    if (twyst.Id == twystId) {
        BOOL isComplete = [[notification.userInfo objectForKey:@"isComplete"] boolValue];
        _isComplete = isComplete;
        TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:twystId];
        [self setDataSourceWithSavedTwyst:savedTwyst];
        [self setSelectedImageIndex:self.imageIndex];
        [self showLoadMore:NO];
        [self startTimer];
    }
}

- (void)handleTwystDownloadFailed:(NSNotification*)notification {
    Twyst *twyst = [notification.userInfo objectForKey:@"Twyst"];
    long twystId = [_savedTwyst.twystId longValue];
    if (twyst.Id == twystId) {
        [self showLoadMore:NO];
        self.imageIndex = 0;
        [self setSelectedImageIndex:self.imageIndex];
        [self showLoadMore:NO];
    }
}

- (void)handleTwystFrameReported:(NSNotification*)notification {
    [self reloadSelectedImage];
}

#pragma mark - handle touch timer
- (void) handleTouchTimer:(NSTimer *)timer {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (!_isMovie) {
        if (now - _lastUpdated > _frameTime) {
            [self actionLoadNextImage];
        }
    }
}

- (void)startTimer {
    [self invalidateTimer];
    _lastUpdated = [NSDate timeIntervalSinceReferenceDate];
    _touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                   target:self
                                                 selector:@selector(handleTouchTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)resumeTimer {
    [self invalidateTimer];
    _lastUpdated = [NSDate timeIntervalSinceReferenceDate] - _pauseTimeInterval;
    _touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                   target:self
                                                 selector:@selector(handleTouchTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)invalidateTimer {
    if (_touchTimer) {
        [_touchTimer invalidate];
        _touchTimer = nil;
    }
}

@end