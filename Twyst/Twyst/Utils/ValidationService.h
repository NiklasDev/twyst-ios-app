//
//  ValidationService.h
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidationService : NSObject

+ (BOOL) checkValidInviteCode:(NSString *)strInviteCode;
+ (BOOL) checkValidEmail:(NSString*) strEmail;
+ (BOOL) checkValidPassword:(NSString*) strPassword;
+ (NSInteger) checkValidUsername:(NSString*) strUsername;
+ (BOOL) checkValidName:(NSString*) strName;
+ (BOOL) checkValidBio:(NSString*) strBio;

@end
