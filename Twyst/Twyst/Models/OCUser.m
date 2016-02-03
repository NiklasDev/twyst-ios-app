//
//  OCUser.m
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "OCUser.h"

@implementation OCUser

+ (OCUser*)createNewUserWithDictionary:(NSDictionary*)userDict {
    return [[OCUser alloc] initWithDictionary:userDict];
}

- (id) init {
    self = [super init];
    if (self)   {
        self.Id = 0;
        self.FirstName = @"";
        self.LastName = @"";
        self.EmailAddress = @"";
        self.CreatedDate = [NSDate date];
        self.CoverPhoto = @"";
        self.PrivateProfile = NO;
        self.ForgotPass = NO;
        self.TwystCreated = 0;
        self.LikeCount = 0;
        self.Followers = 0;
        self.Following = 0;
        self.Phonenumber = @"";
        self.Bio = @"";
        self.Verified = NO;
        self.ProfilePicName = @"";
        self.UserName = @"";
        self.VerifyCode = @"";
        
        self.SendNewStringgNot = YES;
        self.SendReplyNot = YES;
        self.SendNewStringgNot = YES;
        self.SendLikeNot = YES;
        self.SendFriendNot = YES;

        self.Password = @"";
        self.Token = @"";
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary*)userDict {
    self = [super init];
    if (self) {
        NSNumber *Id = [userDict objectForKey:@"Id"];
        NSString *FirstName = [userDict objectForKeyedSubscript:@"FirstName"];
        NSString *LastName = [userDict objectForKeyedSubscript:@"LastName"];
        NSString *EmailAddress = [userDict objectForKey:@"EmailAddress"];
        NSString *CreatedDate = [userDict objectForKey:@"CreatedDate"];
        NSString *CoverPhoto = [userDict objectForKey:@"CoverPhoto"];
        NSNumber *PrivateProfile = [userDict objectForKey:@"PrivateProfile"];
        NSNumber *ForgotPass = [userDict objectForKey:@"ForgotPass"];
        NSNumber *TwystCreated = [userDict objectForKey:@"TwystCreated"];
        NSNumber *LikeCount = [userDict objectForKey:@"LikeCount"];
        NSNumber *Followers = [userDict objectForKey:@"Followers"];
        NSNumber *Following = [userDict objectForKey:@"Following"];
        NSString *Phonenumber = [userDict objectForKey:@"Phonenumber"];
        NSString *Bio = [userDict objectForKey:@"Bio"];
        NSNumber *Verified = [userDict objectForKey:@"Verified"];
        NSString *ProfilePicName = [userDict objectForKey:@"ProfilePicName"];
        NSString *UserName = [userDict objectForKey:@"UserName"];
        NSString *VerifyCode = [userDict objectForKey:@"VerifyCode"];
        
        NSNumber *SendNewStringgNot = [userDict objectForKey:@"SendNewStringgNot"];
        NSNumber *SendLikeNot = [userDict objectForKey:@"SendLikeNot"];
        NSNumber *SendFriendNot = [userDict objectForKey:@"SendFriendNot"];
        NSNumber *SendReplyNot = [userDict objectForKey:@"SendReplyNot"];
        NSNumber *SendPassStringgNot = [userDict objectForKey:@"SendPassStringgNot"];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        
        self.Id = [Id longValue];
        self.FirstName = IsNSStringValid(FirstName) ? FirstName : @"";
        self.LastName = IsNSStringValid(LastName) ? LastName : @"";
        self.EmailAddress = IsNSStringValid(EmailAddress) ? EmailAddress : @"";
        self.CreatedDate = IsNSStringValid(CreatedDate) ? [dateFormatter dateFromString:[CreatedDate substringToIndex:19]] : nil;
        self.CoverPhoto = IsNSStringValid(CoverPhoto) ? CoverPhoto : @"";
        self.PrivateProfile = [PrivateProfile isKindOfClass:[NSNull class]] ? false : [PrivateProfile boolValue];
        self.ForgotPass = [ForgotPass boolValue];
        self.TwystCreated = [TwystCreated integerValue];
        self.LikeCount = [LikeCount isKindOfClass:[NSNull class]] ? 0 : [LikeCount integerValue];
        self.Followers = [Followers isKindOfClass:[NSNull class]] ? 0 : [Followers integerValue];
        self.Following = [Following isKindOfClass:[NSNull class]] ? 0 : [Following integerValue];
        self.Phonenumber = IsNSStringValid(Phonenumber) ? Phonenumber : @"";
        self.Bio = IsNSStringValid(Bio) ? Bio : @"";
        self.Verified = [Verified boolValue];
        self.ProfilePicName = IsNSStringValid(ProfilePicName) ? ProfilePicName : @"";
        self.UserName = IsNSStringValid(UserName) ? UserName : @"";
        self.VerifyCode = IsNSStringValid(VerifyCode) ? VerifyCode : @"";
        
        self.SendNewStringgNot = [SendNewStringgNot boolValue];
        self.SendLikeNot = [SendLikeNot boolValue];
        self.SendFriendNot = [SendFriendNot boolValue];
        self.SendReplyNot = [SendReplyNot boolValue];
        self.SendPassStringgNot = [SendPassStringgNot isKindOfClass:[NSNull class]] ? NO : [SendPassStringgNot boolValue];
    }
    return self;
}

@end

