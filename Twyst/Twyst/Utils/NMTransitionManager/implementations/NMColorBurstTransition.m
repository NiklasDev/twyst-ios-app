//
//  NMColorBurstTransition.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMColorBurstTransition.h"
#import "NMEmptyTransitionAnimation.h"
#import "NMColorBurstTransitionAnimation.h"

@interface NMColorBurstTransition ()

@end

@implementation NMColorBurstTransition

- (instancetype)initWithContainerFrom:(UIView *)containerFrom
                            burstView:(UIView *)burstView
                          containerTo:(UIView *)containerTo {
    
    self = [super init];
    if (self) {
        self.fromAnimation = [NMColorBurstTransitionAnimation animationWithContainerView:containerFrom burstView:burstView];
        self.toAnimation = [NMEmptyTransitionAnimation animationWithContainerView:containerTo];
    }
    return self;
}

- (instancetype)initWithContainerFrom:(UIView *)containerFrom
                            burstView:(UIView *)burstView
                          containerTo:(UIView *)containerTo
                           burstColor:(UIColor *)burstColor {
    self = [super init];
    if (self) {
        self.fromAnimation = [NMColorBurstTransitionAnimation animationWithContainerView:containerFrom burstView:burstView burstColor:burstColor];
        self.toAnimation = [NMEmptyTransitionAnimation animationWithContainerView:containerTo];
    }
    return self;
}

@end
