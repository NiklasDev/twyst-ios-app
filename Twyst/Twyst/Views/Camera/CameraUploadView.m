//
//  CameraUploadView.m
//  Twyst
//
//  Created by Default on 7/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "CameraUploadView.h"

@interface CameraUploadView() {
    UIButton * _btnVideo;
    UIButton * _btnPhoto;
    UIButton * _btnUpload;
    
    CGFloat _buttonInterval;
    CGFloat _buttonOffsetX;
    CGFloat _buttonOffsetY;
    CGRect _frameBtnUpload;
    CGRect _frameBtnVideo;
    CGRect _frameBtnPhoto;
}

@end

@implementation CameraUploadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)initView {
    
    [self initMembers];
    
    UIView * blackView = [[UIView alloc] initWithFrame:self.bounds];
    blackView.backgroundColor = Color(11, 11, 11);
    blackView.alpha = 0.9f;
    [self addSubview:blackView];
    
    _btnPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPhoto.frame = _frameBtnPhoto;
    [_btnPhoto setImage:[UIImage imageNamedForDevice:@"btn-camera-upload-photo"] forState:UIControlStateNormal];
    [_btnPhoto addTarget:self action:@selector(handleBtnUploadPhotoTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnPhoto];
    
    _btnVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnVideo.frame = _frameBtnVideo;
    [_btnVideo setImage:[UIImage imageNamedForDevice:@"btn-camera-upload-video"] forState:UIControlStateNormal];
    [_btnVideo addTarget:self action:@selector(handleBtnUploadVideoTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnVideo];
    
    _btnUpload = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnUpload.frame = _frameBtnUpload;
    [_btnUpload setImage:[UIImage imageNamedForDevice:@"btn-camera-upload-off"] forState:UIControlStateNormal];
    [_btnUpload addTarget:self action:@selector(handleBtnUploadHideTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnUpload];
}

- (void)initMembers {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone4:
            _frameBtnUpload = CGRectMake(172, 318, 60, 60);
            _frameBtnVideo = CGRectMake(172, 263, 60, 60);
            _frameBtnPhoto = CGRectMake(172, 198, 60, 60);
            break;
        case DeviceTypePhone5:
            _frameBtnUpload = CGRectMake(172, 396, 60, 60);
            _frameBtnVideo = CGRectMake(172, 341.5, 60, 60);
            _frameBtnPhoto = CGRectMake(172, 276.5, 60, 60);
            break;
        case DeviceTypePhone6:
            _frameBtnUpload = CGRectMake(198, 484, 60, 60);
            _frameBtnVideo = CGRectMake(199, 416, 60, 60);
            _frameBtnPhoto = CGRectMake(199, 341, 60, 60);
            break;
        case DeviceTypePhone6Plus:
            _frameBtnUpload = CGRectMake(222, 536, 62, 62);
            _frameBtnVideo = CGRectMake(222, 461.5, 62, 62);
            _frameBtnPhoto = CGRectMake(222, 378.5, 62, 62);
            break;
        default:
            break;
    }
}

- (IBAction)handleBtnUploadHideTouch:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)handleBtnUploadPhotoTouch:(UIButton *)sender {
    [UIView animateWithDuration:0.25
                     animations:^{
                         sender.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
                         sender.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(uploadPhotoDidTouch)]) {
                             [self.delegate uploadPhotoDidTouch];
                         }
                         [self removeFromSuperview];
                     }];
}

- (IBAction)handleBtnUploadVideoTouch:(UIButton *)sender {
    [UIView animateWithDuration:0.25
                     animations:^{
                         sender.transform = CGAffineTransformMakeScale(3.0f, 3.0f);
                         sender.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(uploadVideoDidTouch)]) {
                             [self.delegate uploadVideoDidTouch];
                         }
                         [self removeFromSuperview];
                     }];
}

- (void) showInView:(UIView *)parentView {
    [parentView addSubview:self];
    
    _btnVideo.alpha = 1.0f;
    _btnPhoto.alpha = 1.0f;
    
    _btnVideo.transform = CGAffineTransformIdentity;
    _btnPhoto.transform = CGAffineTransformIdentity;
    
    _btnVideo.frame = _btnUpload.frame;
    _btnPhoto.frame = _btnUpload.frame;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _btnVideo.frame = _frameBtnVideo;
                         _btnPhoto.frame = _frameBtnPhoto;
                     } completion:^(BOOL finished) {
                         
                     }];
}

@end
