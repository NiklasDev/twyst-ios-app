//
//  LandingPageControl.m
//  Twyst
//
//  Created by Niklas Ahola on 7/24/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "LandingPageControl.h"

@interface LandingPageControl() {
    NSMutableArray *_arrayIndicators;
}

@end

@implementation LandingPageControl

- (void)awakeFromNib {
    [super awakeFromNib];
    _currentPage = 0;
}

- (void)addElements {
    _arrayIndicators = [NSMutableArray new];
    
    CGRect bounds = self.bounds;
    for (NSInteger i = 0; i < _numberOfPages; i++) {
        UIImageView *indicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        indicator.contentMode = UIViewContentModeCenter;
        indicator.clipsToBounds = NO;
        indicator.center = CGPointMake((bounds.size.width - _indicatorMargin * (_numberOfPages - 1)) / 2 + _indicatorMargin * i, bounds.size.height / 2);
        indicator.image = (_currentPage == i) ? _currentPageIndicatorImage : _pageIndicatorImage;
        [self addSubview:indicator];
        [_arrayIndicators addObject:indicator];
    }
}

- (void)startBeginAnimation {
    for (NSInteger i = 0; i < _numberOfPages; i++) {
        UIImageView *indicator = [_arrayIndicators objectAtIndex:i];
        indicator.alpha = 0.0f;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelay:0.15 * i];
        indicator.alpha = 1.0f;
        [UIView commitAnimations];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    for (NSInteger i = 0; i < _numberOfPages; i++) {
        UIImageView *indicator = [_arrayIndicators objectAtIndex:i];
        indicator.image = (_currentPage == i) ? _currentPageIndicatorImage : _pageIndicatorImage;
    }
}

@end
