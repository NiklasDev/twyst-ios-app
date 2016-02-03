//
//  UIPlaceHolderTextView.m
//  Twyst
//
//  Created by Niklas Ahola on 3/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NSString+Extension.h"
#import "UIPlaceHolderTextView.h"

@interface UIPlaceHolderTextView ()

@property (nonatomic, retain) UILabel *placeHolderLabel;

@end

@implementation UIPlaceHolderTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if __has_feature(objc_arc)
#else
    [_placeHolderLabel release]; _placeHolderLabel = nil;
    [_placeholderColor release]; _placeholderColor = nil;
    [_placeholder release]; _placeholder = nil;
    [super dealloc];
#endif
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    [self initTextView];
    
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self initTextView];
    }
    return self;
}

- (void)initTextView {
    UIColor *plColor = [UIColor whiteColor];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:plColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textBeginEditting) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEndEditting) name:UITextViewTextDidEndEditingNotification object:nil];
    
    self.font = [self fontForDevice];
}

- (void)textBeginEditting   {
    [[self viewWithTag:999] setAlpha:0];
}

- (void)textEndEditting {
    if ([self.text length] == 0)    {
        [[self viewWithTag:999] setAlpha:1];
    }   else    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)textChanged
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    UIView *view = [self viewWithTag:999];
    if([[self text] length] == 0)
    {
        [view setAlpha:1];
    }
    else
    {
        [view setAlpha:0];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeHolderLabel == nil )
        {
            CGSize size = [self.placeholder stringSizeWithFont:self.font constrainedToWidth:self.bounds.size.width - 16];
            CGRect frame = CGRectMake(8, 8, self.bounds.size.width - 16, size.height);
            _placeHolderLabel = [[UILabel alloc] initWithFrame:frame];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.textAlignment = NSTextAlignmentCenter;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [self sendSubviewToBack:_placeHolderLabel];
    }

    if( !self.isFirstResponder && [[self placeholder] length] > 0 && [[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

- (UIFont*)fontForDevice {
    UIFont *font = nil;
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            font = [UIFont fontWithName:@"HelveticaNeue" size:22];
            break;
        case DeviceTypePhone6Plus:
            font = [UIFont fontWithName:@"HelveticaNeue" size:24];
            break;
        default:
            font = [UIFont fontWithName:@"HelveticaNeue" size:18];
            break;
    }
    return font;
}

@end

