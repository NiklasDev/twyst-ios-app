//
//  NMEntranceElementTop.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEntranceElementTop.h"

@implementation NMEntranceElementTop

- (CGSize)translateFromFrame:(CGRect)frame {
    return CGSizeMake(0, -(frame.origin.y + frame.size.height));
}

@end
