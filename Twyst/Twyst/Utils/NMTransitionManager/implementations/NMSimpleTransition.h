//
//  NMSimpleTransition.h
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//  Simple implementation of a transition with the execution of
//  the transition wrapped in a block with empty animations.
//
//  Default animations can be modified after an instance is created.

#import "NMTransition.h"

@interface NMSimpleTransition : NMTransition

/**
 * Execution setted to be executed instead of 'performTransition:'
 */
@property (nonatomic, strong) void (^transitionBlock)(void(^)(void));

@end
