//
//  TwystInfoView.m
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "TTwystOwner.h"
#import "UserWebService.h"
#import "TTwystOwnerManager.h"

#import "BounceButton.h"
#import "ADTickerLabel.h"
#import "TwystInfoView.h"
#import "WrongMessageView.h"
#import "FlutterImageView.h"

@interface TwystInfoView() {
    ADTickerLabel *_labelViewCount;
    ADTickerLabel *_labelLikeCount;
    
    BOOL _isVisible;
    
    NSTimer *_timerViewCount;
    BOOL _isViewCountRequest;
    
    BOOL _isLiked;
    NSInteger _viewCount;
    NSInteger _likeCount;
    NSInteger _twysterCount;
    NSInteger _replyCount;
    NSInteger _passCount;
    
    UISwipeGestureRecognizer *_swipeUpGesture;
}

@property (weak, nonatomic) IBOutlet UIView *infoContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageCreator;
@property (weak, nonatomic) IBOutlet UIImageView *imagePasser;
@property (weak, nonatomic) IBOutlet UILabel *labelRealname;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UILabel *labelTheme;
@property (weak, nonatomic) IBOutlet UILabel *labelReplies;
@property (weak, nonatomic) IBOutlet UILabel *labelPassed;
@property (weak, nonatomic) IBOutlet UILabel *labelLikes;
@property (weak, nonatomic) IBOutlet UILabel *labelReplyCount;
@property (weak, nonatomic) IBOutlet UILabel *labelPassCount;
@property (weak, nonatomic) IBOutlet UIView *likeContainer;
@property (weak, nonatomic) IBOutlet UIView *viewCounts;

@property (weak, nonatomic) IBOutlet UIView *viewCountContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageReplyTutor;
@property (weak, nonatomic) IBOutlet UIImageView *imagePassingTutor;

@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnReply;
@property (weak, nonatomic) IBOutlet UIButton *btnPass;
@property (weak, nonatomic) IBOutlet BounceButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;

@end

@implementation TwystInfoView

- (id)initWithTwyst:(TSavedTwyst *)twyst {
    NSString *nibName = ([Global deviceType] == DeviceTypePhone4) ? @"TwystInfoView-3.5inch" : [FlipframeUtils nibNameForDevice:@"TwystInfoView"];
    NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    self = [subViews firstObject];
    self.twyst = twyst;
    [self initView];
    return self;
}

- (void)initView {
    self.alpha = 0.0f;
    
    _swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    _swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:_swipeUpGesture];
    
    if ([_twyst.allowReplies isEqualToString:@"no"]) {
        _btnReply.selected = YES;
        [_btnReply setImage:[UIImage imageNamedContentFile:@"btn-preview-lock"] forState:UIControlStateNormal];
    }
    
    if (![_twyst.allowPass boolValue]) {
        _btnPass.selected = YES;
        [_btnPass setImage:[UIImage imageNamedContentFile:@"btn-preview-lock"] forState:UIControlStateNormal];
    }
    
    // set gaussian blur image
//    [self addGaussianBlurImage];
    
    // set fonts
    CGFloat fontSize = _labelRealname.font.pointSize;
    [_labelRealname setFont:[UIFont fontWithName:@"Seravek-Medium" size:fontSize]];
    
    fontSize = _labelUsername.font.pointSize;
    [_labelUsername setFont:[UIFont fontWithName:@"Seravek-Light" size:fontSize]];
    
    fontSize = _labelTheme.font.pointSize;
    [_labelTheme setFont:[UIFont fontWithName:@"OpenSans" size:fontSize]];
    
    fontSize = _labelReplies.font.pointSize;
    UIFont *font = [UIFont fontWithName:@"Seravek" size:fontSize];
    [_labelReplies setFont:font];
    [_labelPassed setFont:font];
    [_labelLikes setFont:font];
    
    fontSize = _labelReplyCount.font.pointSize;
    font = [UIFont fontWithName:@"Seravek-Medium" size:fontSize];
    [_labelReplyCount setFont:font];
    [_labelPassCount setFont:font];
    [_labelLikeCount setFont:font];
    
    // add ticker labels
    [self addViewCountLabel];
    [self addLikeCountLabel];
    
    // set creator profile picture
    _imageCreator.layer.cornerRadius = _imageCreator.frame.size.width / 2;
    _imageCreator.layer.masksToBounds = YES;
    
    long ownerId = [_twyst.ownerId longValue];
    TTwystOwner *owner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:ownerId];
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-profile-avatar"];
    [_imageCreator setImageWithURL:ProfileURL(owner.profilePicName) placeholderImage:placeholder];
    
    // set passer profile picture
    NSArray *passer = [_twyst.passedBy componentsSeparatedByString:@","];
    if (passer.count > 0 && ![[passer firstObject] isEqualToString:owner.userName]) {
        _imagePasser.layer.cornerRadius = _imagePasser.frame.size.width / 2;
        _imagePasser.layer.masksToBounds = YES;
        [_imagePasser setImageWithURL:ProfileURL([passer lastObject]) placeholderImage:placeholder];
    }
    
    // set name
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", owner.firstName, owner.lastName];
    _labelUsername.text = owner.userName;
    
    // set theme
    _labelTheme.text = _twyst.caption;

    CGRect frame = _labelTheme.frame;
    CGSize size = [_twyst.caption stringSizeWithFont:_labelTheme.font constrainedToWidth:frame.size.width];
    if (size.height > frame.size.height) {
        CGFloat delta = size.height - frame.size.height;
        _viewCounts.center = CGPointMake(_viewCounts.center.x, _viewCounts.center.y + delta);
        frame.size.height += delta;
        _labelTheme.frame = frame;
    }
    
    // set anchor point for tutor bubbles
    _imageReplyTutor.layer.anchorPoint = CGPointMake(0.3f, 1.0f);
    _imagePassingTutor.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    _imageReplyTutor.hidden = YES;
    _imagePassingTutor.hidden = YES;
    
    [self actionGetTwystInfo];
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

- (void)addGaussianBlurImage {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6f];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.bounds;
        [self insertSubview:blurEffectView belowSubview:_imageCreator];
    }
    else {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.9f];
    }
}

- (void)addViewCountLabel {
    UIFont *font = _labelReplyCount.font;
    _labelViewCount = [[ADTickerLabel alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, font.lineHeight)];
    _labelViewCount.font = font;
    _labelViewCount.textColor = [UIColor whiteColor];
    _labelViewCount.textAlignment = NSTextAlignmentCenter;
    _labelViewCount.changeTextAnimationDuration = 0.5;
    [self.viewCountContainer addSubview:_labelViewCount];
}

- (void)addLikeCountLabel {
    UIFont *font = _labelReplyCount.font;
    CGRect frame = _likeContainer.frame;
    frame = CGRectMake(0, (frame.size.height - font.lineHeight) / 2, frame.size.width, font.lineHeight);
    _labelLikeCount = [[ADTickerLabel alloc] initWithFrame:frame];
    _labelLikeCount.font = font;
    _labelLikeCount.textColor = [UIColor whiteColor];
    _labelLikeCount.textAlignment = NSTextAlignmentCenter;
    _labelLikeCount.changeTextAnimationDuration = 0.5;
    [self.likeContainer addSubview:_labelLikeCount];
}

- (void)actionGetTwystInfo {
    long twystId = [_twyst.twystId longValue];
    [[UserWebService sharedInstance] getTwystPreviewInfo:twystId completion:^(BOOL isSuccess, NSInteger twyster, NSInteger like, NSInteger viewCount, NSInteger replies, NSInteger passes, BOOL userLiked) {
        if (isSuccess) {
            _likeCount = like;
            _twysterCount = twyster;
            _replyCount = replies;
            _passCount = passes;
            _isLiked = userLiked;
            [self updateTwystCounts];
            [self updateViewCount:viewCount];
        }
        else {
            [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
        }
    }];
}

- (void)actionLike {
    long stringgId = [_twyst.twystId longValue];
    if (_isLiked) {
        [[UserWebService sharedInstance] unlikeTwyst:stringgId completion:^(BOOL isSuccess) {
            if (isSuccess == NO) {
                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
                _likeCount += 1;
                _isLiked = YES;
                _btnLike.selected = _isLiked;
                [self updateLikeCount];
            }
        }];
    }
    else {
        [[UserWebService sharedInstance] likeTwyst:stringgId completion:^(BOOL isSuccess) {
            if (isSuccess == NO) {
                [self actionShowWrongMessage:WrongMessageTypeNoInternetConnection];
                _likeCount -= 1;
                _isLiked = NO;
                _btnLike.selected = _isLiked;
                [self updateLikeCount];
            }
        }];
    }
    
    if (_isLiked) {
        _likeCount -= 1;
    }
    else {
        _likeCount += 1;
        [self addFlutterObject];
    }
    _isLiked = !_isLiked;
    _btnLike.selected = _isLiked;
    [self updateLikeCount];
}

- (void)updateViewCount:(NSInteger)viewCount {
    if (_viewCount < viewCount) {
        _viewCount = viewCount;
        _labelViewCount.text = [self countString:_viewCount];
    }
}

- (void)updateLikeCount {
    [_labelLikeCount setText:[self countString:_likeCount] animated:YES];
}

- (void)updateTwystCounts {
    _labelReplyCount.text = [self countString:_replyCount];
    _labelPassCount.text = [self countString:_passCount];
    [_labelLikeCount setText:[self countString:_likeCount] animated:NO];
    _btnLike.selected = _isLiked;
}

- (void)actionShowWrongMessage:(WrongMessageType)type {
    [WrongMessageView showMessage:type inView:self arrayOffsetY:@[@0, @0, @0]];
}

- (void)addFlutterObject {
    UIImage *likeHeart = [UIImage imageNamedContentFile:@"btn-preview-like-sel"];
    FlutterImageView *imageView = [[FlutterImageView alloc] initWithFrame:CGRectMake(0, 0, likeHeart.size.width, likeHeart.size.height)];
    imageView.image = likeHeart;
    imageView.center = [self convertPoint:_btnLike.center fromView:_bottomContainer];
    [self addSubview:imageView];
    [imageView flutterAnimation:-60 sway:20 duration:2];
}

- (NSString*)countString:(NSInteger)count {
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:count]];
}

#pragma mark - show / hide tutor
- (void)showImageTutor:(UIView*)view {
    view.hidden = NO;
    view.alpha = 1.0f;
    view.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.2f
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                          } completion:^(BOOL finished) {
                                              [self performSelector:@selector(hideImageTutor:)
                                                         withObject:view
                                                         afterDelay:3.0f];
                                          }];
                     }];
}
- (void)hideImageTutor:(UIView*)view {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         view.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         view.hidden = YES;
                     }];
}

#pragma mark - public methods
- (void)show {
    [self actionGetTwystInfo];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    _infoContainer.frame = CGRectMake(0, - bounds.size.height, bounds.size.width, bounds.size.height);
    _bottomContainer.frame = CGRectMake(0, bounds.size.height, bounds.size.width, _bottomContainer.frame.size.height);
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.4f
                                          animations:^{
                                              _infoContainer.frame = bounds;
                                              _bottomContainer.frame = CGRectMake(0, bounds.size.height - _bottomContainer.frame.size.height, bounds.size.width, _bottomContainer.frame.size.height);
                                          } completion:^(BOOL finished) {
                                              _isVisible = YES;
                                              [self startViewCountTimer];
                                          }];
                     }];
}

- (void)hide:(void(^)(void))completion {
    CGRect bounds = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         _infoContainer.frame = CGRectMake(0, - bounds.size.height, bounds.size.width, bounds.size.height);
                         _bottomContainer.frame = CGRectMake(0, bounds.size.height, bounds.size.width, _bottomContainer.frame.size.height);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              self.alpha = 0.0f;
                                          } completion:^(BOOL finished) {
                                              _isVisible = NO;
                                              [self stopViewCountTimer];
                                              completion();
                                          }];
                     }];
}

- (BOOL)isVisible {
    return _isVisible;
}

- (NSInteger)getTwysterCount {
    return _twysterCount;
}

- (void)releaseInfoView {
    [self stopViewCountTimer];
}

#pragma mark - button handler
- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)sender {
    [self hide:^{
        [self.delegate twystInfoViewDidHide];
    }];
}

- (IBAction)handleTapCreator:(id)sender {
    [self.delegate twystInfoViewCreatorDidTap];
}

- (IBAction)handleBtnReplyTouch:(id)sender {
    if (_btnReply.selected) {
        if (_imageReplyTutor.hidden) {
            [self showImageTutor:_imageReplyTutor];
        }
    }
    else {
        [self stopViewCountTimer];
        [self.delegate twystInfoViewReplyDidClick];
    }
}

- (IBAction)handleBtnPassTouch:(id)sender {
    if (_btnPass.selected) {
        if (_imagePassingTutor.hidden) {
            [self showImageTutor:_imagePassingTutor];
        }
    }
    else {
        [self.delegate twystInfoViewPassDidClick];
    }
}

- (IBAction)handleBtnLikeTouch:(id)sender {
    [self actionLike];
}

- (IBAction)handleBtnMoreTouch:(id)sender {
    [self.delegate twystInfoViewMoreDidClick];
}

#pragma mark - handle timer methods
- (void)startViewCountTimer {
    if (_timerViewCount == nil) {
        _timerViewCount = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                           target:self
                                                         selector:@selector(onViewCountTimer:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void)stopViewCountTimer {
    if (_timerViewCount) {
        [_timerViewCount invalidate];
        _timerViewCount = nil;
    }
}

- (void)onViewCountTimer:(id)sender {
    if (_isViewCountRequest == NO) {
        _isViewCountRequest = YES;
        long twystId = [_twyst.twystId longValue];
        [[UserWebService sharedInstance] getTwystViewCount:twystId completion:^(BOOL isSuccess, NSInteger viewCount) {
            if (isSuccess) {
                [self updateViewCount:viewCount];
            }
            _isViewCountRequest = NO;
        }];
    }
}

@end
