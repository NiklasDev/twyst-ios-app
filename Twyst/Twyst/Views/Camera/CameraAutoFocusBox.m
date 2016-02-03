//
//  CameraAutoFocusBox.m
//  Twyst
//
//  Created by Niklas Ahola on 4/1/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "CameraAutoFocusBox.h"

@implementation CameraAutoFocusBox

- (id)init
{
    float s = 83;
    CGRect frame = CGRectMake(0, 0, s, s);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _outCircle = [[UIImageView alloc] initWithFrame:frame];
        _outCircle.image = [UIImage imageNamedContentFile:@"ic-camera-focus-circle"];
        [self addSubview:_outCircle];
        
        _centerCircle = [[UIImageView alloc] initWithFrame:frame];
        _centerCircle.image = [UIImage imageNamedContentFile:@"ic-camera-focus-center"];
        [self addSubview:_centerCircle];
    }
    return self;
}

@end
