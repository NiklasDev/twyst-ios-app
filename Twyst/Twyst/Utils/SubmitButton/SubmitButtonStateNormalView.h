//
//  SubmitButtonStateNormalView.h
//  Twyst
//
//  Created by Nahuel Morales on 9/9/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface SubmitButtonStateNormalView : UIView

@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color;

@end
