//
//  UITabBar+NewSize.m
//  Twyst
//
//  Created by Niklas Ahola on 7/1/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UITabBar+NewSize.h"

@implementation UITabBar (NewSize)

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(size.width, UI_TAB_BAR_HEIGHT);
    return newSize;
}

@end
