//
//  NMSimpleTransition.m
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMSimpleTransition.h"
#import "NMEmptyTransitionAnimation.h"

@implementation NMSimpleTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fromAnimation = [NMEmptyTransitionAnimation animationWithContainerView:nil];
        self.toAnimation = [NMEmptyTransitionAnimation animationWithContainerView:nil];
    }
    return self;
}

- (void)performTransition:(void(^)())completionBlock {
    self.transitionBlock(completionBlock);
}

@end
