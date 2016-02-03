//
//  IANLoadingView.m
//  Twyst
//
//  Created by Niklas Ahola on 1/8/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "IANLoadingView.h"
#import "WDActivityIndicator.h"

@interface IANLoadingView() {
    
}

@property (weak, nonatomic) IBOutlet WDActivityIndicator *activityIndicator;

@end

@implementation IANLoadingView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.frame = bounds;
    self.activityIndicator.indicatorStyle = WDActivityIndicatorStylePretzelGrey;
    [self.activityIndicator startAnimating];
}

@end
