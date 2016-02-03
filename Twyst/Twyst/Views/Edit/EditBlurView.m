//
//  EditBlurView.m
//  Twyst
//
//  Created by Niklas Ahola on 8/20/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImage+ImageEffects.h"

#import "PhotoHelper.h"
#import "EditBlurView.h"
#import "EditPhotoService.h"
#import "FlipframePhotoModel.h"

@interface EditBlurView() <UIGestureRecognizerDelegate> {
    NSInteger _imageIndex;
    FlipframePhotoModel *_flipframeModel;
    NSTimer *_timer;
    NSInteger _aniIndex;
}

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOrigin;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBlur;

@property (strong, nonatomic) UIImageView *blurMask;
@property (nonatomic, retain) UIImage *imageOrigin;
@property (nonatomic, retain) UIImage *imageBlur;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;

@end

@implementation EditBlurView

- (id)initWithTarget:(id)target imageIndex:(NSInteger)index {
    NSString *nibName = [FlipframeUtils nibNameForDevice:@"EditBlurView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    self = [subViews firstObject];
    self.delegate = target;
    [self initView:index];
    [self addGestures];
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void) initView:(NSInteger)index {
    _imageIndex = index;
    _flipframeModel = [Global getCurrentFlipframePhotoModel];
    if ([_flipframeModel isBlurAppliedAtIndex:_imageIndex])
        self.imageOrigin = [_flipframeModel serviceGetBackupOriginalImageAtIndex:_imageIndex];
    else
        self.imageOrigin = [_flipframeModel serviceGetFullOriginalImageAtIndex:_imageIndex];
   
    CGRect bounds = [self bounds];
    CGSize imageSize = CGSizeMake(bounds.size.width / 2, DEF_TWYST_IMAGE_HEIGHT * bounds.size.width / DEF_TWYST_IMAGE_WIDTH / 2);
    self.imageBlur = [PhotoHelper resizeImage:self.imageOrigin size:imageSize];
    
    self.topBar.alpha = 0.0f;
    
    self.blurMask = [[UIImageView alloc] initWithFrame:self.frame];
    self.blurMask.image = [UIImage imageNamedForDevice:@"ic-edit-blur-mask"];
    self.blurMask.contentMode = UIViewContentModeScaleAspectFill;
    self.blurMask.transform = CGAffineTransformScale(self.blurMask.transform, 2.0f, 2.0f);
    self.imageViewBlur.layer.mask = self.blurMask.layer;
}

- (void)addGestures {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (UIImage*)blurWithImageEffects:(UIImage *)image tintColor:(UIColor*)tintColor {
    return [image applyBlurWithRadius:1 tintColor:tintColor saturationDeltaFactor:1 maskImage:nil];
}

- (void)blurWithImageEffects:(UIImage*)image tintColor:(UIColor *)tintColor completion:(void(^)(UIImage*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *blurImage = [self blurWithImageEffects:image tintColor:tintColor];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(blurImage);
        });
    });
}

#pragma mark - public methods
- (void)showInView:(UIView*)parent {
    [parent addSubview:self];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.topBar.alpha = 1.0f;
                     }];
    self.imageViewOrigin.image = self.imageOrigin;
    [self blurWithImageEffects:self.imageBlur tintColor:[UIColor colorWithWhite:1.0f alpha:0.8f] completion:^(UIImage *blurImage) {
        self.imageViewBlur.image = blurImage;
        [self startTimer];
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.topBar.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - handle gestures
- (void)handlePanGesture:(UIPanGestureRecognizer*)panRecognizer {
    CGPoint translation = [panRecognizer translationInView:self];
    CGPoint imageViewPosition = self.blurMask.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    self.blurMask.center = imageViewPosition;
    [self fitBlurImageFrame];
    [panRecognizer setTranslation:CGPointZero inView:self];
    [self handleGestureStates:panRecognizer.state];
    
//    if(panRecognizer.state == UIGestureRecognizerStateEnded) {
//        [UIView animateWithDuration:0.4f
//                         animations:^{
//                             self.topBar.alpha = 1;
//                             self.controlView.alpha = 1;
//                         }];
//    } else {
//        [UIView animateWithDuration:0.4f
//                         animations:^{
//                             self.topBar.alpha = 0;
//                             self.controlView.alpha = 0;
//                         }];
//    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)pinchRecognizer {
    CGAffineTransform transform = CGAffineTransformScale(self.blurMask.transform, pinchRecognizer.scale, pinchRecognizer.scale);
    pinchRecognizer.scale = 1.0;
    CGFloat scale = sqrtf(transform.a * transform.a + transform.c * transform.c);
    if (scale < 2) {
        return;
    }
    else if (scale > 8) {
        return;
    }

    self.blurMask.transform = transform;
    [self fitBlurImageFrame];
    [self handleGestureStates:pinchRecognizer.state];
}

- (void)handleTapGesture:(UITapGestureRecognizer*)tapRecognizer {
    CGPoint pt = [tapRecognizer locationInView:self];
    self.blurMask.center = pt;
    [self handleGestureStates:tapRecognizer.state];
}

- (void)fitBlurImageFrame {
    CGRect bounds = [self bounds];
    CGRect frame = self.blurMask.frame;
    if (frame.origin.x > 0) {
        frame.origin.x = 0;
    }
    else if (frame.origin.x + frame.size.width < bounds.size.width) {
        frame.origin.x = bounds.size.width - frame.size.width;
    }
    if (frame.origin.y > 0) {
        frame.origin.y = 0;
    }
    else if (frame.origin.y + frame.size.height < bounds.size.height) {
        frame.origin.y = bounds.size.height - frame.size.height;
    }
    self.blurMask.frame = frame;
}

- (void)handleGestureStates:(UIGestureRecognizerState)state {
    switch (state) {
        case UIGestureRecognizerStateBegan:
            [self touchBegan];
            break;
        case UIGestureRecognizerStateEnded:
            [self touchEnded];
            break;
        default:
            break;
    }
    
    if(state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.topBar.alpha = 1;
                             self.controlView.alpha = 1;
                         }];
    } else {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.topBar.alpha = 0;
                             self.controlView.alpha = 0;
                         }];
    }
}

- (void)touchBegan {
    [self stopTimer];
    [self blurWithImageEffects:self.imageBlur tintColor:[UIColor colorWithWhite:1 alpha:0.8] completion:^(UIImage *blurImage) {
        self.imageViewBlur.image = blurImage;
    }];
}

- (void)touchEnded {
    [self startTimer];
}

#pragma mark - timer methods
- (void)startTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    _aniIndex = 8;
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimer:(id)sender {
    if (_aniIndex == 1) {
        [self stopTimer];
        self.imageViewBlur.image = [self blurWithImageEffects:self.imageBlur tintColor:nil];
    }
    else {
        _aniIndex --;
        self.imageViewBlur.image = [self blurWithImageEffects:self.imageBlur tintColor:[UIColor colorWithWhite:1.0f alpha:0.1 * _aniIndex]];
    }
}

#pragma mark - handle button methods
- (IBAction)handleBtnCancelTouch:(id)sender {
    [self.delegate editBlurViewDidCancelTouch];
    [self hide];
}

- (IBAction)handleBtnApplyTouch:(UIButton *)sender {
    [_flipframeModel backUpOriginalFullImageAtIndex:_imageIndex];
    UIImage *resultImage = [self getResultImage];
    [_flipframeModel serviceReplaceFullOriginalImageAtIndex:_imageIndex newImage:resultImage];
    [_flipframeModel setBlurAppliedAtIndex:_imageIndex isApplied:YES];
    [self.delegate editBlurViewDidApplyTouch];
    [self hide];
}

- (UIImage*)getResultImage {
    @autoreleasepool {
        CGRect frame = CGRectMake(0, 0, DEF_TWYST_IMAGE_WIDTH, DEF_TWYST_IMAGE_HEIGHT);
        CGFloat ratioX = DEF_TWYST_IMAGE_WIDTH / SCREEN_WIDTH;
        CGFloat ratioY = DEF_TWYST_IMAGE_HEIGHT / SCREEN_HEIGHT;
        
        UIImageView *container = [[UIImageView alloc] initWithFrame:frame];
        container.image = self.imageOrigin;
        
        UIImageView *blurContainer = [[UIImageView alloc] initWithFrame:frame];
        blurContainer.image = self.imageViewBlur.image;
        [container addSubview:blurContainer];
        
        CGRect blurFrame = self.blurMask.frame;
        blurFrame = CGRectMake(blurFrame.origin.x * ratioX, blurFrame.origin.y * ratioY, blurFrame.size.width * ratioX, blurFrame.size.height * ratioY);
        UIImageView *maskContainer = [[UIImageView alloc] initWithFrame:blurFrame];
        maskContainer.image = [UIImage imageNamedForDevice:@"ic-edit-blur-mask"];
        maskContainer.contentMode = UIViewContentModeScaleAspectFill;
        blurContainer.layer.mask = maskContainer.layer;
        
        UIGraphicsBeginImageContext(frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [container.layer renderInContext:context];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
