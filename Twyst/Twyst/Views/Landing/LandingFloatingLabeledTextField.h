//
//  LandingFloatingLabeledTextView.h
//  Twyst
//
//  Created by Nahuel Morales on 8/26/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "JVFloatLabeledTextField.h"

@interface LandingFloatingLabeledTextField : JVFloatLabeledTextField

@property (nonatomic, retain) NSString *placeholderText;
@property (nonatomic, retain) UIColor *placeholderTextColor;

- (void)setPlaceholderText:(NSString *)text color:(UIColor*)color font:(UIFont*)font;

@end
