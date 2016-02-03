//
//  NMEntranceTransitionAnimation.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEntranceTransitionAnimation.h"
#import "NMTransitionManager.h"

@interface NMEntranceTransitionAnimation ()

@property (nonatomic, strong) NSMutableArray *elements;

@end

@implementation NMEntranceTransitionAnimation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.elements = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Add elements
- (void)addEntranceElement:(NMEntranceElement *)entranceElement {
    [self.elements addObject:entranceElement];
}

- (void)addEntranceElements:(NSArray *)array {
    [self.elements addObjectsFromArray:array];
}

#pragma mark - Animation
- (void)prepareAnimation {
    [self.elements makeObjectsPerformSelector:@selector(prepareAnimation)];
}

- (void)beginAnimation:(void(^)())completion {
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        completion();
    }];
    
    for (NMEntranceElement *element in self.elements) {
        [blockOperation addDependency:element];
    }
    [self.manager.operationQueue addOperations:self.elements waitUntilFinished:NO];
    [self.manager.operationQueue addOperation:blockOperation];
}

@end
