//
//  LogoView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "NSString+Extension.h"

#import "LogoView.h"
#import "LoginView.h"
#import "SignupView.h"
#import "InviteCodeView.h"

#import "LandingPageControl.h"

#import "NMTransitionManager.h"
#import "NMSimpleTransition.h"
#import "NMColorBurstTransitionAnimation.h"

@interface LogoView() <UIScrollViewDelegate> {
    CGFloat _phoneCenterY;
    NSInteger _currentPage;
    NSMutableArray *_arrayCenters;
    
    NSTimeInterval _lastUpdated;
    NSTimer *_timer;
    BOOL _isAnimated;
    BOOL _isStop;
}

@property (weak, nonatomic) IBOutlet LandingPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *viewPhone1;
@property (nonatomic, weak) IBOutlet UIView *viewPhone2;
@property (nonatomic, weak) IBOutlet UIView *viewPhone3;

@property (nonatomic, weak) IBOutlet UIImageView *imageFlash;
@property (nonatomic, weak) IBOutlet UIImageView *imageDigi;
@property (nonatomic, weak) IBOutlet UIImageView *imageRusy;
@property (nonatomic, weak) IBOutlet UIImageView *imageTurt;
@property (nonatomic, weak) IBOutlet UIImageView *imageBano;
@property (nonatomic, weak) IBOutlet UIImageView *imageVint;
@property (nonatomic, weak) IBOutlet UIImageView *imageMate;
@property (nonatomic, weak) IBOutlet UIImageView *imagePhone3;
@property (nonatomic, weak) IBOutlet UIView *viewArrow;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *patternImage;

@end

@implementation LogoView

+ (LogoView*)logoViewWithParent:(LandingPageViewController*)parent {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"LogoView-3.5inch" : [FlipframeUtils nibNameForDevice:@"LogoView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    LogoView *logoView = [subViews firstObject];
    logoView.parentViewController = parent;
    [logoView initView];
    return logoView;
}

- (void)landingViewDidAppear {
    [super landingViewDidAppear];
    [self startTimer];
}

- (void)landingViewWillDisappear {
    [super landingViewWillDisappear];
    [self stopTimer];
}

- (void)initView {
    [self initMembers];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.scrollView.contentSize = CGSizeMake(bounds.size.width * 4, bounds.size.height);
    
    // init page control
    self.pageControl.numberOfPages = 4;
    self.pageControl.indicatorMargin = ([Global deviceType] == DeviceTypePhone6Plus) ? 14 : 13;
    [self.pageControl setPageIndicatorImage:[UIImage imageNamedContentFile:@"ic-landing-dot-off"]];
    [self.pageControl setCurrentPageIndicatorImage:[UIImage imageNamedContentFile:@"ic-landing-dot-on"]];
    [self.pageControl addElements];
    
    // set pattern back image
    [self.patternImage setImage:[UIImage imageNamedContentFile:@"ic-landing-back-pattern"]];
    
    //logo start animation
    [self initBeginAnimate];
    
    [self stopAnimatePhone1];
}

- (void)initMembers {
    _currentPage = 0;
    _arrayCenters = [NSMutableArray new];
    
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone4:
        {
            _phoneCenterY = 62;
            CGPoint centers[6] = {
                CGPointMake(114.5, 64),
                CGPointMake(126.5, 33),
                CGPointMake(199, 105),
                CGPointMake(203, 62),
                CGPointMake(121, 100),
                CGPointMake(162, 25),
            };
            for (NSInteger i = 0; i < 6; i++) {
                CGPoint pt = centers[i];
                NSValue *value = [NSValue valueWithCGPoint:pt];
                [_arrayCenters addObject:value];
            }
        }
            break;
        case DeviceTypePhone5:
        {
            _phoneCenterY = 92;
            CGPoint centers[6] = {
                CGPointMake(114.5, 64),
                CGPointMake(126.5, 33),
                CGPointMake(199, 105),
                CGPointMake(203, 62),
                CGPointMake(121, 100),
                CGPointMake(162, 25),
            };
            for (NSInteger i = 0; i < 6; i++) {
                CGPoint pt = centers[i];
                NSValue *value = [NSValue valueWithCGPoint:pt];
                [_arrayCenters addObject:value];
            }
        }
            break;
        case DeviceTypePhone6:
        {
            _phoneCenterY = 129.5;
            CGPoint centers[6] = {
                CGPointMake(142, 64),
                CGPointMake(154, 33),
                CGPointMake(227, 105),
                CGPointMake(231, 62),
                CGPointMake(149, 100),
                CGPointMake(190, 25),
            };
            for (NSInteger i = 0; i < 6; i++) {
                CGPoint pt = centers[i];
                NSValue *value = [NSValue valueWithCGPoint:pt];
                [_arrayCenters addObject:value];
            }
        }
            break;
        case DeviceTypePhone6Plus:
        {
            _phoneCenterY = 145;
            CGPoint centers[6] = {
                CGPointMake(155, 69),
                CGPointMake(169, 34),
                CGPointMake(251, 114),
                CGPointMake(255, 66),
                CGPointMake(164, 109),
                CGPointMake(209, 26),
            };
            for (NSInteger i = 0; i < 6; i++) {
                CGPoint pt = centers[i];
                NSValue *value = [NSValue valueWithCGPoint:pt];
                [_arrayCenters addObject:value];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void) initBeginAnimate{
    if (self.parentViewController.isLogoAnimate) {
        self.logoImage.alpha = 0;
        self.signUpButton.alpha = 0;
        self.loginButton.alpha = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        //don't forget to add delegate.....
        [UIView setAnimationDelegate:self];
        
        [UIView setAnimationDuration:0.5];
        self.logoImage.alpha = 1;
        self.signUpButton.alpha = 1;
        self.loginButton.alpha = 1;
        
        //also call this before commit animations......
//        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView commitAnimations];
        
        [_pageControl startBeginAnimation];
    }
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    self.logoImage.alpha = 1;
    self.signUpButton.alpha = 1;
    self.loginButton.alpha = 1;
    [UIView commitAnimations];
}

- (void)actionScrollView:(CGFloat)offset {
    self.viewPhone1.center = [self centerPhone1View:offset];
    self.viewPhone2.center = [self centerPhone2View:offset];
    self.viewPhone3.center = [self centerPhone3View:offset];
    self.pageControl.currentPage = [self currentPage:offset];
    self.patternImage.alpha = [self alphaPatternImage:offset];
}

- (CGPoint)centerPhone1View:(CGFloat)offset {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGPoint center = CGPointZero;
    CGRect frame = self.viewPhone1.frame;
    if (offset <= bounds.size.width) {
        center.x = bounds.size.width * 1.5 - offset;
        center.y = _phoneCenterY + frame.size.height / 2;
    }
    else {
        center.x = bounds.size.width / 2;
        center.y = MAX(-frame.size.height, MIN(_phoneCenterY + frame.size.height / 2, _phoneCenterY + frame.size.height / 2 - (_phoneCenterY + frame.size.height) * ((offset - bounds.size.width) / bounds.size.width)));
    }
    return center;
}

- (CGPoint)centerPhone2View:(CGFloat)offset {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGPoint center = CGPointZero;
    CGRect frame = self.viewPhone2.frame;
    if (offset <= bounds.size.width * 2) {
        center.x = bounds.size.width * 2.5 - offset;
        center.y = _phoneCenterY + frame.size.height / 2;
    }
    else {
        center.x = bounds.size.width / 2;
        center.y = MAX(-frame.size.height, MIN(_phoneCenterY + frame.size.height / 2, _phoneCenterY + frame.size.height / 2 - (_phoneCenterY + frame.size.height) * ((offset - bounds.size.width * 2) / bounds.size.width)));
    }
    return center;
}

- (CGPoint)centerPhone3View:(CGFloat)offset {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGPoint center = CGPointZero;
    CGRect frame = self.viewPhone2.frame;
    center.x = MAX(bounds.size.width / 2, bounds.size.width * 3.5 - offset);
    center.y = _phoneCenterY + frame.size.height / 2;
    return center;
}

- (CGFloat)alphaPatternImage:(CGFloat)offset {
    return MIN(1.0f, (offset / SCREEN_WIDTH));
}

- (NSInteger)currentPage:(CGFloat)offset {
    NSInteger newPage = 0;
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (offset < bounds.size.width / 2) {
        newPage = 0;
    }
    else if (offset < bounds.size.width * 1.5) {
        newPage = 1;
    }
    else if (offset < bounds.size.width * 2.5) {
        newPage = 2;
    }
    else {
        newPage = 3;
    }
    if (newPage != _currentPage) {
        _isAnimated = NO;
        _isStop = NO;
        _currentPage = newPage;
    }
    return _currentPage;
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.scrollView]) {
        CGFloat offsetX = scrollView.contentOffset.x;
        scrollView.contentOffset = CGPointMake(offsetX, 0);
        [self actionScrollView:offsetX];
        _lastUpdated = [NSDate timeIntervalSinceReferenceDate];
    }
}

#pragma mark - timer methods
- (void)startTimer {
    if (_timer == nil) {
        _lastUpdated = [NSDate timeIntervalSinceReferenceDate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimer:(id)sender {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    switch (self.pageControl.currentPage) {
        case 1:
            if (now - _lastUpdated > 0 && _isStop == NO) {
                [self stopAnimatePhone2];
            }
            if (now - _lastUpdated > 0.2 && _isAnimated == NO) {
                [self startAnimatePhone1];
            }
            break;
        case 2:
            if (now - _lastUpdated > 0 && _isStop == NO) {
                [self stopAnimatePhone1];
                [self stopAnimatePhone3];
            }
            if (now - _lastUpdated > 0.4 && _isAnimated == NO) {
                [self startAnimatePhone2];
            }
            break;
        case 3:
            if (now - _lastUpdated > 0 && _isStop == NO) {
                [self stopAnimatePhone2];
            }
            if (now - _lastUpdated > 0.4 && _isAnimated == NO) {
                [self startAnimatePhone3];
            }
            break;
            
        default:
            break;
    }
}

- (void)stopAnimatePhone1 {
    NSLog(@"stop animation 1");
    _isStop = YES;
    self.imageFlash.transform = CGAffineTransformMakeScale(0, 0);
    self.imageFlash.alpha = 1;
    [self.imageFlash.layer removeAllAnimations];
}

- (void)stopAnimatePhone2 {
    NSLog(@"stop animation 2");
    _isStop = YES;
    NSArray *arrayEffects = @[self.imageDigi, self.imageRusy, self.imageTurt, self.imageBano, self.imageVint, self.imageMate];
    for (UIImageView *imageView in arrayEffects) {
        [imageView.layer removeAllAnimations];
        imageView.center = CGPointMake(self.viewPhone2.frame.size.width / 2, self.viewPhone2.frame.size.height / 2);
    }
}

- (void)stopAnimatePhone3 {
    NSLog(@"stop animation 3");
    _isStop = YES;
    self.viewArrow.alpha = 1.0f;
    CGRect frame = self.viewArrow.frame;
    frame.origin.x = self.imagePhone3.frame.origin.x + self.imagePhone3.frame.size.width - frame.size.width;
    self.viewArrow.frame = frame;
}

- (void)startAnimatePhone1 {
    _isAnimated = YES;
    NSLog(@"start animation 1");
    
    [UIView animateKeyframesWithDuration:0.8 delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        [UIView setAnimationRepeatCount:2];
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.3 animations:^{
            self.imageFlash.transform = CGAffineTransformMakeScale(1, 1);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.1 animations:^{
            self.imageFlash.alpha = 0;
        }];
    } completion:^(BOOL finished) {
        self.imageFlash.transform = CGAffineTransformMakeScale(0, 0);
        self.imageFlash.alpha = 1;
    }];
}

- (void)startAnimatePhone2 {
    _isAnimated = YES;
    NSLog(@"start animation 2");
    
    NSArray *arrayEffects = @[self.imageDigi, self.imageRusy, self.imageMate, self.imageBano, self.imageVint, self.imageTurt];
    for (NSInteger i = 0; i < 6; i++) {
        UIImageView *imageView = [arrayEffects objectAtIndex:i];
        NSValue *value = [_arrayCenters objectAtIndex:i];
        CGPoint center = [value CGPointValue];
        [UIView animateWithDuration:0.2 + 0.02 * i
                         animations:^{
                             imageView.center = center;
                         }];
    }
}

- (void)startAnimatePhone3 {
    _isAnimated = YES;
    NSLog(@"start animation 3");
    CGRect frameOrigin = CGRectMake(self.imagePhone3.frame.origin.x + self.imagePhone3.frame.size.width - self.viewArrow.frame.size.width,
                                    self.viewArrow.frame.origin.y,
                                    self.viewArrow.frame.size.width,
                                    self.viewArrow.frame.size.height);
    CGRect frameMove = CGRectMake(self.imagePhone3.frame.origin.x + self.imagePhone3.frame.size.width,
                                  self.viewArrow.frame.origin.y,
                                  self.viewArrow.frame.size.width,
                                  self.viewArrow.frame.size.height);
    self.viewArrow.frame = frameOrigin;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.viewArrow.frame = frameMove;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1f
                                          animations:^{
                                              self.viewArrow.alpha = 0.0f;
                                          } completion:^(BOOL finished) {
                                              self.viewArrow.frame = frameOrigin;
                                              self.viewArrow.alpha = 1.0f;
                                              [UIView animateWithDuration:0.2f
                                                               animations:^{
                                                                   self.viewArrow.frame = frameMove;
                                                               }];
                                          }];
                     }];
}

#pragma mark - handle button methods
- (IBAction)handleBtnLoginTouch:(id)sender {
    LoginView *loginView = [LoginView loginViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:loginView
                                   slideEnabled:NO
                                      animation:[NMColorBurstTransitionAnimation animationWithContainerView:self burstView:sender]
                                         sender:sender];
}

- (IBAction)handleBtnSignupTouch:(id)sender {
    InviteCodeView *inviteCodeView = [InviteCodeView inviteCodeViewWithParent:self.parentViewController];
    [self.parentViewController pushAnimatedView:inviteCodeView
                                   slideEnabled:NO
                                      animation:[NMColorBurstTransitionAnimation animationWithContainerView:self burstView:sender]
                                         sender:sender];
}

#pragma mark -
- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
