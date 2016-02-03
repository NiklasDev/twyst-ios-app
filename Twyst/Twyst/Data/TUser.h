//
//  TUser.h
//  Twyst
//
//  Created by Niklas Ahola on 9/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TUser : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * coverPhoto;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * forgotPass;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * privateProfile;
@property (nonatomic, retain) NSString * profilePicName;
@property (nonatomic, retain) NSNumber * sendNewStringgNot;
@property (nonatomic, retain) NSNumber * sendLikeNot;
@property (nonatomic, retain) NSNumber * sendFriendNot;
@property (nonatomic, retain) NSNumber * sendReplyNot;
@property (nonatomic, retain) NSNumber * sendPassStringgNot;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSNumber * twystCreated;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * verified;
@property (nonatomic, retain) NSString * verifyCode;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * followers;
@property (nonatomic, retain) NSNumber * following;

@end
