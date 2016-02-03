//
//  OCUser.m
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "OCToken.h"

@implementation OCToken


+ (OCToken*)createNewTokenWithDictionary:(NSDictionary*)tokenDict{
    return [[OCToken alloc] initWithDictionary:tokenDict];
}

- (id) init {
    self = [super init];
    if (self)   {
        self.access_token=@"";
        self.token_type = @"";
        self.expires_in = 0;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary*)tokenDic {
    self = [super init];
    if (self) {
        self.expires_in = 0;
        self.token_type = @"";
        self.access_token = @"";
        
        NSNumber *expires_in = [tokenDic objectForKey:@"expires_in"];
        NSString *access_token = [tokenDic objectForKey:@"access_token"];
        
        NSString *token_type = [tokenDic objectForKey:@"token_type"];
       
        
        self.expires_in = [expires_in longValue];
        self.access_token = IsNSStringValid(access_token) ? access_token : @"";
        self.token_type = IsNSStringValid(token_type) ? token_type : @"";
    }
    return self;
}

@end

