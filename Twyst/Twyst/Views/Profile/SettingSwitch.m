//
//  SettingSwitch.m
//  Twyst
//
//  Created by Niklas Ahola on 8/18/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "SettingSwitch.h"

@implementation SettingSwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tintColor = Color(0, 198, 181);
        self.onTintColor = Color(0, 198, 181);
    }
    return self;
}

@end