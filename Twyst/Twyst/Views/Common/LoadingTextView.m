//
//  LoadingTextView.m
//  Twyst
//
//  Created by Niklas Ahola on 4/18/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "LoadingTextView.h"

@implementation LoadingTextView

- (id) init
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect frameLabelLoading = CGRectMake(0, height / 2, width, 25);
    self = [super initWithFrame:frameLabelLoading];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.text = @"Loading...";
        self.textColor = [UIColor blackColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont boldSystemFontOfSize:14];
    }
    return self;
}

- (void) showInView:(UIView*) parent    {
    if (self.superview) {
        [self removeFromSuperview];
    }
    [parent addSubview:self];
}
- (void) hide   {
    [self removeFromSuperview];
}

static LoadingTextView *_instance;
+ (LoadingTextView*) getStaticInstance {
    if (_instance == nil)   {
        _instance = [[LoadingTextView alloc] init];
    }
    return _instance;
}

+ (void) showInView:(UIView*) parent    {
    [[self getStaticInstance] showInView:parent];
}

+ (void) hide   {
    [[self getStaticInstance] hide];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
