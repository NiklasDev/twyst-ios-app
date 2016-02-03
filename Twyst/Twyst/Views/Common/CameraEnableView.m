//
//  CameraEnableView.m
//  Twyst
//
//  Created by Niklas Ahola on 10/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImage+Device.h"
#import "CameraEnableView.h"
#import "AppPermissionService.h"

@interface CameraEnableView() {
    CGRect _frameCancel;
    CGFloat _fontSizeCancel;
    CGRect _frameTutor;
}

@end

@implementation CameraEnableView

+ (void)showInView:(UIView*)view target:(id)target {
    CameraEnableView *dropdownView = [[CameraEnableView alloc] initWithTarget:target];
    [dropdownView showInView:view];
}

- (id)initWithTarget:(id)target {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:bounds];
    if (self) {
        self.delegate = target;
        [self initMembers];
        [self initView];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone4:
            _frameCancel = CGRectMake(8, 20, 60, 40);
            _fontSizeCancel = 16;
            _frameTutor = CGRectMake(58, 88, 204, 179);
            break;
        case DeviceTypePhone5:
            _frameCancel = CGRectMake(8, 20, 60, 40);
            _fontSizeCancel = 16;
            _frameTutor = CGRectMake(58, 103, 204, 179);
            break;
        case DeviceTypePhone6:
            _frameCancel = CGRectMake(10, 22, 60, 40);
            _fontSizeCancel = 17;
            _frameTutor = CGRectMake(71.5, 109, 232, 208);
            break;
        case DeviceTypePhone6Plus:
            _frameCancel = CGRectMake(14, 26, 60, 40);
            _fontSizeCancel = 18.6;
            _frameTutor = CGRectMake(79, 121, 256, 229);
            break;
        default:
            break;
    }
}

- (void)initView {
    self.backgroundColor = ColorRGBA(255, 255, 255, 0.98);
    self.alpha = 0;
    
    UIButton *buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCancel.frame = _frameCancel;
    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [buttonCancel.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_fontSizeCancel]];
    [buttonCancel setTitleColor:Color(58, 50, 88) forState:UIControlStateNormal];
    [buttonCancel setTitleColor:Color(91, 87, 111) forState:UIControlStateHighlighted];
    [buttonCancel addTarget:self action:@selector(handleBtnCancelTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonCancel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_frameTutor];
    imageView.image = [UIImage imageNamedForDevice:@"tutor-start-twyst"];
    [self addSubview:imageView];
    
    NSArray *buttonFrames = [self buttonFrames];
    NSArray *normalImages = [self normalImages];
    NSArray *hightlightImages = [self highlightImages];
    NSArray *disableImages = [self disableImages];
    
    NSInteger count = buttonFrames.count;
    for (NSInteger i = 0; i < count; i++) {
        CGRect frame = [[buttonFrames objectAtIndex:i] CGRectValue];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        
        if (i == 0) {
            if ([[AppPermissionService sharedInstance] isCameraEnable]) {
                [button setImage:[UIImage imageNamedForDevice:[disableImages objectAtIndex:i]] forState:UIControlStateDisabled];
                button.enabled = NO;
            }
            else {
                [button setImage:[UIImage imageNamedForDevice:[normalImages objectAtIndex:i]] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamedForDevice:[hightlightImages objectAtIndex:i]] forState:UIControlStateHighlighted];
            }
        }
        else if (i == 1) {
            if ([[AppPermissionService sharedInstance] isMicroPhoneEnable]) {
                [button setImage:[UIImage imageNamedForDevice:[disableImages objectAtIndex:i]] forState:UIControlStateDisabled];
                button.enabled = NO;
            }
            else {
                [button setImage:[UIImage imageNamedForDevice:[normalImages objectAtIndex:i]] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamedForDevice:[hightlightImages objectAtIndex:i]] forState:UIControlStateHighlighted];
            }
        }
        
        [button addTarget:self action:@selector(handleBtnActionTouch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button.tag = i + 100;
    }
}

- (NSArray*)buttonFrames {
    NSArray *frames = nil;
    switch ([Global deviceType]) {
        case DeviceTypePhone4:
        {
            frames = @[[NSValue valueWithCGRect:CGRectMake(53, 295.5, 214, 39)],
                       [NSValue valueWithCGRect:CGRectMake(53, 346.5, 214, 39)]];
        }
            break;
        case DeviceTypePhone5:
        {
            frames = @[[NSValue valueWithCGRect:CGRectMake(53, 310.5, 214, 39)],
                       [NSValue valueWithCGRect:CGRectMake(53, 361.5, 214, 39)]];
        }
            break;
        case DeviceTypePhone6:
        {
            frames = @[[NSValue valueWithCGRect:CGRectMake(62.5, 352.5, 250, 45)],
                       [NSValue valueWithCGRect:CGRectMake(62.5, 412.5, 250, 45)]];
        }
            break;
        case DeviceTypePhone6Plus:
        {
            frames = @[[NSValue valueWithCGRect:CGRectMake(69, 389, 278, 50)],
                       [NSValue valueWithCGRect:CGRectMake(69, 455, 278, 50)]];
        }
            break;
    }
    
    return frames;
}

- (NSArray*)normalImages {
    NSArray *images = @[@"btn-start-camera-off",
                       @"btn-start-microphone-off"];
    return images;
}

- (NSArray*)highlightImages {
    NSArray *images = @[@"btn-start-camera-hl",
                       @"btn-start-microphone-hl"];
    return images;
}

- (NSArray*)disableImages {
    NSArray *images = @[@"btn-start-camera-on",
                       @"btn-start-microphone-on"];
    return images;
}

- (void)show {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 1.0f;
                     }];
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
    [self show];
}

- (void)hide {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if ([self.delegate respondsToSelector:@selector(CameraEnableViewDidDismiss:)]) {
                             [self.delegate CameraEnableViewDidDismiss:self];
                         }
                     }];
}

- (void)reloadButtons {
    NSArray *normalImages = [self normalImages];
    NSArray *disableImages = [self disableImages];
    
    NSInteger count = normalImages.count;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *button = (UIButton*)[self viewWithTag:i + 100];
        if (i == 0) {
            if ([[AppPermissionService sharedInstance] isCameraEnable]) {
                [button setImage:[UIImage imageNamedForDevice:[disableImages objectAtIndex:i]] forState:UIControlStateDisabled];
                button.enabled = NO;
            }
            else {
                [button setImage:[UIImage imageNamedForDevice:[normalImages objectAtIndex:i]] forState:UIControlStateNormal];
                button.enabled = YES;
            }
        }
        else if (i == 1) {
            if ([[AppPermissionService sharedInstance] isMicroPhoneEnable]) {
                [button setImage:[UIImage imageNamedForDevice:[disableImages objectAtIndex:i]] forState:UIControlStateDisabled];
                button.enabled = NO;
            }
            else {
                [button setImage:[UIImage imageNamedForDevice:[normalImages objectAtIndex:i]] forState:UIControlStateNormal];
                button.enabled = YES;
            }
        }
    }
}

- (void)handleBtnActionTouch:(UIButton*)sender {
    NSInteger selectedIndex = sender.tag - 100;
    if ([self.delegate respondsToSelector:@selector(CameraEnableViewClicked:selectedIndex:)]) {
        [self.delegate CameraEnableViewClicked:self selectedIndex:selectedIndex];
    }
}

- (void)handleBtnCancelTouch:(UIButton*)sender {
    [self hide];
}

- (void) dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

@end
