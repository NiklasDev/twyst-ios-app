//
//  NMEntranceElementScaleIn.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEntranceElementScaleIn.h"

@interface NMEntranceElementScaleIn () {
    CGAffineTransform _originalTransform;
}
@end

@implementation NMEntranceElementScaleIn

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.horizontalScaleEnabled = YES;
        self.verticalScaleEnabled = YES;
    }
    return self;
}
- (void)prepareAnimation {
    _originalTransform = self.elementView.transform;
    self.elementView.transform = CGAffineTransformScale(_originalTransform, self.horizontalScaleEnabled ? 0 : 1, self.verticalScaleEnabled ? 0 : 1);
}

- (void)beginAnimation:(void(^)())completion {
    [UIView animateWithDuration:self.duration delay:self.delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.elementView.transform = _originalTransform;
    } completion:^(BOOL finished) {
        completion();
    }];
}

@end
