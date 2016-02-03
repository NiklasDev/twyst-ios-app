//
//  SubmitButtonStatePressedView.m
//  Twyst
//
//  Created by Nahuel Morales on 9/9/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "SubmitButtonStatePressedView.h"

@implementation SubmitButtonStatePressedView

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
    
    self.backgroundColor = self.color;
    self.layer.cornerRadius = self.frame.size.height / 2.0;
}

@end
