//
//  ValidationService.m
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "ValidationService.h"

@implementation ValidationService

+ (BOOL) checkValidInviteCode:(NSString *)strInviteCode {
    return (strInviteCode.length == DEF_INVITE_CODE_SIZE);
}

+ (BOOL) checkValidEmail:(NSString*) strEmail   {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

+ (BOOL) checkValidPassword:(NSString*) strPassword    {
    int minCountPass = DEF_PASSWORD_COUNT_MIN;
    
    if (strPassword.length >= minCountPass)
        return YES;
    return NO;
}

//  0: ok
// -1: low length
//  1: bad format
//  2: over length
+ (NSInteger) checkValidUsername:(NSString*) strUsername {
    strUsername = [strUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger length = [strUsername length];
    if (length < DEF_USERNAME_COUNT_MIN)
        return -1;
    else if (length > DEF_USERNAME_COUNT_MAX)
        return 2;
    else if ([strUsername containsString:@" "]) {
        return 1;
    }
    return 0;
}

+ (BOOL) checkValidName:(NSString*) strName {
    strName = [strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger length = [strName length];
    if (length > 0) {
        NSString *regex = @"^[A-Za-z ]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL result = [predicate evaluateWithObject:strName];
        if ([strName containsString:@"  "]) result = NO;
        return result;
    }
    return NO;
}

+ (BOOL) checkValidBio:(NSString*) strBio    {
    if (strBio.length > 0 && strBio.length <= DEF_BIO_COUNT_MAX)
        return YES;
    return NO;
}

@end
