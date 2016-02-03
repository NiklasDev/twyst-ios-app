//
//  CircleProcessingView.m
//  Winck
//
//  Created by Niklas Ahola on 12/12/14.
//  Copyright (c) 2014 Fang Chen. All rights reserved.
//

#import "WDActivityIndicator.h"
#import "CircleProcessingView.h"

@interface CircleProcessingView ()   {
    WDActivityIndicator *_activityIndicator;
    
    BOOL _isWorking;
    float _processingDuration;
}
@end

@implementation CircleProcessingView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        CGRect bounds = [UIScreen mainScreen].bounds;
        self.frame = bounds;
        
        CGFloat size = UI_NEW_TOP_BAR_HEIGHT - UI_STATUS_BAR_HEIGHT;
        CGRect frame = CGRectMake(bounds.size.width - size, UI_STATUS_BAR_HEIGHT, size, size);
        _activityIndicator = [[WDActivityIndicator alloc] initWithFrame:frame];
        _activityIndicator.indicatorStyle = WDActivityIndicatorStyleGradientPurple;
        [_activityIndicator startAnimating];
        [self addSubview:_activityIndicator];
        
        //_processingDuration
        _processingDuration = 0.3;
    }
    return self;
}

#pragma Internal Methods
- (void)hide   {
    self.alpha = 1;
    [UIView animateWithDuration:_processingDuration animations:^{
        self.alpha = 0;
        _isWorking = NO;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)show   {
    self.alpha = 0;
    _isWorking = YES;
    [UIView animateWithDuration:_processingDuration animations:^{
        self.alpha = 1;
    }];
}

#pragma mark --

#pragma Public Methods
static CircleProcessingView *_instance;
+ (CircleProcessingView*) getStaticInstance {
    if (_instance == nil)   {
        _instance = [[CircleProcessingView alloc] init];
    }
    return _instance;
}

+ (void) showInView: (UIView*) view {
    [view addSubview:[self getStaticInstance]];
    [[self getStaticInstance] show];
}

+ (void) hide   {
    [[self getStaticInstance] hide];
}

#pragma mark --

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
