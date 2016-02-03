//
//  LandingPageControl.h
//  Twyst
//
//  Created by Niklas Ahola on 7/24/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandingPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) CGFloat indicatorMargin;

@property (nonatomic, strong) UIImage *pageIndicatorImage;
@property (nonatomic, strong) UIImage *currentPageIndicatorImage;

- (void)addElements;
- (void)startBeginAnimation;

@end
