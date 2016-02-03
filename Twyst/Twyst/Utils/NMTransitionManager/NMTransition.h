//
//  NMTransition.h
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "NMTransitionAnimation.h"

@class NMTransitionManager;

@interface NMTransition : NSOperation

/**
 * Animation executed before the transition 'performTransition:' method is run.
 */
@property (nonatomic, strong) NMTransitionAnimation *fromAnimation;

/**
 * Animation executed after the transition 'completionBlock' from 'performTransition:' method is run.
 */
@property (nonatomic, strong) NMTransitionAnimation *toAnimation;

/**
 * Method called by TransitionManager
 * This Method should be never called.
 */
- (void)executeTransition:(NMTransitionManager *)manager;

/**
 * Method to be implemented in subclasses
 */
- (void)performTransition:(void(^)())completionBlock;

@end
