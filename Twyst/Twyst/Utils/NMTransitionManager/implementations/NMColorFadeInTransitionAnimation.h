//
//  NMColorFadeInTransitionAnimation.h
//  Twyst
//
//  Created by Nahuel Morales on 9/1/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransitionAnimation.h"

@interface NMColorFadeInTransitionAnimation : NMTransitionAnimation

/**
 * Color used to fadeIn
 */
@property (nonatomic, strong) UIColor *color;

+ (instancetype)animationWithContainerView:(UIView *)containerView color:(UIColor *)color;

@end
