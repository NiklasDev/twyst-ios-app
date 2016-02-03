//
//  RCounter.m
//  Version 0.1
//
//
//  Created by Ans Riaz on 12/12/13.
//  Copyright (c) 2013 Rizh. All rights reserved.
//
//  Have fun :-)

#import "RCounter.h"

#define kCounterDigitStartY 0.0
#define kCounterDigitDiff 14.0

@interface RCounter ()

@end

@implementation RCounter {
    NSInteger digits;
    NSInteger tagCounterRightToLeft;
    NSInteger tagCounterLeftToRight;
    NSInteger tagComma;
}

- (void) incrementCounter:(BOOL)animate {
    [self updateCounter:(_currentReading + 1) animate:animate];
}

-(void) updateFrame:(UIImageView*)img withValue:(long)newValue andImageCentre:(CGPoint)imgCentre andImageFrame:(CGRect)frame animate:(BOOL)animate {
    if (animate) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
        anim.fromValue = [NSValue valueWithCGPoint:img.center];
        if (newValue == 0) {
            imgCentre.y = centerStart.y - 11 * kCounterDigitDiff;
            anim.toValue = [NSValue valueWithCGPoint:imgCentre];
        } else
            anim.toValue = [NSValue valueWithCGPoint:imgCentre];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.duration = 0.3;
        [img.layer addAnimation:anim forKey:@"rollLeft"];
        img.frame = frame;
    }
    else {
        img.frame = frame;
    }
}

- (void) updateCounter:(NSInteger)newValue animate:(BOOL)animate {

    // Only do something if it is different
    if (newValue == _currentReading)
        return;
    
    // Work out the digits
    NSInteger billion = (newValue % 10000000000)/1000000000;
    NSInteger hmillion = (newValue % 1000000000)/100000000;
    NSInteger tenmillion = (newValue % 100000000)/10000000;
    NSInteger million = (newValue % 10000000)/1000000;
    NSInteger hthousandth = (newValue % 1000000)/100000;
    NSInteger tenthounsandth = (newValue % 100000) / 10000;
    NSInteger thounsandth = (newValue % 10000)/1000;
    NSInteger hundredth = (newValue % 1000)/ 100;
    NSInteger ten = (newValue % 100) / 10;
    NSInteger unit = newValue % 10;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject: [NSNumber numberWithInteger:unit]];
    [array addObject: [NSNumber numberWithInteger:ten]];
    [array addObject: [NSNumber numberWithInteger:hundredth]];
    [array addObject: [NSNumber numberWithInteger:thounsandth]];
    [array addObject: [NSNumber numberWithInteger:tenthounsandth]];
    [array addObject: [NSNumber numberWithInteger:hthousandth]];
    [array addObject: [NSNumber numberWithInteger:million]];
    [array addObject: [NSNumber numberWithInteger:tenmillion]];
    [array addObject: [NSNumber numberWithInteger:hmillion]];
    [array addObject: [NSNumber numberWithInteger:billion]];
    
    BOOL isNumber = NO;
    for (NSInteger i = digits - 1; i >= 0; i--) {
        UIImageView *img = (UIImageView*)[self viewWithTag:(tagCounterLeftToRight + i)];
        
        CGRect imgFrame = img.frame;
        CGPoint imgCenter = img.center;
        
        imgFrame.origin.y = kCounterDigitStartY - (([array[i] integerValue] + 1) * kCounterDigitDiff);
        imgCenter.y = centerStart.y - (([array[i] integerValue] + 1) * kCounterDigitDiff);
        
        BOOL imgChanged = NO;
        
        if (imgFrame.origin.y != img.frame.origin.y) {
            imgChanged = YES;
        }
        if (imgChanged) {
            [self updateFrame:img withValue:[array[i] integerValue] andImageCentre:imgCenter andImageFrame:imgFrame animate:animate];
        }
        
        NSInteger tag = tagComma - ((digits - i) / 3);
        UIImageView *imgComma = (UIImageView*)[self viewWithTag:tag];
        imgComma.hidden = !isNumber;
        
        isNumber |= [array[i] integerValue];
        if (i == 0) {
            isNumber = YES;
        }
        img.hidden = !isNumber;
        
    }

    _currentReading = newValue;
}

#pragma mark - Init/Dealloc

- (id)initWithFrame:(CGRect)frame1 andNumberOfDigits:(NSInteger)_digits
{
    frame1.size.width = (_digits * 25) + 10;
    self = [super initWithFrame:frame1];
    if (self) {
        
        if (_digits > 10) {
            _digits = 10;
        }
        digits = _digits;
        
        tagCounterRightToLeft = 4025;
        tagCounterLeftToRight = tagCounterRightToLeft + 1 - digits;
        
        tagComma = 1000;
        
        // Load the background
        [self setBackgroundColor:[UIColor blackColor]];
        
        // Load the counters
        UIView *counterCanvas = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 14.0)];
        
        CGRect frame = CGRectMake(10.0, kCounterDigitStartY, 8.0, 182.0);
        for (int i = 0; i < digits; i++) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:frame];
            [img setImage:[UIImage imageNamed:@"counter-numbers.png"]];
            centerStart = img.center;
            
            [img setTag: (tagCounterRightToLeft - i)];
            [counterCanvas addSubview:img];
            frame.origin.x += 8;
            
            if (i < digits - 1 && ((digits - i) % 3) == 1) {
                UIImageView *imgComma = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x, 0, 5, 14)];
                [imgComma setImage:[UIImage imageNamed:@"comma.png"]];
                NSInteger tag = tagComma - (i / 3);
                [imgComma setTag:tag];
                [counterCanvas addSubview:imgComma];
                imgComma.hidden = YES;
                frame.origin.x += 5;
            }
        }
        
        [counterCanvas.layer setMasksToBounds:YES];
        [self addSubview:counterCanvas];
        
        // Set the current reading
        _currentReading = NSNotFound;
    }
    
    return self;
}

@end
