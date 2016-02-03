//
//  TTwystOwner.h
//  Twyst
//
//  Created by Niklas Ahola on 9/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TTwystOwner : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * coverPhoto;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * profilePicName;
@property (nonatomic, retain) NSNumber * twystCreated;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * followers;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * privateProfile;

@end
