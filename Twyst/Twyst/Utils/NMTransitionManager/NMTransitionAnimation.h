//
//  NMTransitionIntro.h
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NMTransitionManager;

@interface NMTransitionAnimation : NSOperation

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) NMTransitionManager *manager;

/**
 * Static instance getter
 */
+ (instancetype)animationWithContainerView:(UIView *)containerView;

/**
 * Methods implemented in subclasses
 */
- (void)prepareAnimation;
- (void)beginAnimation:(void(^)())completion;

@end
