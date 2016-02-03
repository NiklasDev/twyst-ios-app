//
//  LandingTextField.m
//  Twyst
//
//  Created by Niklas Ahola on 2/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "LandingTextField.h"

@implementation LandingTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addObservers];
}

- (void)setPlaceholderText:(NSString *)text color:(UIColor*)color font:(UIFont*)font {
    
    _placeholderText = text;
    _placeholderTextColor = color;
    
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:font}];
}

#pragma mark - Notifications
- (void) addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidBeginEditing:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidEndEditing:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidEndEditingNotification
                                                  object:nil];
}

- (void)handleDidBeginEditing:(NSNotification*)notification {
    UITextField *sender = (UITextField*)[notification object];
    if (sender == self) {
        //self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@""];
    }
}

- (void)handleDidEndEditing:(NSNotification*)notification {
    UITextField *sender = (UITextField*)[notification object];
    if (sender == self) {
        //self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_placeholderText attributes:@{NSForegroundColorAttributeName:_placeholderTextColor}];
    }
}

#pragma mark -

- (void)dealloc {
    [self removeObservers];
}

@end
