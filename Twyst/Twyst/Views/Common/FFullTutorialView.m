//
//  FFullTutorialView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "FFullTutorialView.h"
#import "BounceButton.h"

@interface FFullTutorialView()

@end

@implementation FFullTutorialView

- (id)initWithType:(FullTutorialType)type withTarget:(id)target withSelector:(SEL)selector {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _type = type;
        
        // Initialization code
        UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        bgView.backgroundColor = ColorRGBA(11, 11, 11, 0.9);
        bgView.userInteractionEnabled = NO;
        [self addSubview:bgView];
        
        UIImage *image = [self tutorImage];
        CGRect frame = [self tutorFrameWithImageSize:image.size];
        UIImageView *imageTutor = [[UIImageView alloc] initWithFrame:frame];
        imageTutor.image = image;
        [self addSubview:imageTutor];
        
        [self addAction:target action:selector];
    }
    return self;
}

- (UIImage*)tutorImage {
    NSString *imageName = nil;
    switch (_type) {
        // preview
        case FullTutorialPreviewSkipFrame:
            imageName = @"tutor-preview-skip-frame";
            break;
        case FullTutorialPreviewSwipeUp:
            imageName = @"tutor-preview-swipe-up";
            break;
        case FullTutorialPreviewSwipeDown:
            imageName = @"tutor-preview-swipe-down";
            break;
        case FullTutorialPreviewSwipeLeft:
            imageName = @"tutor-preview-swipe-left";
            break;
        case FullTutorialPreviewSwipeRight:
            imageName = @"tutor-preview-swipe-right";
            break;
            
        // camera
        case FullTutorialCameraTapPhoto:
            imageName = @"tutor-camera-tap-photo";
            break;
        case FullTutorialCameraHoldVideo:
            imageName = @"tutor-camera-hold-video";
            break;
        case FullTutorialCameraEcho:
            imageName = @"tutor-camera-echo";
            break;
        case FullTutorialCameraReply:
            imageName = @"tutor-camera-reply";
            break;
            
        // edit
        case FullTutorialEditPlayback:
            imageName = @"tutor-edit-playback";
            break;
        case FullTutorialEditPhotoSwipeDown:
        case FullTutorialEditVideoSwipeDown:
            imageName = @"tutor-edit-swipe-down";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamedForDevice:imageName];
}

- (CGRect)tutorFrameWithImageSize:(CGSize)size {
    CGRect frame = CGRectZero;
    DeviceType device = [Global deviceType];
    switch (_type) {
        // preview
        case FullTutorialPreviewSkipFrame:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(65, 93, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(65, 108, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(73, 131, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(74, 144, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
        case FullTutorialPreviewSwipeUp:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(71, 109, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(71, 124, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(84, 142.5, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(93, 158, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
        case FullTutorialPreviewSwipeDown:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(65, 106, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(65, 121, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(78, 143, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(87, 158, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
        case FullTutorialPreviewSwipeLeft:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(70, 108, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(70, 122, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(90, 136.5, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(100, 151, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
        case FullTutorialPreviewSwipeRight:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(83, 104, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(83, 119, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(104, 136.5, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(115, 151, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
            
        // camera
        case FullTutorialCameraTapPhoto:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(56, 88.5, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(56, 118.5, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(76.5, 141, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(84.3, 155.3, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
        case FullTutorialCameraHoldVideo:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(52, 88.5, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(52, 118.5, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(75, 141, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(82.7, 155.3, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
        case FullTutorialCameraEcho:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(21, 88.5, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(21, 118.5, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(39, 141, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(43.7, 155.3, size.width, size.height);
                    break;
            }
        }
            break;
        case FullTutorialCameraReply:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(46, 88.5, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(46, 118.5, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(68, 141, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(75, 155.3, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
            
        // edit
        case FullTutorialEditPlayback:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(29, 78.5, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(29, 108.5, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(47, 108, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(52, 119, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
        case FullTutorialEditPhotoSwipeDown:
        case FullTutorialEditVideoSwipeDown:
        {
            switch (device) {
                case DeviceTypePhone4:
                    frame = CGRectMake(57.5, 88, size.width, size.height);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(57.5, 118, size.width, size.height);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(61, 140.5, size.width, size.height);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(67.3, 155, size.width, size.height);
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return frame;
}

- (void)addAction:(id)target action:(SEL)selector {
    switch (_type) {
            
        case FullTutorialCameraTapPhoto:
        case FullTutorialCameraHoldVideo:
        case FullTutorialEditPlayback:
        {
            CGRect frame = CGRectZero;
            switch ([Global deviceType]) {
                case DeviceTypePhone4:
                    frame = CGRectMake(116.5, 305, 87, 35);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(116.5, 335, 87, 35);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(135, 363.5, 103, 41);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(149, 401, 114, 46);
                    break;
                default:
                    break;
            }
            BounceButton *button = [BounceButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:frame];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-next-on"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-next-hl"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(handleBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
            break;
        case FullTutorialCameraEcho:
        case FullTutorialCameraReply:
        case FullTutorialEditPhotoSwipeDown:
        case FullTutorialEditVideoSwipeDown:
        {
            CGRect frame = CGRectZero;
            switch ([Global deviceType]) {
                case DeviceTypePhone4:
                    frame = CGRectMake(116.5, 305, 87, 35);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(116.5, 335, 87, 35);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(135, 363.5, 103, 41);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(149, 401, 114, 46);
                    break;
                default:
                    break;
            }
            BounceButton *button = [BounceButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:frame];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-done-on"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-done-hl"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(handleBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
            break;
            
        case FullTutorialPreviewSkipFrame:
        {
            CGRect frame = CGRectZero;
            switch ([Global deviceType]) {
                case DeviceTypePhone4:
                    frame = CGRectMake(116.5, 320, 87, 35);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(116.5, 335, 87, 35);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(135, 398.5, 103, 41);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(149, 440, 114, 46);
                    break;
                default:
                    break;
            }
            BounceButton *button = [BounceButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:frame];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-next-on"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-next-hl"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(handleBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
            break;
            
        case FullTutorialPreviewSwipeUp:
        case FullTutorialPreviewSwipeDown:
        case FullTutorialPreviewSwipeLeft:
        {
            CGRect frame = CGRectZero;
            switch ([Global deviceType]) {
                case DeviceTypePhone4:
                    frame = CGRectMake(116.5, 320, 87, 35);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(116.5, 335, 87, 35);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(135, 378.5, 103, 41);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(149, 418, 114, 46);
                    break;
                default:
                    break;
            }
            BounceButton *button = [BounceButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:frame];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-next-on"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-next-hl"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(handleBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
            break;
            
        case FullTutorialPreviewSwipeRight:
        {
            CGRect frame = CGRectZero;
            switch ([Global deviceType]) {
                case DeviceTypePhone4:
                    frame = CGRectMake(116.5, 320, 87, 35);
                    break;
                case DeviceTypePhone5:
                    frame = CGRectMake(116.5, 335, 87, 35);
                    break;
                case DeviceTypePhone6:
                    frame = CGRectMake(135, 378.5, 103, 41);
                    break;
                case DeviceTypePhone6Plus:
                    frame = CGRectMake(149, 418, 114, 46);
                    break;
                default:
                    break;
            }
            BounceButton *button = [BounceButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:frame];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-done-on"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamedForDevice:@"btn-camera-done-hl"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(handleBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
            break;
            
        default:
            [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            break;
    }
}

- (void)handleBtnTouch:(id)sender {
    if ([self.delegate respondsToSelector:@selector(FullTutorialViewWillDisappear:)]) {
        [self.delegate FullTutorialViewWillDisappear:self];
    }
}

@end
