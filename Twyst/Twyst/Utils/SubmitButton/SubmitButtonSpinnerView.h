//
//  SubmitButtonSpinnerView.h
//  Twyst
//
//  Created by Nahuel Morales on 9/10/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitButtonSpinnerView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *secondColor;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color;

- (void)startLoading;
- (void)stopLoading;

@end
