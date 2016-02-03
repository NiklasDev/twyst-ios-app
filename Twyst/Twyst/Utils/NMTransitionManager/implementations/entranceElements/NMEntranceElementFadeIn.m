//
//  NMEntranceElementFadeIn.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEntranceElementFadeIn.h"

@implementation NMEntranceElementFadeIn

- (void)prepareAnimation {
    self.elementView.alpha = 0.0;
}

- (void)beginAnimation:(void(^)())completion {
    [UIView animateWithDuration:self.duration delay:self.delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.elementView.alpha = 1.0;
    } completion:^(BOOL finished) {
        completion();
    }];
}

@end
