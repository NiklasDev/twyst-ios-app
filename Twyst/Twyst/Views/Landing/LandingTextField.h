//
//  LandingTextField.h
//  Twyst
//
//  Created by Niklas Ahola on 2/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "RippleTextField.h"

@interface LandingTextField : RippleTextField

@property (nonatomic, retain) NSString *placeholderText;
@property (nonatomic, retain) UIColor *placeholderTextColor;

- (void)setPlaceholderText:(NSString *)text color:(UIColor*)color font:(UIFont*)font;

@end
