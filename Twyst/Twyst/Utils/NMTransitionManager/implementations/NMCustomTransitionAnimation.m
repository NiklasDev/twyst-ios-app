//
//  NMCustomTransitionAnimation.m
//  Twyst
//
//  Created by Nahuel Morales on 9/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMCustomTransitionAnimation.h"

@implementation NMCustomTransitionAnimation

- (void)prepareAnimation {
    
}

- (void)beginAnimation:(void(^)())completion {
    self.animationBlock(completion);
}

@end
