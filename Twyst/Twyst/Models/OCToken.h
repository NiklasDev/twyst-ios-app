//
//  OCUser.h
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCToken : NSObject

@property (nonatomic, retain) NSString *access_token;
@property (nonatomic, retain) NSString *token_type;
@property (nonatomic, assign) NSInteger expires_in;

+ (OCToken*)createNewTokenWithDictionary:(NSDictionary*)tokenDict;

@end
