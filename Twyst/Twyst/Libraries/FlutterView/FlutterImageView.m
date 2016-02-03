//
//  FlutterImageView.m
//  Twyst
//
//  Created by Niklas Ahola on 9/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIView+Animation.h"
#import "FlutterImageView.h"

@interface FlutterImageView() {
    NSTimer *_timer;
    CGFloat _swayVelocity;
    BOOL _isRight;
    CGFloat _startX;
    NSTimeInterval _prev;
    NSTimeInterval _lifeCycle;
}

@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign) CGFloat sway;
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation FlutterImageView

- (void)flutterAnimation:(CGFloat)velocity sway:(CGFloat)sway duration:(NSTimeInterval)duration {
    _velocity = velocity;
    _sway = sway;
    _duration = duration;
    _isRight = [self randomBoolean];
    _swayVelocity = [self randomFloatBetween:15 and:24];
    _startX = self.center.x;
    [self bounceAnimation:0.2f scale:0.2f];
    [self startTimer];
}

#pragma mark - internal methods
- (void)startTimer {
    _prev = [NSDate timeIntervalSinceReferenceDate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                              target:self
                                            selector:@selector(onTimer:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)invalidateTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimer:(id)sender {
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = now - _prev;
    _lifeCycle += delta;
    if (_duration < _lifeCycle) {
        [self invalidateTimer];
        [self removeFromSuperview];
    }
    else {
        [self updateViewPosition:delta];
        _prev = now;
    }
}

- (void)updateViewPosition:(NSTimeInterval)delta {
    CGPoint center = self.center;
    center.y += (_velocity * delta);
    
    CGFloat deltaX = _swayVelocity * delta;
    deltaX = _isRight ? deltaX : -deltaX;
    center.x += deltaX;
    if (fabs(_startX - center.x) > _sway) {
        _isRight = !_isRight;
    }
    
    self.center = center;
    
    CGFloat alpha = 1 - (_lifeCycle / _duration);
    self.alpha = alpha;
}

- (CGFloat)randomFloatBetween:(CGFloat)smallNumber and:(CGFloat)bigNumber {
    CGFloat diff = bigNumber - smallNumber;
    return (((CGFloat) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (BOOL)randomBoolean {
    return (arc4random() > (RAND_MAX) / 2);
}

@end
