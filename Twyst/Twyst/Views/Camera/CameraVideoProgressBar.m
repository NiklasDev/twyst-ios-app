//
//  CameraVideoProgressBar.m
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "YLProgressBar.h"
#import "CameraVideoProgressBar.h"

@interface CameraVideoProgressBar() {
    
}

@property (nonatomic, strong) YLProgressBar *progressBar;
@property (nonatomic, strong) UIImageView *imageGlow;

@end

@implementation CameraVideoProgressBar

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    _progressBar = [[YLProgressBar alloc] initWithFrame:self.bounds];
    _progressBar.progressTintColors        = @[Color(255, 84, 84), Color(255, 84, 84)];
    _progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    _progressBar.type                     = YLProgressBarTypeFlat;
    _progressBar.stripesColor             = Color(221, 68, 68);
    _progressBar.stripesWidth             = 8;
    _progressBar.stripesInterval          = 21;
    _progressBar.stripesDelta             = 30;
    _progressBar.hideTrack                = YES;
    [_progressBar setProgress:0];
    [self addSubview:_progressBar];
    
    UIImage *image = [UIImage imageNamedForDevice:@"ic-camera-video-bar-glow"];
    self.imageGlow = [[UIImageView alloc] initWithFrame:CGRectMake(-image.size.width / 2, 0, image.size.width, image.size.height)];
    self.imageGlow.image = image;
    [self addSubview:self.imageGlow];
}

- (void)setProgress:(CGFloat)progress {
    [_progressBar setProgress:progress animated:NO];
    
    CGFloat x = self.bounds.size.width * progress;
    self.imageGlow.frame = CGRectMake(x - self.imageGlow.frame.size.width / 2, 0, self.imageGlow.frame.size.width, self.imageGlow.frame.size.height);
}

@end
