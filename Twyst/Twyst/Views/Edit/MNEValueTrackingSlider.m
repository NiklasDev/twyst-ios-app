//
//  CustomSlider.m
//  Measures
//
//  Created by Michael Neuwert on 4/26/11.
//  Copyright 2011 Neuwert Media. All rights reserved.
//

#import "MNEValueTrackingSlider.h"

#define BUBBLE_OVERFLOW 60.0f

#pragma mark - Private UIView subclass rendering the popup showing slider value

@interface MNESliderValuePopupView : UIView {
    CGFloat _fontSize;
}

@property (nonatomic) float value;
@property (nonatomic) float cursorX;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) NSString *text;

@end

@implementation MNESliderValuePopupView

@synthesize value=_value;
@synthesize font=_font;
@synthesize text = _text;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initMembers];
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:_fontSize];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            _fontSize = 11.8;
            break;
        case DeviceTypePhone6Plus:
            _fontSize = 13;
            break;
        default:
            _fontSize = 11;
            break;
    }
}

- (void)dealloc {
    self.text = nil;
    self.font = nil;
}

- (void)drawRect:(CGRect)rect {
    
    // Set the fill color
    [Color(49, 49, 49) setFill];
    
    // Create the path for the rounded rectangle
    CGRect roundedRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, floorf(self.bounds.size.height * 0.75));
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:5.0];
    // Create the arrow path
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat midX = _cursorX - self.frame.origin.x;
    CGPoint p0 = CGPointMake(midX, CGRectGetMaxY(self.bounds));
    [arrowPath moveToPoint:p0];
    [arrowPath addLineToPoint:CGPointMake((midX - 8.0), CGRectGetMaxY(roundedRect))];
    [arrowPath addLineToPoint:CGPointMake((midX + 8.0), CGRectGetMaxY(roundedRect))];
    [arrowPath closePath];
    
    // Attach the arrow path to the rounded rect
    [roundedRectPath appendPath:arrowPath];
    
    [roundedRectPath fill];
    
    // Draw the text
    if (self.text) {
        [[UIColor colorWithWhite:1 alpha:1.0] set];
        CGSize s = [_text sizeWithFont:self.font];
        CGFloat yOffset = (roundedRect.size.height - s.height) / 2;
        CGRect textRect = CGRectMake(roundedRect.origin.x, yOffset, roundedRect.size.width, s.height);
        
        [_text drawInRect:textRect withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
}

- (void)setValue:(float)aValue {
    
    _value = 3 - (2 * aValue);

    self.text = [NSString stringWithFormat:@"%.2fs per photo", _value];
    [self setNeedsDisplay];
}

@end

#pragma mark - MNEValueTrackingSlider implementations

@implementation MNEValueTrackingSlider

@synthesize thumbRect;

#pragma mark - Private methods

- (void)_constructSlider {
    [self initMembers];
    valuePopupView = [[MNESliderValuePopupView alloc] initWithFrame:CGRectZero];
    valuePopupView.backgroundColor = [UIColor clearColor];
    valuePopupView.alpha = 0.0;
    [self addSubview:valuePopupView];
}

- (void)_fadePopupViewInAndOut:(BOOL)aFadeIn {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    if (aFadeIn) {
        valuePopupView.alpha = 1.0;
    } else {
        valuePopupView.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)_positionAndUpdatePopupView {
    CGFloat x = self.thumbRect.origin.x + self.thumbRect.size.width / 2 - _popWidth / 2;
    x = MIN(MAX(_popMarginX, x), self.frame.size.width - _popMarginX - _popWidth);
    CGRect popupRect = CGRectMake(x,
                                  self.thumbRect.origin.y - _popY,
                                  _popWidth,
                                  _popHeight);
    valuePopupView.frame =popupRect;
    valuePopupView.cursorX = self.thumbRect.origin.x + self.thumbRect.size.width / 2;
    valuePopupView.value = (float)self.value;
    
    if ([self.delegate respondsToSelector:@selector(sliderView:valueDidChange:)]) {
        CGFloat retVal = 3 - (2 * self.value);
        [self.delegate sliderView:self valueDidChange:retVal];
    }
}

#pragma mark - Memory management

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _constructSlider];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _constructSlider];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            _popWidth = 98;
            _popHeight = 35;
            _popY = 31;
            _popMarginX = -28;
            break;
        case DeviceTypePhone6Plus:
            _popWidth = 109;
            _popHeight = 39;
            _popY = 36;
            _popMarginX = -32;
            break;
        default:
            _popWidth = 88;
            _popHeight = 32;
            _popY = 29;
            _popMarginX = -25;
            break;
    }
}

#pragma mark - UIControl touch event tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Fade in and update the popup view
    CGPoint touchPoint = [touch locationInView:self];
    // Check if the knob is touched. Only in this case show the popup-view
    if(CGRectContainsPoint(CGRectInset(self.thumbRect, -12.0, -12.0), touchPoint)) {
        [self _positionAndUpdatePopupView];
        [self _fadePopupViewInAndOut:YES];
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Update the popup view as slider knob is being moved
    [self _positionAndUpdatePopupView];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Fade out the popoup view
    [self _fadePopupViewInAndOut:NO];
    [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark - Custom property accessors

- (CGRect)thumbRect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbR = [self thumbRectForBounds:self.bounds
                                   trackRect:trackRect
                                       value:self.value];
    thumbR.size.width = BUBBLE_OVERFLOW;
    thumbR.origin.x = thumbR.origin.x - 15;
    return thumbR;
}

@end