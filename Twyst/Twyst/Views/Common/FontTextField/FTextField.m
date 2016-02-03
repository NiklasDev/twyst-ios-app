//
//  FTextField.m
//  Twyst
//
//  Created by Niklas Ahola on 9/8/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FTextField.h"

@implementation FTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib {
    // Initialization code
//    [self addObservers];
}

- (void)setPlaceholderInfo:(NSString*)string color:(UIColor *)color {
    _placeholderText = string;
    _placeholderTextColor = color;
    
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_placeholderText attributes:@{NSForegroundColorAttributeName:_placeholderTextColor}];
}

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

- (void) removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidEndEditingNotification
                                                  object:nil];
}
     
- (void) handleDidBeginEditing:(NSNotification*)notification {
    UITextField *sender = (UITextField*)[notification object];
    if (sender == self) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@""];
    }
}

- (void) handleDidEndEditing:(NSNotification*)notification {
    UITextField *sender = (UITextField*)[notification object];
    if (sender == self) {
        [self setPlaceholderInfo:_placeholderText color:_placeholderTextColor];
    }
}

- (void) dealloc {
//    [self removeObservers];
}

@end
