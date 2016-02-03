//
//  SubmitButtonStateNormalView.m
//  Twyst
//
//  Created by Nahuel Morales on 9/9/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "SubmitButtonStateNormalView.h"

@implementation SubmitButtonStateNormalView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.color = color;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [self color].CGColor;
}

@end
