//
//  UIView+Animation.h
//  Twyst
//
//  Created by Niklas Ahola on 8/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)

- (void)startPulseAnimation:(CGFloat)pulseScale duration:(CGFloat)duration;
- (void)stopPulseAnimation;

- (void)bounceAnimation:(CGFloat)duration;
- (void)bounceAnimation:(CGFloat)duration scale:(CGFloat)scale;

@end
