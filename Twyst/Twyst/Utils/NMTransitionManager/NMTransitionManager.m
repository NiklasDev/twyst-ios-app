//
//  NMTransitionManager.m
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransitionManager.h"

@implementation NMTransitionManager

+ (instancetype)sharedInstance {
    static NMTransitionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.name = @"NMTransitionManager Queue";
    }
    return self;
}

- (void)beginTransition:(NMTransition *)transition {
    [transition executeTransition:self];
}

- (void)beginAnimation:(NMTransitionAnimation *)animation {
    animation.manager = self;
    [animation prepareAnimation];
    [self.operationQueue addOperation:animation];
}

- (void)beginAnimations:(NSArray *)animations {
    for (NMTransitionAnimation *animation in animations) {
        [self beginAnimation:animation];
    }
}

@end
