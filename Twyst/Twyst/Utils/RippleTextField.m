//
//  RippleTextField.m
//  Twyst
//
//  Created by Nahuel Morales on 9/4/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//  Ripple effect over cursor after every time the user touches the textfield.
//
//  Based on the first step of the animated gif:
//  https://dribbble.com/shots/1254439--GIF-Float-Label-Form-Interaction?list=searches&tag=gif
//

#import "RippleTextField.h"

@interface RippleTextField () {
    BOOL _touchCancelled;
}

@end

@implementation RippleTextField

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _touchCancelled = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(cancelTouch:) userInfo:nil repeats:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (!_touchCancelled) [self animatefocus];
}

- (void)cancelTouch:(id)sender {
    _touchCancelled = YES;
}

#pragma mark - Animation

- (void)animatefocus {
    //Position & size
    CGFloat size = self.font.lineHeight *2.5;
    CGFloat position = self.selectedTextRange.empty ? [self caretRectForPosition:self.selectedTextRange.start].origin.x : 0;
    CGRect focusFrame = CGRectMake(self.frame.origin.x + position - (size/2.0), self.center.y - (size/2.0), size, size);
    
    // Config
    UIView *focusView = [[UIView alloc] initWithFrame:focusFrame];
    focusView.layer.cornerRadius = size/2.0;
    focusView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    focusView.alpha = 0.7;
    focusView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    // Animation
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.superview addSubview:focusView];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            focusView.transform = CGAffineTransformIdentity;
            focusView.alpha = 0.2;
        } completion:^(BOOL finished) {
            [focusView removeFromSuperview];
        }];
    });
}

@end
