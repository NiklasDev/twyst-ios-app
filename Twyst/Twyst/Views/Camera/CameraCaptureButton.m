//
//  CameraCaptureButton.m
//  Twyst
//
//  Created by Niklas Ahola on 4/22/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "CameraCaptureButton.h"

@interface CameraCaptureButton() <UIGestureRecognizerDelegate> {
    CameraButtonState _buttonState;
    BOOL _enableVideoCapture;
}

@property (nonatomic, strong) UIImageView *imageButton;

@end

@implementation CameraCaptureButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
    self.imageButton = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.imageButton];
    [self changeButtonState:CameraButtonStateNormal];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTapGesture:)];
    gesture.minimumPressDuration = 0.5f;
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"-- camera button touch began --");
    [self changeButtonState:CameraButtonStatePhoto];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"-- camera button touch ended --");
    [self changeButtonState:CameraButtonStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(CameraCapturePhoto)]) {
        [self.delegate CameraCapturePhoto];
    }
}

- (void)handleLongTapGesture:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"-- camera button long tap began --");
        [self changeButtonState:CameraButtonStateVideo];
        
        if ([self.delegate respondsToSelector:@selector(CameraCaptureVideoStart)]) {
            [self.delegate CameraCaptureVideoStart];
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"-- camera button long tap ended --");
        if (_buttonState == CameraButtonStateVideo) {
            [self changeButtonState:CameraButtonStateNormal];
            
            if ([self.delegate respondsToSelector:@selector(CameraCaptureVideoEnd)]) {
                [self.delegate CameraCaptureVideoEnd];
            }
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"-- camera button long tap cancelled --");
        if (_buttonState == CameraButtonStateVideo) {
            [self changeButtonState:CameraButtonStateNormal];
            
            if ([self.delegate respondsToSelector:@selector(CameraCaptureVideoEnd)]) {
                [self.delegate CameraCaptureVideoEnd];
            }
        }
    }
}

- (void)enableVideoCapturing:(BOOL)enable {
    _enableVideoCapture = enable;
}

- (void)changeButtonState:(CameraButtonState)state {
    NSString *buttonImage = nil;
    switch (state) {
        case CameraButtonStateNormal:
            buttonImage = @"btn-camera-shutter-on";
            break;
        case CameraButtonStatePhoto:
            buttonImage = @"btn-camera-shutter-hl";
            break;
        case CameraButtonStateVideo:
            buttonImage = @"btn-video-shutter-on";
            break;
        default:
            break;
    }
    self.imageButton.image = [UIImage imageNamedForDevice:buttonImage];
    _buttonState = state;
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return _enableVideoCapture;
}

@end
