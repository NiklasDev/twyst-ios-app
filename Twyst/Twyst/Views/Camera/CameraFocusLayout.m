//
//  CameraFocusLayout.m
//  Twyst
//
//  Created by Niklas Ahola on 4/1/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CameraFocusLayout.h"
#import "CameraAutoFocusBox.h"

@interface CameraFocusLayout()  {
    CameraAutoFocusBox *_focusBox;
    CGFloat _totalDuration;
    CGFloat _frameDuration;
    NSTimer *_focusTimer;
    NSInteger _animateIndex;
}

@end

@implementation CameraFocusLayout

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        
        _focusBox = [[CameraAutoFocusBox alloc] init];
        _focusBox.alpha = 0;
        [self addSubview:_focusBox];
        
        self.isFocusing = YES;
        
        _totalDuration = 0.8f;
        _frameDuration = _totalDuration / 4;
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event   {
    [super touchesBegan:touches withEvent:event];
    if (self.isFocusing)    {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self actionDrawAutofocusBox:point];
        if (point.x >=0 && point.y >= 0 && point.x <= self.bounds.size.width && point.y <= self.bounds.size.height)    {
            if (self.delegate)  {
                CGPoint newPoint = CGPointMake(point.x / self.bounds.size.width, point.y / self.bounds.size.height);
                [self.delegate cameraPreviewDidTouch:newPoint];
            }
        }
    }   else    {
        if (self.delegate)  {
            //[self.delegate cameraPreviewDidBeginTouch];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event   {
    [super touchesEnded:touches withEvent:event];
    if (!self.isFocusing)    {
        //[self.delegate cameraPreviewDidEndTouch];
    }
}

- (void) actionDrawAutofocusBox:(CGPoint) point {
    [self bringSubviewToFront:_focusBox];
    _focusBox.alpha = 1.0f;
    _focusBox.center = point;
    
    [self startAnimateTimer];
}

#pragma mark - timer handle methods
- (void) startAnimateTimer {
    [self invalidateAnimateTimer];
    
    _focusBox.alpha = 1.0f;
    [_focusBox.outCircle.layer removeAllAnimations];
    _focusBox.outCircle.transform = CGAffineTransformIdentity;
    _animateIndex = 0;
    _focusTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(onAnimateTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void) invalidateAnimateTimer {
    if (_focusTimer) {
        [_focusTimer invalidate];
        _focusTimer = nil;
    }
}

- (void) onAnimateTimer:(NSTimer*)timer {
    if (_animateIndex > 40) {
        [self invalidateAnimateTimer];
        [self endFocusAnimation];
    }
    [self focusAnimation:_animateIndex];
    _animateIndex++;
}

- (void) focusAnimation:(NSInteger)index {
    CGFloat focusSize[] = {0.9f, 1.0f, 1.1f, 1.0f};
    CGFloat destSize = focusSize[index % 4];
    [UIView animateWithDuration:0.1f
                     animations:^{
                         _focusBox.outCircle.transform = CGAffineTransformMakeScale(destSize, destSize);
                     }];
}

- (void) endFocusAnimation {
    [_focusBox.outCircle.layer removeAllAnimations];
    [UIView animateWithDuration:0.2f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _focusBox.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                     } completion:^(BOOL finished) {
                         _focusBox.alpha = 0.0f;
                         _focusBox.transform = CGAffineTransformIdentity;
                     }];
}

- (void) hideFocus {
    [_focusBox.outCircle.layer removeAllAnimations];
    [_focusBox.layer removeAllAnimations];
    _focusBox.alpha = 0;
}

#pragma mark - public methods
- (void) adjustFocusDidFinish {
    [self invalidateAnimateTimer];
    [self endFocusAnimation];
}

- (void) reverseCamera {
    [self hideFocus];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
