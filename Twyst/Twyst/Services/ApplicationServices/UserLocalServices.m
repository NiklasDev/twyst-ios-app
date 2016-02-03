//
//  UserLocalServices.m
//  Twyst
//
//  Created by Niklas Ahola on 5/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UserLocalServices.h"

@interface UserLocalServices()  {
    TUserManager *_userManager;
}
@end

@implementation UserLocalServices

#pragma static singleton
static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

#pragma class definition
- (id) init {
    self = [super init];
    if (self)   {
        _userManager = [TUserManager sharedInstance];
        
        //get and init local user if have any
        TUser *tMpuser = [_userManager getLatestUser];
        if (tMpuser)    {
            self.tUser = tMpuser;
            
            //new OCUser
            self.ocUser = [[OCUser alloc] init];
            
            self.ocUser.Bio = self.tUser.bio;
            self.ocUser.CoverPhoto = self.tUser.coverPhoto;
            self.ocUser.CreatedDate = self.tUser.createdDate;
            self.ocUser.EmailAddress = self.tUser.emailAddress;
            self.ocUser.FirstName = self.tUser.firstName;
            self.ocUser.Followers = [self.tUser.followers intValue];
            self.ocUser.Following = [self.tUser.following intValue];
            self.ocUser.ForgotPass = [self.tUser.forgotPass boolValue];
            self.ocUser.LastName = self.tUser.lastName;
            self.ocUser.LikeCount = [self.tUser.likeCount intValue];
            self.ocUser.Password = self.tUser.password;
            self.ocUser.Phonenumber = self.tUser.phoneNumber;
            self.ocUser.PrivateProfile = [self.tUser.privateProfile boolValue];
            self.ocUser.ProfilePicName = self.tUser.profilePicName;
            self.ocUser.SendFriendNot = [self.tUser.sendFriendNot boolValue];
            self.ocUser.SendLikeNot = [self.tUser.sendLikeNot boolValue];
            self.ocUser.SendNewStringgNot = [self.tUser.sendNewStringgNot boolValue];
            self.ocUser.SendPassStringgNot = [self.tUser.sendPassStringgNot boolValue];
            self.ocUser.SendReplyNot = [self.tUser.sendReplyNot boolValue];
            self.ocUser.Token = self.tUser.token;
            self.ocUser.TwystCreated = [self.tUser.twystCreated intValue];
            self.ocUser.Id = [self.tUser.userId longValue];
            self.ocUser.UserName = self.tUser.userName;
            self.ocUser.Verified = [self.tUser.verified boolValue];
            self.ocUser.VerifyCode = self.tUser.verifyCode;
            
        }
    }
    return self;
}

- (void) updateOCUser:(OCUser*) ocUser  {
    if (!self.tUser)    {
        self.tUser = [[TUser alloc] initWithEntity:[_userManager entityDescription] insertIntoManagedObjectContext:[_userManager managedObjectContext]];
    }
    
    self.tUser.bio = ocUser.Bio;
    self.tUser.coverPhoto = ocUser.CoverPhoto;
    self.tUser.createdDate = ocUser.CreatedDate;
    self.tUser.emailAddress = ocUser.EmailAddress;
    self.tUser.firstName = ocUser.FirstName;
    self.tUser.followers = [NSNumber numberWithInteger:ocUser.Followers];
    self.tUser.following = [NSNumber numberWithInteger:ocUser.Following];
    self.tUser.forgotPass = [NSNumber numberWithBool:ocUser.ForgotPass];
    self.tUser.lastName = ocUser.LastName;
    self.tUser.likeCount = [NSNumber numberWithInteger:ocUser.LikeCount];
    self.tUser.password = ocUser.Password;
    self.tUser.phoneNumber = ocUser.Phonenumber;
    self.tUser.privateProfile = [NSNumber numberWithBool:ocUser.PrivateProfile];
    self.tUser.profilePicName = ocUser.ProfilePicName;
    self.tUser.sendFriendNot = [NSNumber numberWithBool:ocUser.SendFriendNot];
    self.tUser.sendLikeNot = [NSNumber numberWithBool:ocUser.SendLikeNot];
    self.tUser.sendNewStringgNot = [NSNumber numberWithBool:ocUser.SendNewStringgNot];
    self.tUser.sendPassStringgNot = [NSNumber numberWithBool:ocUser.SendPassStringgNot];
    self.tUser.sendReplyNot = [NSNumber numberWithBool:ocUser.SendReplyNot];
    self.tUser.token = ocUser.Token;
    self.tUser.twystCreated = [NSNumber numberWithInteger:ocUser.TwystCreated];
    self.tUser.userId = [NSNumber numberWithLong:ocUser.Id];
    self.tUser.userName = ocUser.UserName;
    self.tUser.verified = [NSNumber numberWithBool:ocUser.Verified];
    self.tUser.verifyCode = ocUser.VerifyCode;
    
    [_userManager saveObject:self.tUser];
    self.ocUser = ocUser;
}

- (void) recoverOCUser {
    TUser *tMpuser = [_userManager getLatestUser];
    if (tMpuser)    {
        self.tUser = tMpuser;
        
        //new OCUser
        self.ocUser = [[OCUser alloc] init];
        
        self.ocUser.Bio = self.tUser.bio;
        self.ocUser.CoverPhoto = self.tUser.coverPhoto;
        self.ocUser.CreatedDate = self.tUser.createdDate;
        self.ocUser.EmailAddress = self.tUser.emailAddress;
        self.ocUser.FirstName = self.tUser.firstName;
        self.ocUser.Followers = [self.tUser.followers intValue];
        self.ocUser.Following = [self.tUser.following intValue];
        self.ocUser.ForgotPass = [self.tUser.forgotPass boolValue];
        self.ocUser.LastName = self.tUser.lastName;
        self.ocUser.LikeCount = [self.tUser.likeCount intValue];
        self.ocUser.Password = self.tUser.password;
        self.ocUser.Phonenumber = self.tUser.phoneNumber;
        self.ocUser.PrivateProfile = [self.tUser.privateProfile boolValue];
        self.ocUser.ProfilePicName = self.tUser.profilePicName;
        self.ocUser.SendFriendNot = [self.tUser.sendFriendNot boolValue];
        self.ocUser.SendLikeNot = [self.tUser.sendLikeNot boolValue];
        self.ocUser.SendNewStringgNot = [self.tUser.sendNewStringgNot boolValue];
        self.ocUser.SendPassStringgNot = [self.tUser.sendPassStringgNot boolValue];
        self.ocUser.SendReplyNot = [self.tUser.sendReplyNot boolValue];
        self.ocUser.Token = self.tUser.token;
        self.ocUser.TwystCreated = [self.tUser.twystCreated intValue];
        self.ocUser.Id = [self.tUser.userId longValue];
        self.ocUser.UserName = self.tUser.userName;
        self.ocUser.Verified = [self.tUser.verified boolValue];
        self.ocUser.VerifyCode = self.tUser.verifyCode;
    }
}

- (void) saveOCUser {
    if (!self.tUser)    {
        self.tUser = [[TUser alloc] initWithEntity:[_userManager entityDescription] insertIntoManagedObjectContext:[_userManager managedObjectContext]];
    }
    
    self.tUser.bio = self.ocUser.Bio;
    self.tUser.coverPhoto = self.ocUser.CoverPhoto;
    self.tUser.createdDate = self.ocUser.CreatedDate;
    self.tUser.emailAddress = self.ocUser.EmailAddress;
    self.tUser.firstName = self.ocUser.FirstName;
    self.tUser.followers = [NSNumber numberWithInteger:self.ocUser.Followers];
    self.tUser.following = [NSNumber numberWithInteger:self.ocUser.Following];
    self.tUser.forgotPass = [NSNumber numberWithBool:self.ocUser.ForgotPass];
    self.tUser.lastName = self.ocUser.LastName;
    self.tUser.likeCount = [NSNumber numberWithInteger:self.ocUser.LikeCount];
    self.tUser.password = self.ocUser.Password;
    self.tUser.phoneNumber = self.ocUser.Phonenumber;
    self.tUser.privateProfile = [NSNumber numberWithBool:self.ocUser.PrivateProfile];
    self.tUser.profilePicName = self.ocUser.ProfilePicName;
    self.tUser.sendFriendNot = [NSNumber numberWithBool:self.ocUser.SendFriendNot];
    self.tUser.sendLikeNot = [NSNumber numberWithBool:self.ocUser.SendLikeNot];
    self.tUser.sendNewStringgNot = [NSNumber numberWithBool:self.ocUser.SendNewStringgNot];
    self.tUser.sendPassStringgNot = [NSNumber numberWithBool:self.ocUser.SendPassStringgNot];
    self.tUser.sendReplyNot = [NSNumber numberWithBool:self.ocUser.SendReplyNot];
    self.tUser.token = self.ocUser.Token;
    self.tUser.twystCreated = [NSNumber numberWithInteger:self.ocUser.TwystCreated];
    self.tUser.userId = [NSNumber numberWithLong:self.ocUser.Id];
    self.tUser.userName = self.ocUser.UserName;
    self.tUser.verified = [NSNumber numberWithBool:self.ocUser.Verified];
    self.tUser.verifyCode = self.ocUser.VerifyCode;
    
    [_userManager saveObject:self.tUser];
}

- (void) logOut {
    [_userManager deleteObject:self.tUser];
    self.ocUser = nil;
    self.tUser = nil;
}

@end
