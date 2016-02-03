//
//  Contact.m
//  upsi
//
//  Created by Mac on 3/24/14.
//  Copyright (c) 2014 Laith. All rights reserved.
//

#import "Contact.h"

@implementation Contact

#pragma mark - NSObject - Creating, Copying, and Deallocating Objects

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:attributes];
    }
    
    return self;
}

#pragma mark - NSKeyValueCoding Protocol

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"fullName"]) {
        self.fullName = [NSString stringWithString:value];
    } else if ([key isEqualToString:@"phone"]) {
        self.phone = IsNSStringValid(value) ? [NSString stringWithString:value] : nil;
    }
}

@end
