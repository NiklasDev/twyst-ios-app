//
//  NMCircleView.h
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//  Simple Circle view

#import <UIKit/UIKit.h>

@interface NMCircleView : UIView

@property (nonatomic, strong) UIColor *color;

+ (instancetype)circleWithColor:(UIColor *)color;

@end
