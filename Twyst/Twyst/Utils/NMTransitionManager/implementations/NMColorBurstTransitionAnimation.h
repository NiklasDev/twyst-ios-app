//
//  NMColorBurstTransitionAnimation.h
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//
#import "NMTransitionAnimation.h"

@interface NMColorBurstTransitionAnimation : NMTransitionAnimation

/**
 * View to be used as start point of the burst animation
 */
@property (nonatomic, strong) UIView *burstView;

/**
 * Color used as burst color.
 * If the color is nil, burstView tint color is used instead.
 */
@property (nonatomic, strong) UIColor *burstColor;

+ (instancetype)animationWithContainerView:(UIView *)containerView burstView:(UIView *)burstView;
+ (instancetype)animationWithContainerView:(UIView *)containerView burstView:(UIView *)burstView burstColor:(UIColor *)burstColor;

@end
