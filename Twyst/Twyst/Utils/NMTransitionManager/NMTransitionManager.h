//
//  NMTransitionManager.h
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//  Singleton Class
//
//  This class manage the right execution of the transitions / animations given.
//  Every Transition and animation is based on NSOperation

#import <Foundation/Foundation.h>
#import "NMTransition.h"

@interface NMTransitionManager : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;

+ (instancetype)sharedInstance;

- (void)beginTransition:(NMTransition *)transition;
- (void)beginAnimation:(NMTransitionAnimation *)animation;
- (void)beginAnimations:(NSArray *)animations;

@end
