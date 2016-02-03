//
//  EditLargeImageView.m
//  Twyst
//
//  Created by Niklas Ahola on 7/5/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "EditCommentView.h"
#import "EditLargeImageView.h"

@interface EditLargeImageView() <UIGestureRecognizerDelegate> {
    
    FlipframePhotoModel *_flipframeModel;
    
    UIImageView *_previewView;
    
    NSTimer *_touchTimer;
    NSTimeInterval _lastUpdated;
    
    BOOL _isPlaybackDidFinish;
    
    UITapGestureRecognizer *_tapGesture;
    UISwipeGestureRecognizer *_swipeGesture;
    UILongPressGestureRecognizer *_longPressGesture;
    
    BOOL _isCommentTouch;
    BOOL _isEditingComment;
    CGRect _frameCommentView;
}

@end

@implementation EditLargeImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isCommentTouch = NO;
        _isEditingComment = NO;
        [self initView];
    }
    return self;
}

- (void) initView {
    self.backgroundColor = [UIColor blueColor];
    _previewView = [[UIImageView alloc] initWithFrame:self.bounds];
    _previewView.contentMode = UIViewContentModeScaleAspectFill;
    _previewView.clipsToBounds = YES;
    _previewView.userInteractionEnabled = YES;
    [self addSubview:_previewView];
    
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

#pragma mark - public methods
- (void) setSelectedImageIndex:(long)indexl {
    // Set Image
    _flipframeModel = [Global getCurrentFlipframePhotoModel];
    
    _imageIndex = indexl;
    _previewView.image = [self actionLoadImage:_imageIndex];
    
    BOOL isSaved = [self isCurrentFrameSaved];
    [self.delegate editLargeImageViewDidChange:_imageIndex isSaved:isSaved];
}

- (void) saveActiveFrame {
    FlipframePhotoModel *flipframeModel = [Global getCurrentFlipframePhotoModel];
    if ([flipframeModel canSaveFrameAtIndex:self.imageIndex])   {
        [flipframeModel saveSingleFrameAtIndex:self.imageIndex];
        [flipframeModel notifySavedImage:self.imageIndex];
        if ([self.delegate respondsToSelector:@selector(editLargeImageViewFrameSaved:)])  {
            [self.delegate editLargeImageViewFrameSaved:self.imageIndex];
        }
    }
}

- (BOOL) isCurrentFrameSaved {
    BOOL isSaved = ![[Global getCurrentFlipframePhotoModel] canSaveFrameAtIndex:self.imageIndex];
    return isSaved;
}

- (void) reloadImageEffect  {
    if (self.imageIndex >= 0)   {
        _flipframeModel = [Global getCurrentFlipframePhotoModel];
        _previewView.image = [_flipframeModel serviceGetFullImageAtIndex:self.imageIndex];
        
        BOOL isSaved = [self isCurrentFrameSaved];
        [self.delegate editLargeImageViewDidChange:_imageIndex isSaved:isSaved];
    }
}

- (UIImage *) getActiveFrame {
    return _previewView.image;
}

#pragma mark - add / remove gestures
- (void) initGes    {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPreview:)];
    _tapGesture.delegate = self;
    
    _swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownPreview:)];
    _swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    _swipeGesture.delegate = self;
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressPreview:)];
    _longPressGesture.minimumPressDuration = 0.2f;
    _longPressGesture.delegate = self;
    
    [_previewView addGestureRecognizer:_tapGesture];
    [_previewView addGestureRecognizer:_swipeGesture];
    [_previewView addGestureRecognizer:_longPressGesture];
}

- (void) removeGes {
    [_previewView removeGestureRecognizer:_tapGesture];
    [_previewView removeGestureRecognizer:_swipeGesture];
    [_previewView removeGestureRecognizer:_longPressGesture];
}

#pragma mark - handle gesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:_swipeGesture]
        || [gestureRecognizer isEqual:_longPressGesture]
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
        [self actionLoadNextImage];
    }
}

- (void)handleSwipeDownPreview:(UISwipeGestureRecognizer*)swipeGesture {
    NSLog(@" --- swipe preview --- ");
    if (!_isCommentTouch) {
        [self.commentView setFirstResponder];
        _isEditingComment = YES;
    }
}

- (void) handleLongPressPreview:(UILongPressGestureRecognizer*)longPressGesture {
    NSLog(@" --- long press preview --- ");
    switch (_longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self touchBegan];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self touchEnded];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self touchEnded];
        }
            break;
        default:
            break;
    }
}

- (void) touchBegan {
    if (_imageIndex != [self totalFrames] - 1) {
        [self startTimer];
        _isPlaybackDidFinish = NO;
        _lastUpdated = [NSDate timeIntervalSinceReferenceDate];
    }
    else {
        _isPlaybackDidFinish = YES;
    }
}

- (void) touchEnded {
    if (_isPlaybackDidFinish == YES) {
        [self actionLoadNextImage];
    }
    else {
        [self invalidateTimer];
        if ([self.delegate respondsToSelector:@selector(editLargeImageViewLongTapDidCancel)]) {
            [self.delegate editLargeImageViewLongTapDidCancel];
        }
    }
    
    _isPlaybackDidFinish = YES;
}

#pragma mark - touch preview methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@" --- touch began --- ");
    if (!_isEditingComment) {
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
        
        CGRect frame = self.commentView.frame;
        NSString *comment = [self.commentView getComment];
        [_flipframeModel setCommentAtIndex:self.imageIndex comment:comment frame:frame];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@" --- touch cancelled --- ");
}

#pragma mark - internal actions
- (void) actionLoadNextImage  {
    self.imageIndex += 1;
    if (self.imageIndex >= [_flipframeModel.inputService totalImages]) {
        self.imageIndex = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _previewView.image = [self actionLoadImage:_imageIndex];
        [self actionLoadComment];
    });
    _lastUpdated = [NSDate timeIntervalSinceReferenceDate];
    
    BOOL isSaved = [self isCurrentFrameSaved];
    [self.delegate editLargeImageViewDidChange:_imageIndex isSaved:isSaved];
}

- (UIImage*) actionLoadImage:(NSInteger)index {
    return [_flipframeModel serviceGetFullImageAtIndex:index];
}

- (void)actionLoadComment {
    NSString *comment = [_flipframeModel commentTextAtIndex:self.imageIndex];
    CGRect frame = [_flipframeModel commentFrameAtIndex:self.imageIndex];
    [self.commentView setComment:comment frame:frame];
}

- (NSInteger) totalFrames {
    return [_flipframeModel.inputService totalImages];
}

#pragma mark - handle touch timer
- (void) handleTouchTimer:(NSTimer *)timer {
    NSTimeInterval delta = [NSDate timeIntervalSinceReferenceDate] - _lastUpdated;
    [self.delegate editLargeImageViewTimer:MAX(self.timeOn - delta, 0)];
    
    if (delta > _timeOn) {
        if (_imageIndex == [self totalFrames] - 2) {
            [self invalidateTimer];
            _isPlaybackDidFinish = YES;
        }
        [self actionLoadNextImage];
    }
}

- (void)startTimer {
    if (_touchTimer == nil) {
        _touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.001f
                                                       target:self
                                                     selector:@selector(handleTouchTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

- (void)invalidateTimer {
    if (_touchTimer) {
        [_touchTimer invalidate];
        _touchTimer = nil;
    }
}

- (void) dealloc {
    [self removeGes];
    [self removeKeyboardObserver];
    NSLog(@"--- Edit Large Image View Dealloc ---");
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
    CGRect frame = self.commentView.frame;
    NSString *comment = [self.commentView getComment];
    [_flipframeModel setCommentAtIndex:self.imageIndex comment:comment frame:frame];
}

@end
