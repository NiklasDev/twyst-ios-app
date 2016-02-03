//
//  NMEntranceElementTranslate.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEntranceElementTranslate.h"

@interface NMEntranceElementTranslate () {
    CGAffineTransform _originalTransform;
}
@end

@implementation NMEntranceElementTranslate

- (void)prepareAnimation {
    CGRect relativeFrame = [self.containerView convertRect:self.elementView.frame fromView:self.elementView.superview];
    _originalTransform = self.elementView.transform;
    CGSize translate = [self translateFromFrame:relativeFrame];
    self.elementView.transform = CGAffineTransformTranslate(self.elementView.transform,
                                                            translate.width * (self.fadeIn ? 0.2 : 1.0),
                                                            translate.height * (self.fadeIn ? 0.2 : 1.0));
    
    self.elementView.alpha = self.fadeIn ? 0.0 : 1.0;
}

- (void)beginAnimation:(void(^)())completion {
    [UIView animateWithDuration:self.duration delay:self.delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.elementView.transform = _originalTransform;
        self.elementView.alpha = 1.0;
    } completion:^(BOOL finished) {
        completion();
    }];
}

- (CGSize)translateFromFrame:(CGRect)frame {
    return CGSizeMake(0, 0);
}

@end
