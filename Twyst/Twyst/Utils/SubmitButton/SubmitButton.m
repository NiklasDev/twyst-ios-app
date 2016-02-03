//
//  SubmitButton.m
//  Twyst
//
//  Created by Nahuel Morales on 9/9/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "SubmitButton.h"
#import "SubmitButtonStateNormalView.h"
#import "SubmitButtonStatePressedView.h"
#import "SubmitButtonSpinnerView.h"

#import <QuartzCore/QuartzCore.h>

@interface SubmitButton ()

@property (nonatomic, strong) SubmitButtonStateNormalView *stateNormalView;
@property (nonatomic, strong) SubmitButtonStatePressedView *statePressedView;
@property (nonatomic, strong) SubmitButtonSpinnerView *spinnerView;

@property (nonatomic, assign) BOOL isLoading;

@end

@implementation SubmitButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView {
    self.stateNormalView = [[SubmitButtonStateNormalView alloc] initWithFrame:self.bounds color:self.tintColor];
    self.statePressedView = [[SubmitButtonStatePressedView alloc] initWithFrame:self.bounds color:self.tintColor];
    self.spinnerView = [[SubmitButtonSpinnerView alloc] initWithFrame:self.bounds color:self.tintColor];
    [self insertSubview:self.spinnerView belowSubview:self.titleLabel];
    [self insertSubview:self.stateNormalView belowSubview:self.titleLabel];
    [self insertSubview:self.statePressedView belowSubview:self.titleLabel];
    
    self.spinnerView.alpha = 0.0;
    [self updateViewOnTouch];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.stateNormalView.color = tintColor;
    self.statePressedView.color = tintColor;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.stateNormalView.frame = self.bounds;
    self.statePressedView.frame = self.bounds;
    self.spinnerView.frame = self.bounds;
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isLoading) {
        BOOL touchInside = [self isTouchInside];
        self.titleLabel.textColor = touchInside ? [UIColor whiteColor] : [self tintColor];
    } else {
        self.titleLabel.textColor = [UIColor clearColor];
    }
}

#pragma mark - Loading

- (void)startLoading {
    [self updateViewOnTouch];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.isLoading = YES;
        CGRect centeredRectangle = CGRectMake((self.bounds.size.width - self.bounds.size.height)/2.0, 0, self.bounds.size.height, self.bounds.size.height);
        [self animateView:self.stateNormalView toFrame:centeredRectangle alpha:0.0];
        [self animateView:self.spinnerView toFrame:centeredRectangle alpha:1.0 completion:^{
            [self.spinnerView startLoading];
        }];
    });
}

- (void)stopLoading {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.isLoading = NO;
        [self.spinnerView stopLoading];
        [self animateView:self.spinnerView toFrame:self.bounds alpha:0.0];
        [self animateView:self.stateNormalView toFrame:self.bounds alpha:1.0];
        [self updateViewOnTouch];
    });
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self updateViewOnTouch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self updateViewOnTouch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self updateViewOnTouch];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self updateViewOnTouch];
}

- (void)updateViewOnTouch {
    if (!self.isLoading) {
        BOOL touchInside = [self isTouchInside];
        self.titleLabel.alpha = 1.0;
        
        self.stateNormalView.hidden = touchInside;
        self.statePressedView.hidden = !touchInside;
        
        [self setNeedsLayout];
    } else {
        self.titleLabel.alpha = 0.0;
    }
}



#pragma mark - Layers

- (void)animateView:(UIView *)view toFrame:(CGRect)frame {
    [self animateView:view toFrame:frame alpha:view.alpha];
}

- (void)animateView:(UIView *)view toFrame:(CGRect)frame alpha:(CGFloat)alpha {
    [self animateView:view toFrame:frame alpha:alpha completion:^{}];
}

- (void)animateView:(UIView *)view toFrame:(CGRect)frame alpha:(CGFloat)alpha completion:(void(^)(void))completion {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        view.frame = frame;
        view.alpha = alpha;
    } completion:^(BOOL finished) {
        completion();
    }];
}

@end
