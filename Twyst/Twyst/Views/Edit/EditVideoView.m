//
//  EditVideoView.m
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "EditCommentView.h"
#import "EditVideoView.h"
#import "FlipframeVideoModel.h"

#import "NSBlockTimer.h"

@interface EditVideoView() <UIGestureRecognizerDelegate> {
    id _videoObserver;
    
    FlipframeVideoModel *_flipframeModel;
    
    UITapGestureRecognizer *_tapGesture;
    UISwipeGestureRecognizer *_swipeGesture;
    
    BOOL _isCommentTouch;
    BOOL _isEditingComment;
    CGRect _frameCommentView;
}

@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerLayer *videoPlayerLayer;

@end

@implementation EditVideoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isCommentTouch = NO;
        _isEditingComment = NO;
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor blackColor];
    
    _flipframeModel = [Global getCurrentFlipframeVideoModel];
    
    self.videoPlayer = [AVPlayer playerWithURL:_flipframeModel.videoURL];
    self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    self.videoPlayerLayer.frame = self.bounds;
    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPlayerLayer.hidden = YES;
    [self.layer addSublayer:self.videoPlayerLayer];
    
    [self.videoPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    //flip video if front camera
    if (_flipframeModel.isMirrored) {
        self.videoPlayerLayer.transform = CATransform3DMakeScale(-1, 1, 1);
    }
    
    self.imageDrawing = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageDrawing.image = _flipframeModel.imageDrawing;
    [self addSubview:self.imageDrawing];
    
    self.commentView = [[EditCommentView alloc] initWithFrame:self.bounds];
    self.commentView.hidden = YES;
    [self addSubview:self.commentView];
    
    [self initGes];
    [self addKeyboardObserver];
}

- (void)setTopBarHeight:(CGFloat)topBarHeight {
    _topBarHeight = topBarHeight;
    self.commentView.topBarHeight = topBarHeight;
}

- (void)setBottomBarHeight:(CGFloat)bottomBarHeight {
    _bottomBarHeight = bottomBarHeight;
    self.commentView.bottomBarHeight = bottomBarHeight;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.videoPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
            self.videoPlayerLayer.hidden = NO;
        } else if (self.videoPlayer.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
        }
    }
}

#pragma mark - public methods
- (void)playVideo {
    [self.videoPlayer play];
}

- (void)pauseVideo {
    [self.videoPlayer pause];
}

- (void)playReverseVideoWithDuration:(CGFloat)duration completion:(void(^)(void))completion {
    [self playReverseVideoWithDuration:duration completion:completion progress:^(CGFloat totalTime, CGFloat currentTime) {}];
}

- (void)playReverseVideoWithDuration:(CGFloat)duration completion:(void (^)(void))completion progress:(void (^)(CGFloat, CGFloat))progress {
    CMTime durTime = self.videoPlayer.currentItem.asset.duration;
    CGFloat realDuration = CMTimeGetSeconds(durTime) - 0.1;
    durTime = CMTimeMakeWithSeconds(realDuration, 600);
    [self.videoPlayer seekToTime:durTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    CGFloat step = 0.05;
    [NSBlockTimer scheduledTimerWithTimeInterval:step scheduledBlock:^(NSTimer *timer) {
        CGFloat currTime = CMTimeGetSeconds(self.videoPlayer.currentTime);
        currTime -= step * (realDuration/duration);
        
        if (currTime > 0) {
            CMTime seekTime = CMTimeMakeWithSeconds(currTime, 600);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.videoPlayer seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                progress(realDuration, currTime);
            });
        } else {
            completion();
            [timer invalidate];
        }
    } userInfo:nil repeats:YES];
}

- (void)updateVideoCoverFrame {
    CMTime seekTime = CMTimeMakeWithSeconds(_flipframeModel.coverFrame, 600);
    [self.videoPlayer seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)updateVideoPlayRange {
    CMTime startTime = CMTimeMakeWithSeconds(_flipframeModel.playStartTime, 30);
    CMTime endTime = CMTimeMakeWithSeconds(_flipframeModel.playEndTime, 30);
    
    [self.videoPlayer seekToTime:startTime];
    
    if (_videoObserver) {
        [self.videoPlayer removeTimeObserver:_videoObserver];
        _videoObserver = nil;
    }
    
    __unsafe_unretained AVPlayer *weakPlayer = _videoPlayer;
    _videoObserver = [self.videoPlayer addBoundaryTimeObserverForTimes:@[ [NSValue valueWithCMTime:endTime] ]
                                                       queue:dispatch_get_main_queue()
                                                  usingBlock:^{
                                                      [weakPlayer seekToTime:startTime
                                                        toleranceBefore:kCMTimeZero
                                                        toleranceAfter:kCMTimeZero
                                                       ];
                                                  }
                   ];
    [self.videoPlayer play];
}

- (void)setDrawingImage:(UIImage*)drawing {
    if (drawing) {
        if (_flipframeModel.imageDrawing) {
            // merge
            _flipframeModel.imageDrawing = [FlipframeUtils applyDrawingOverlay:_flipframeModel.imageDrawing overlay:drawing];
        }
        else {
            _flipframeModel.imageDrawing = drawing;
        }
    }
    else {
        _flipframeModel.imageDrawing = nil;
    }
    self.imageDrawing.image = _flipframeModel.imageDrawing;
}

- (CGFloat)currentPlaybackTime {
    return CMTimeGetSeconds(self.videoPlayer.currentItem.currentTime);
}

- (void)dealloc {
    if (_videoObserver) {
        [self.videoPlayer removeTimeObserver:_videoObserver];
        _videoObserver = nil;
    }
    [self.videoPlayer removeObserver:self forKeyPath:@"status"];
    
    [self removeGes];
    [self removeKeyboardObserver];
    NSLog(@"--- %@ dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - add / remove gestures
- (void) initGes    {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPreview:)];
    _tapGesture.delegate = self;
    
    _swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownPreview:)];
    _swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    _swipeGesture.delegate = self;
    
    [self addGestureRecognizer:_tapGesture];
    [self addGestureRecognizer:_swipeGesture];
}

- (void) removeGes {
    [self removeGestureRecognizer:_tapGesture];
    [self removeGestureRecognizer:_swipeGesture];
}

#pragma mark - handle gesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:_swipeGesture]
        || [gestureRecognizer isEqual:_tapGesture]) {
        return !_isCommentTouch;
    }
    else {
        return YES;
    }
}

- (void) handleTapPreview:(UITapGestureRecognizer*)tapGesture {
    NSLog(@" --- tap preview --- ");
    if (_isEditingComment) {
        [self.commentView resignFirstResponder];
    }
    else {
        // pause / play
    }
}

- (void)handleSwipeDownPreview:(UISwipeGestureRecognizer*)swipeGesture {
    NSLog(@" --- swipe preview --- ");
    if (!_isCommentTouch) {
        [self.commentView setFirstResponder];
        _isEditingComment = YES;
    }
}

#pragma mark - touch view methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_isEditingComment) {
        NSLog(@" --- touch began --- ");
        UITouch *touch = [touches anyObject];
        CGPoint pt = [touch locationInView:self];
        _isCommentTouch = [self.commentView containsPoint:pt];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@" --- touch moved --- ");
    if (_isCommentTouch) {
        UITouch *touch = [touches anyObject];
        CGPoint pt = [touch locationInView:self];
        [self.commentView moveComment:pt];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@" --- touch ended --- ");
    if (_isCommentTouch) {
        UITouch *touch = [touches anyObject];
        CGPoint pt = [touch locationInView:self];
        [self.commentView moveComment:pt];
        
        _flipframeModel.frameComment = self.commentView.frame;
        _flipframeModel.comment = [self.commentView getComment];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@" --- touch cancelled --- ");
}

#pragma mark - show / hide keyboard
- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    _frameCommentView = self.commentView.frame;
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect frameKeyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat height = [FlipframeUtils editCommentHeight];
    CGRect newFrame = CGRectMake(0,
                                 bounds.size.height - height - frameKeyboard.size.height,
                                 bounds.size.width,
                                 height);
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.commentView.frame = newFrame;
                     } completion:^(BOOL finished) {
                         self.commentView.userInteractionEnabled = YES;
                     }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.commentView.frame = _frameCommentView;
        self.commentView.userInteractionEnabled = NO;
    });
}

- (void)keyboardDidHide:(NSNotification*)notification {
    _isEditingComment = NO;
    _flipframeModel.frameComment = self.commentView.frame;
    _flipframeModel.comment = [self.commentView getComment];
}

@end
