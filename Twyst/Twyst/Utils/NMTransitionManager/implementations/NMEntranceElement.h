//
//  NMEntranceElement.h
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransitionAnimation.h"

@interface NMEntranceElement : NMTransitionAnimation

/**
 * Element to be animated
 */
@property (nonatomic, strong) UIView *elementView;

/**
 * Animation configuration
 */
@property (nonatomic, assign) CGFloat delay;
@property (nonatomic, assign) CGFloat duration;

+ (instancetype)animationWithContainerView:(UIView *)containerView elementView:(UIView *)elementView;
+ (instancetype)animationWithContainerView:(UIView *)containerView elementView:(UIView *)elementView duration:(CGFloat)duration;
+ (instancetype)animationWithContainerView:(UIView *)containerView elementView:(UIView *)elementView duration:(CGFloat)duration delay:(CGFloat)delay;

@end
