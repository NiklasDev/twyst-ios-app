//
//  NMEntranceElement.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEntranceElement.h"

@implementation NMEntranceElement

+ (instancetype)animationWithContainerView:(UIView *)containerView elementView:(UIView *)elementView {
    NMEntranceElement *element = [self animationWithContainerView:containerView];
    element.elementView = elementView;
    return element;
}

+ (instancetype)animationWithContainerView:(UIView *)containerView elementView:(UIView *)elementView duration:(CGFloat)duration {
    NMEntranceElement *element = [self animationWithContainerView:containerView elementView:elementView];
    element.duration = duration;
    return element;
}

+ (instancetype)animationWithContainerView:(UIView *)containerView elementView:(UIView *)elementView duration:(CGFloat)duration delay:(CGFloat)delay {
    NMEntranceElement *element = [self animationWithContainerView:containerView elementView:elementView duration:duration];
    element.delay = delay;
    return element;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0.3;
        self.delay = 0.0;
    }
    return self;
}

@end
