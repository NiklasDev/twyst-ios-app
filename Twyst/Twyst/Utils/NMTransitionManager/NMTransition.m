//
//  NMTransition.m
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransition.h"
#import "NMTransitionManager.h"

@interface NMTransition ()

@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isExecuting;

@end

@implementation NMTransition

- (void)executeTransition:(NMTransitionManager *)manager {
    
    self.fromAnimation.manager = manager;
    self.toAnimation.manager = manager;
    
    [self.fromAnimation prepareAnimation];
    [self.toAnimation prepareAnimation];
    
    [self addDependency:self.fromAnimation];
    [self.toAnimation addDependency:self];
    
    [manager.operationQueue addOperation:self.fromAnimation];
    [manager.operationQueue addOperation:self];
    [manager.operationQueue addOperation:self.toAnimation];
}

- (void)main {
    [self setExecuting:YES];
    [self setFinished:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performTransition:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setExecuting:NO];
                [self setFinished:YES];
            });
        }];
    });
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = executing;
    [self didChangeValueForKey:@"isExecuting"];
    
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = finished;
    [self didChangeValueForKey:@"isFinished"];

    NSArray *deps = [NSArray arrayWithArray:self.dependencies];
    for (NSOperation *op in deps) {
        [self removeDependency:op];
    }
}

- (void)performTransition:(void(^)())completionBlock {
    NSAssert(NO, @"Method %@ not implemented on class %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
    completionBlock();
}

@end
