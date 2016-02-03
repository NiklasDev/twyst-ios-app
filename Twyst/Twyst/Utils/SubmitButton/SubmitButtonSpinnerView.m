//
//  SubmitButtonSpinnerView.m
//  Twyst
//
//  Created by Nahuel Morales on 9/10/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "SubmitButtonSpinnerView.h"

#define kSubmitButtonSpinnerView_BorderWidth 4.0
#define kSubmitButtonSpinnerView_ArcAngleStep 5.0
#define kSubmitButtonSpinnerView_ArcAngleStepDuration 0.02

@interface SubmitButtonSpinnerView ()

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) CGFloat currentArcAngle;
@property (nonatomic, strong) NSTimer *animationTimer;

@end

@implementation SubmitButtonSpinnerView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.color = color;
        self.secondColor = [UIColor lightGrayColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.borderWidth = kSubmitButtonSpinnerView_BorderWidth;
    self.layer.borderColor = self.isLoading ? [UIColor clearColor].CGColor : self.secondColor.CGColor;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.isLoading) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, kSubmitButtonSpinnerView_BorderWidth);
        
        CGFloat radius = (self.bounds.size.height - kSubmitButtonSpinnerView_BorderWidth) / 2.0;
        CGFloat center = self.bounds.size.height/2.0;
        
        CGContextSetStrokeColorWithColor(context, self.secondColor.CGColor);
        CGContextAddArc(context, center, center, radius, 0, M_PI *2.0, 1);
        
        CGContextStrokePath(context);
        
        CGFloat realAngle = self.currentArcAngle - 360.0 * ((int)self.currentArcAngle / 360);
        BOOL isFirstStep = ((int)self.currentArcAngle / 360) % 2 == 0;
        CGFloat offset = -M_PI_2;
        CGFloat endAngleRad = ((realAngle + 0.1) / 360.0) * 2.0 * M_PI;
        
        if (!isFirstStep) {
            NSLog(@"");
        }
        
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextAddArc(context, center, center, radius, (isFirstStep ? 0 : endAngleRad) + offset, (isFirstStep ? endAngleRad : 0) + offset, 0);

        CGContextStrokePath(context);
    }
}

#pragma mark - Loading

- (void)startLoading {
    self.isLoading = YES;
    self.currentArcAngle = 0.0;
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:kSubmitButtonSpinnerView_ArcAngleStepDuration
                                                           target:self
                                                         selector:@selector(updateArc)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)stopLoading {
    self.isLoading = NO;
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)updateArc {
    self.currentArcAngle += kSubmitButtonSpinnerView_ArcAngleStep;
    //if (self.currentArcAngle > 360) self.currentArcAngle = 0.0;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

@end
