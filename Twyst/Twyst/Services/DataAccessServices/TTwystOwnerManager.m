//
//  TTwystOwnerManager.m
//  Twyst
//
//  Created by Niklas Ahola on 5/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TTwystOwnerManager.h"

@implementation TTwystOwnerManager

static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

- (id) init {
    self = [super init];
    if (self)   {
        self.entityName = DEF_DB_ENTITY_NAME_TTwystOwner;
    }
    return self;
}

- (TTwystOwner*) getOwnerWithUserId:(long)userId {
    
    NSManagedObjectContext *privateMOC = [TBCoreDataStore privateQueueContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:privateMOC];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId==%ld", userId];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchLimit:1];
    
    NSArray *fetchedObjects = [privateMOC executeFetchRequest:fetchRequest error:nil];
    
    if (fetchedObjects == nil) {
        NSLog(@"Could not delete Entity Objects");
    }
    
    TTwystOwner *owner = nil;
    if (fetchedObjects.count) {
        owner = [fetchedObjects firstObject];
        NSManagedObjectContext *mainMOC = [self managedObjectContext];
        owner = (TTwystOwner*)[mainMOC objectWithID:owner.objectID];
    }
    return owner;
}

- (TTwystOwner*) confirmTwystOwnerWithOCUser:(OCUser*)ocUser {
    TTwystOwner *tOwner = [self getOwnerWithUserId:ocUser.Id];
    
    if (tOwner == nil) {
        NSEntityDescription *entityMOwner = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
        tOwner = [[TTwystOwner alloc] initWithEntity:entityMOwner insertIntoManagedObjectContext:self.managedObjectContext];
    }
    
    //update data fields
    tOwner.bio = ocUser.Bio;
    tOwner.coverPhoto = ocUser.CoverPhoto;
    tOwner.createdDate = ocUser.CreatedDate;
    tOwner.emailAddress = ocUser.EmailAddress;
    tOwner.firstName = ocUser.FirstName;
    tOwner.followers = [NSNumber numberWithInteger:ocUser.Followers];
    tOwner.following = [NSNumber numberWithInteger:ocUser.Following];
    tOwner.lastName = ocUser.LastName;
    tOwner.likeCount = [NSNumber numberWithInteger:ocUser.LikeCount];
    tOwner.phoneNumber = ocUser.Phonenumber;
    tOwner.privateProfile = [NSNumber numberWithBool:ocUser.PrivateProfile];
    tOwner.profilePicName = ocUser.ProfilePicName;
    tOwner.twystCreated = [NSNumber numberWithInteger:ocUser.TwystCreated];
    tOwner.userId = [NSNumber numberWithLong:ocUser.Id];
    tOwner.userName = ocUser.UserName;
    
    //add to database
    if (![self saveObject:tOwner]) {
        return nil;
    }
    else {
        return tOwner;
    }
}

- (TTwystOwner*) confirmTwystOwnerWithUserDict:(NSDictionary*)userDict {
    OCUser *user = [OCUser createNewUserWithDictionary:userDict];
    return [self confirmTwystOwnerWithOCUser:user];
}

- (OCUser*) getOCUserFromTwystOwner:(TTwystOwner*)tOwner {
    //new OCUser
    OCUser *ocUser = [[OCUser alloc] init];

    ocUser.Bio = tOwner.bio;
    ocUser.CoverPhoto = tOwner.coverPhoto;
    ocUser.CreatedDate = tOwner.createdDate;
    ocUser.EmailAddress = tOwner.emailAddress;
    ocUser.FirstName = tOwner.firstName;
    ocUser.Followers = [tOwner.followers intValue];
    ocUser.Following = [tOwner.following intValue];
    ocUser.LastName = tOwner.lastName;
    ocUser.LikeCount = [tOwner.likeCount intValue];
    ocUser.Phonenumber = tOwner.phoneNumber;
    ocUser.PrivateProfile = [tOwner.privateProfile boolValue];
    ocUser.ProfilePicName = tOwner.profilePicName;
    ocUser.TwystCreated = [tOwner.twystCreated intValue];
    ocUser.Id = [tOwner.userId longValue];
    ocUser.UserName = tOwner.userName;
    
    return ocUser;
}

@end
