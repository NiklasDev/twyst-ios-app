//
//  FTextField.h
//  Twyst
//
//  Created by Niklas Ahola on 9/8/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTextField : UITextField

@property (nonatomic, retain) NSString *placeholderText;
@property (nonatomic, retain) UIColor *placeholderTextColor;

- (void)setPlaceholderInfo:(NSString*)string color:(UIColor*)color;

@end
