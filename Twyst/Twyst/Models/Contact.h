//
//  Contact.h
//  upsi
//
//  Created by Mac on 3/24/14.
//  Copyright (c) 2014 Laith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
- (void)setValue:(id)value forKey:(NSString *)key;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *phone;

@end
