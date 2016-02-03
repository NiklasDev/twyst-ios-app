//
//  HeaderLabel.m
//  Twyst
//
//  Created by Wang Fang on 3/18/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "HeaderLabel.h"

@implementation HeaderLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Seravek-Medium" size:[self headerFontSize]];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont fontWithName:@"Seravek-Medium" size:[self headerFontSize]];
    }
    return self;
}

- (CGFloat)headerFontSize {
    CGFloat headerFontSize = 0;
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            headerFontSize = 20;
            break;
        case DeviceTypePhone6Plus:
            headerFontSize = 22.0f;
            break;
        default:
            headerFontSize = 19;
            break;
    }
    return headerFontSize;
}

@end
