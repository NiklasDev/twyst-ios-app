//
//  FullProfileImageView.m
//  Twyst
//
//  Created by Niklas Ahola on 1/8/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"

#import "WrongMessageView.h"
#import "FullProfileImageView.h"
#import "ProfileDownloadProgressView.h"

@interface FullProfileImageView()

@property (nonatomic, retain) UIImageView *showImgView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIImageView *ratioView;

@property (nonatomic, assign) CGRect imageFrame;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;

@end

@implementation FullProfileImageView

- (id)initWithProfileName:(NSString*)profileName {
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.profileName = profileName;
        self.limitRatio = 3;
        [self initView];
    }
    return self;
}

- (void)showInView:(UIView*)parent {
    self.alpha = 0;
    [parent addSubview:self];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 1.0f;
                     }];
}

- (void)initView {
    self.backgroundColor = [UIColor blackColor];
    
    self.showImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self addSubview:self.showImgView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 20, 60, 60);
    [closeButton setImage:[UIImage imageNamedContentFile:@"btn-preview-close-on"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamedContentFile:@"btn-preview-close-hl"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(handleBtnCloseTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    [self loadProfileImage];
}

- (void)loadProfileImage {
    __weak typeof(self) weakSelf = self;
    NSURL *fullImageURL = ProfileFullImageURL(self.profileName);
    if ([[SDWebImageManager sharedManager] diskImageExistsForURL:fullImageURL]) {
        [self.showImgView setImageWithURL:fullImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [weakSelf actionDidDownloadImage:image];
        }];
    }
    else {
        [ProfileDownloadProgressView startWithParent:self Completion:^{}];
        [self.showImgView setImageWithURL:ProfileFullImageURL(self.profileName) placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            [weakSelf.processDelegate profileDownloadProgress:receivedSize withTotal:expectedSize];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (error) {
                [weakSelf.processDelegate profileDownloadDidFail];
                [weakSelf.showImgView setImageWithURL:ProfileURL(weakSelf.profileName) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (error) {
                        [WrongMessageView showMessage:WrongMessageTypeNoInternetConnection inView:weakSelf arrayOffsetY:@[@0, @0, @0]];
                    }
                    else {
                        [weakSelf actionDidDownloadImage:image];
                    }
                }];
            }
            else {
                [weakSelf.processDelegate profileDownloadDidComplete];
                [weakSelf actionDidDownloadImage:image];
            }
        }];
    }
}

- (void)actionDidDownloadImage:(UIImage*)image {
    CGFloat width = MIN(image.size.width, self.bounds.size.width);
    
    // fill width
    width = self.bounds.size.width;
    
    self.oldFrame = CGRectMake((self.bounds.size.width - width) / 2,
                                 (self.bounds.size.height - width) / 2,
                                 width,
                                 width);
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    self.imageFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    [self addGestureRecognizers];
}

// register all gestures
- (void) addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.3 animations:^{
            self.showImgView.frame = newFrame;
        }];
    }
}

// pan gesture handler
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.imageFrame.origin.x + self.imageFrame.size.width / 2;
        CGFloat absCenterY = self.imageFrame.origin.y + self.imageFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.imageFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.3 animations:^{
            self.showImgView.frame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.imageFrame.origin.x) newFrame.origin.x = self.imageFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.imageFrame.size.width) newFrame.origin.x = self.imageFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.imageFrame.origin.y) newFrame.origin.y = self.imageFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.imageFrame.origin.y + self.imageFrame.size.height) {
        newFrame.origin.y = self.imageFrame.origin.y + self.imageFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.imageFrame.size.height) {
        newFrame.origin.y = self.imageFrame.origin.y + (self.imageFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

- (void)handleBtnCloseTouch:(UIButton*)sender {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
