//
//  BounceButton.m
//  Twyst
//
//  Created by Niklas Ahola on 8/26/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BounceButton.h"
#import "UIView+Animation.h"

@implementation BounceButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addTarget:self action:@selector(handleButtonDownTouch:) forControlEvents:UIControlEventTouchDown];
}

+(id)buttonWithType:(UIButtonType)buttonType {
    BounceButton *button = [super buttonWithType:buttonType];
    [button addTarget:button action:@selector(handleButtonDownTouch:) forControlEvents:UIControlEventTouchDown];
    return button;
}

- (void)handleButtonDownTouch:(UIButton*)sender {
    [sender bounceAnimation:0.3f];
}

@end
