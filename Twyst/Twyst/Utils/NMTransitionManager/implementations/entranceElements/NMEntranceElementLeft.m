//
//  NMEntranceElementLeft.m
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMEntranceElementLeft.h"

@implementation NMEntranceElementLeft

- (CGSize)translateFromFrame:(CGRect)frame {
    return CGSizeMake(-(frame.origin.x + frame.size.width), 0);
}

@end
