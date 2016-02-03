//
//  NMTransitionIntro.m
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransitionAnimation.h"

@interface NMTransitionAnimation ()

@property (nonatomic) BOOL isFinished;
@property (nonatomic) BOOL isExecuting;

@end

@implementation NMTransitionAnimation

+ (instancetype)animationWithContainerView:(UIView *)containerView {
    NMTransitionAnimation *animation = [[[self class] alloc] init];
    animation.containerView = containerView;
    return animation;
}

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)main {
    [self setExecuting:YES];
    [self setFinished:NO];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self beginAnimation:^{
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

#pragma mark -

- (void)prepareAnimation {
    NSAssert(NO, @"Method %@ not implemented on class %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void)beginAnimation:(void(^)())completion {
    NSAssert(NO, @"Method %@ not implemented on class %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
    completion();
}

@end
