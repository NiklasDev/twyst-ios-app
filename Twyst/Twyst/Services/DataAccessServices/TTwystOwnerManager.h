//
//  TTwystOwnerManager.h
//  Twyst
//
//  Created by Niklas Ahola on 5/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "TTwystOwner.h"

@interface TTwystOwnerManager : DataManager

- (TTwystOwner*) getOwnerWithUserId:(long)userId;
- (TTwystOwner*) confirmTwystOwnerWithOCUser:(OCUser*)ocUser;
- (TTwystOwner*) confirmTwystOwnerWithUserDict:(NSDictionary*)userDict;
- (OCUser*) getOCUserFromTwystOwner:(TTwystOwner*)mOwner;

@end
