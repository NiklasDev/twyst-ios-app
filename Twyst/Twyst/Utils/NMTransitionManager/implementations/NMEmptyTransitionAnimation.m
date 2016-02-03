//
//  NMEmptyTransitionAnimation.m
//  Twyst
//
//  Created by Nahuel Morales on 8/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEmptyTransitionAnimation.h"

@implementation NMEmptyTransitionAnimation

- (void)prepareAnimation {
    
}

- (void)beginAnimation:(void(^)())completion {
    completion();
}

@end
