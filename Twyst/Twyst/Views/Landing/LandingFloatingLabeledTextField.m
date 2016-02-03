//
//  LandingFloatingLabeledTextView.m
//  Twyst
//
//  Created by Nahuel Morales on 8/26/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "LandingFloatingLabeledTextField.h"

const static CGFloat LandingFloatingLabelFontSize = 11.0f;

@implementation LandingFloatingLabeledTextField

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView {
    self.floatingLabelFont = [UIFont boldSystemFontOfSize:LandingFloatingLabelFontSize];
    self.floatingLabelTextColor = [UIColor grayColor];
}

- (void)setPlaceholderText:(NSString *)text color:(UIColor*)color font:(UIFont*)font {
    _placeholderText = text;
    _placeholderTextColor = color;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:font}];
}

@end