//
//  NMImageBurstTransitionAnimation.h
//  Twyst
//
//  Created by Nahuel Morales on 9/2/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransitionAnimation.h"

@interface NMImageBurstTransitionAnimation : NMTransitionAnimation

/**
 * View to be used as start point of the burst animation
 */
@property (nonatomic, strong) UIView *burstView;

/**
 * Image used for the burst animation
 */
@property (nonatomic, strong) UIImage *image;

+ (instancetype)animationWithContainerView:(UIView *)containerView burstView:(UIView *)view image:(UIImage *)burstImage;

@end
