//
//  NMCircleView.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMCircleView.h"

@implementation NMCircleView

+ (instancetype)circleWithColor:(UIColor *)color {
    NMCircleView *circleView = [[self alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
    circleView.color = color;
    return circleView;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillEllipseInRect(context, rect);
}

@end
