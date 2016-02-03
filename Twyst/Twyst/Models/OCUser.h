//
//  OCUser.h
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCUser : NSObject

// ocuser from server
@property (nonatomic, assign) long Id;
@property (nonatomic, retain) NSString *FirstName;
@property (nonatomic, retain) NSString *LastName;
@property (nonatomic, retain) NSString *EmailAddress;
@property (nonatomic, retain) NSDate *CreatedDate;
@property (nonatomic, retain) NSString *CoverPhoto;
@property (nonatomic, assign) BOOL PrivateProfile;
@property (nonatomic, assign) BOOL ForgotPass;
@property (nonatomic, assign) NSInteger TwystCreated;
@property (nonatomic, assign) NSInteger LikeCount;
@property (nonatomic, assign) NSInteger Followers;
@property (nonatomic, assign) NSInteger Following;
@property (nonatomic, retain) NSString *Phonenumber;
@property (nonatomic, retain) NSString *Bio;
@property (nonatomic, assign) BOOL Verified;
@property (nonatomic, retain) NSString *ProfilePicName;
@property (nonatomic, retain) NSString *UserName;
@property (nonatomic, retain) NSString *VerifyCode;

// notifications
@property (nonatomic, assign) BOOL SendNewStringgNot;
@property (nonatomic, assign) BOOL SendLikeNot;
@property (nonatomic, assign) BOOL SendFriendNot;
@property (nonatomic, assign) BOOL SendReplyNot;
@property (nonatomic, assign) BOOL SendPassStringgNot;


// added to manage user
@property (nonatomic, retain) NSString *Password;
@property (nonatomic, retain) NSString *Token;


+ (OCUser*)createNewUserWithDictionary:(NSDictionary*)userDict;

@end
