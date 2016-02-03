//
//  UserLocalServices.h
//  Twyst
//
//  Created by Niklas Ahola on 5/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCUser.h"
#import "TUserManager.h"

@interface UserLocalServices : NSObject
+ (id) sharedInstance;

@property (nonatomic, retain) NSString *inviteCode;

@property (nonatomic, retain) OCUser *ocUser;
@property (nonatomic, retain) TUser *tUser;

- (void) updateOCUser:(OCUser*) ocUser;
- (void) recoverOCUser;
- (void) saveOCUser;
- (void) logOut;

@end
