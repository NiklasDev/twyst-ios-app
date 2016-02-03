//
//  UserWebService.m
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "JSON.h"
#import "RestKit.h"
#import "TTwystOwnerManager.h"
#import "UserWebService.h"
#import "OCToken.h"

@implementation UserWebService

static id _sharedObject = nil;
+ (id)sharedInstance {
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
        [self actionInitNetwork];
    }
    return self;
}

#pragma mark - check update method
- (void)checkUpdateVersion:(NSString*)version completion:(void(^)(BOOL isUpdate))completion {
    NSString *path = [NSString stringWithFormat:@"/version/%@", version];
    [self actionPostStringRequest:path withUserObject:nil headers:nil completion:^(BOOL isSuccess, NSString *res) {
        res = [self fixedStringFromResponse:res];
        if (isSuccess)  {
            if (completion) {
                if ([res isEqualToString:@"update"]) {
                    completion(YES);
                }
                else {
                    completion(NO);
                }
            }
        }   else    {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

#pragma mark - invite codes
- (void)inviteCodeRequestCodeWithcompletion:(void(^)(NSString *inviteCode))completion {
    NSString *path = @"/requestcode";
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        NSLog(@"%@", res);
        res = [self fixedStringFromResponse:res];
        if (isSuccess) {
            completion(res);
        } else {
            completion(nil);
        }
    }];
}

- (void)inviteCodeVerifyCode:(NSString *)code completion:(void(^)(BOOL isValid))completion {
    NSString *path = [@"/verifycode/" stringByAppendingString:code];
    NSDictionary *headers = @{@"Authorization":@"null", @"x-sec-id":@"0"};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        NSLog(@"%@", res);
        res = [self fixedStringFromResponse:res];
        if (isSuccess) {
            completion([res isEqualToString:@"ok"]);
        } else {
            completion(NO);
        }
    }];
}

- (void)inviteCodeRedeemCode:(NSString *)code completion:(void(^)(BOOL isSuccess))completion {
    NSString *path = [@"/redeemcode/" stringByAppendingString:code];
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        NSLog(@"%@", res);
        res = [self fixedStringFromResponse:res];
        if (isSuccess) {
            completion([res isEqualToString:@"ok"]);
        } else {
            completion(NO);
        }
    }];
}

#pragma mark - user management methods
- (void)loginUser:(NSString*)username withPass:(NSString*)password completion:(void (^)(OCUser*)) completion    {
    if (!username || !password) {
        completion(nil);
        return;
    }
    
    [self token:username withPass:password completion:^(NSString* token) {
        if (token) {
            NSDictionary *headers = @{@"authorization":token, @"x-sec-id":username};
            [self actionPostUserRequest:@"Login/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, OCUser *user) {
                if (isSuccess)  {
                    if (completion) {
                        if (user.Id > 0)    {
                            user.Password = password;
                            user.Token = token;
                            [Global updateOCUser:user];
                            completion(user);
                        } else {
                            completion(nil);
                        }
                    }
                } else {
                    if (completion) {
                        completion(nil);
                    }
                }
            }];
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)token:(NSString*)username withPass:(NSString*) password completion:(void (^)(NSString*)) completion    {
    if (!username || !password) {
        completion(nil);
        return;
    }
    
    /**
     *This prevented an issue from server side, this was agreed with Larry Garnier: transform '+' -> '|'
     */
    username = [username stringByReplacingOccurrencesOfString:@"+" withString:@"|"];
    
    NSDictionary *params = @{ @"username": username, @"password": password,@"grant_type": @"password"};
    [self actionPostTokenRequest:@"token" withTokenObject:nil parameters:params completion:^(BOOL a, NSString *token) {
        completion(token);
    }];
}

- (void)logOutUser:(void (^)(BOOL)) completion   {
    //load object
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"Logout/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (isSuccess)  {
            res = [self fixedStringFromResponse:res];
            BOOL result = NO;
            if ([res isEqualToString:@"ok"])    {
                result = YES;
            }   else    {
                result = NO;
            }
            if (completion) {
                completion(result);
            }
        }   else    {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

- (void)registerNewUser:(NSString*) email withPass:(NSString*) password firstName:(NSString*)firstName lastName:(NSString*)lastName completion:(void (^)(OCUser*, BOOL)) completion    {
    OCUser *userReg = [[OCUser alloc] init];
    userReg.EmailAddress = email;
    userReg.Password = password;
    userReg.FirstName = firstName;
    userReg.LastName = lastName;

    NSDictionary *headers = @{@"x-sec-token":password, @"x-sec-id":@"0"};
    
    [self actionPostUserRequest:@"Register/" withUserObject:userReg headers:headers completion:^(BOOL isSuccess, OCUser *user) {
        //add token call
        if (isSuccess)  {
            if (completion) {
                if (user.Id <= 0)    {
                    if ([user.UserName isEqualToString:@"emailalreadyexists"])   {
                        completion(nil, YES);
                    }   else    {
                        completion(nil, NO);
                    }
                } else {
                    user.Password = password;
                    [self token:email withPass:password completion:^(NSString* token) {
                        if (token) {
                            user.Token = token;
                            [Global updateOCUser:user];
                            [[Global getConfig] addLoggedInUser:user];
                            
                            //RedeemCode
                            NSString *inviteCode = [Global getInviteCode];
                            if ([inviteCode length]) {
                                [self inviteCodeRedeemCode:inviteCode completion:^(BOOL isSuccess) {
                                    if (isSuccess) {
                                        NSLog(@"Invite code redeemed");
                                    } else {
                                        NSLog(@"Failed to redeem the invite code");
                                    }
                                }];
                            }
                    
                            completion(user, NO);
                        } else {
                            completion(nil, NO);
                        }
                    }];
                }
            }
        }   else    {
            if (completion) {
                completion(nil, NO);
            }
        }
    }];
}

- (void)getOCUser:(long)userId completion:(void(^)(OCUser*))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getuser/%ld", userId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            NSDictionary *dicUser = [[[SBJSON alloc] init] objectWithString:res error:nil];
            OCUser *user = [OCUser createNewUserWithDictionary:dicUser];
            OCUser *curUser = [Global getOCUser];
            user.Password = curUser.Password;
            user.Token = curUser.Token;
            [Global updateOCUser:user];
            completion(user);
        }
        else {
            completion(nil);
        }
     }];
}

#pragma mark - password management methods
- (void)forgotPassword:(NSString*)email completion:(void (^)(NSString*)) completion    {
    NSDictionary *headers = @{@"Authorization":@"null", @"x-sec-id":email};
    [self actionPostStringRequest:@"ForgotPass/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        res = [self fixedStringFromResponse:res];
        if (isSuccess)  {
            if (completion) {
                completion(res);
            }
        }   else    {
            if (completion) {
                completion(@"Unknown Error");
            }
        }
    }];
}

- (void)updatePassword:(NSString*) newPassword completion:(void (^)(OCUser*)) completion    {
    OCUser *user = [Global getOCUser];
    NSString *urlString = [NSString stringWithFormat:@"%@/ChangePass/", VAL_SERVER_ADDRESS];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    
    NSString *formattedString = [NSString stringWithFormat:@"\"%@\"", newPassword];
    NSURLRequest * request = [self jsonURLRequest:urlString method:@"POST" headers:headers body:[formattedString dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"request body = %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError = %@", [connectionError description]);
            completion(nil);
        }
        else {
            NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"change password response = %@", res);
            res = [self fixedStringFromResponse:res];
            if ([res isEqualToString:@"ok"])   {
                user.Password = newPassword;
                [Global updateOCUser:user];
                completion(user);
            }   else    {
                completion(nil);
            }
        }
    }];
}

#pragma mark - edit profile method

// 0 : success
// 1 : email already exists
// 2 : username already exists
// 3 : something went wrong

- (void)updateProfile:(OCUser*) user completion:(void (^)(NSInteger)) completion    {
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"editprofile/" withUserObject:user headers:headers completion:^(BOOL isSuccess, NSString *res) {
        res = [self fixedStringFromResponse:res];
        if (isSuccess)  {
            if ([res isEqualToString:@"ok"])    {
                //get test user
                if (completion) {
                    completion(0);
                }
            }   else if ([res isEqualToString:@"emailalreadyexists"]) {
                if (completion) {
                    completion(1);
                }
            }   else if ([res isEqualToString:@"usernamealreadyexists"]) {
                if (completion) {
                    completion(2);
                }
            }   else    {
                if (completion) {
                    completion(3);
                }
            }
        }   else    {
            if (completion) {
                completion(3);
            }
        }
    }];
}

// 0 : success
// 1 : email already exists
// 2 : something went wrong
- (void)updateEmail:(NSString*) newEmail completion:(void (^)(NSInteger))completion {
    OCUser *user = [Global getOCUser];
    NSString *urlString = [NSString stringWithFormat:@"%@/changeemail/", VAL_SERVER_ADDRESS];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    
    NSString *formattedString = [NSString stringWithFormat:@"\"%@\"", newEmail];
    NSURLRequest * request = [self jsonURLRequest:urlString method:@"POST" headers:headers body:[formattedString dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"request body = %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError = %@", [connectionError description]);
            completion(2);
        } else {
            NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"change password response = %@", res);
            res = [self fixedStringFromResponse:res];
            if ([res isEqualToString:@"ok"]) {
                user.EmailAddress = newEmail;
                [Global updateOCUser:user];
                completion(0);
            } else if ([res isEqualToString:@"emailalreadyexists"]) {
                completion(1);
            } else {
                completion(2);
            }
        }
    }];
}

- (void)uploadProfilePic:(NSString*)fileName completion:(void (^)(OCUser*)) completion {
    OCUser *curUser = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/uploadprofilepic/%@", fileName];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    NSDictionary *headers = @{@"Authorization":curUser.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", curUser.Id]};
    [self actionPostUserRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, OCUser *newUser) {
        //add token call
        if (isSuccess && newUser.Id > 0)  {
            newUser.Password = curUser.Password;
//            newUser.Token = token;
            completion(newUser);
        }   else    {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

#pragma mark - friend related methods
- (void)searchFriends:(NSString*)searchString completion:(void(^)(NSArray*))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/searchfriends/%@", searchString];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    path = [path stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *friends = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(friends);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getSentRequests:(void(^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"getfriendrequests/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *requests = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(requests);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getReceivedRequests:(void(^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"getreceivedrequests/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *requests = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(requests);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)requestFriend:(NSString*)friendId completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/requestfriend/%@", friendId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

//the send the unique id of the friend record friend.id not friendid column
//approves a friend request
- (void)acceptFriendRequest:(NSString*)requestId completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/approvefriend/%@", requestId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

- (void)acceptAllFriendRequest:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"/acceptallfriendrequests/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

- (void)cancelFriendRequest:(NSString*)requestId completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/cancelrequest/%@", requestId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

- (void)declineAllFriendRequest:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"/declineallfriendrequests/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

- (void)deleteFriend:(NSString*)friendId completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/deletefriend/%@", friendId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

- (void)getFriendList:(long)userId completion:(void(^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"getfriendlist/%ld", userId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *friends = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(friends);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getFriendFollowersList:(long)userId completion:(void(^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"getfriendfollowerslist/%ld", userId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *friends = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(friends);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)verifyPhone:(NSString*)code completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/verifyphone/%@", code];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    path = [path stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

- (void)sendVerificationCode:(NSString*)code completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/sendverification/%@", code];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    path = [path stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

- (void)searchFriendByPhoneCode:(NSString*)phoneCodes completion:(void(^)(NSArray*))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@phonesearch/", VAL_SERVER_ADDRESS];
    NSDictionary *headers = @{@"Authorization":@"null", @"x-sec-id":@"0"};
    
    NSURLRequest * request = [self jsonURLRequest:urlString
                                           method:@"POST"
                                          headers:headers
                                             body:[phoneCodes dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError = %@", [connectionError description]);
            completion(nil);
        }
        else {
            NSArray * responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:nil];
            NSLog(@"responseData = %@", responseData);
            if ([responseData isKindOfClass:[NSArray class]]) {
                completion(responseData);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getFriendProfile:(long)friendId start:(NSInteger)start completion:(void(^)(NSDictionary*))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/friendprofile/%ld/%ld/%d", friendId, (long)start, DEF_HOME_FEED_BUNCH];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                id friendProfile = [[[SBJSON alloc] init] objectWithString:res error: nil];
                completion(friendProfile);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getUsersFollower:(long)userId completion:(void(^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"myfollowers/%ld", userId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *friends = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(friends);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getUsersFollowing:(long)userId completion:(void(^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"whoifollow/%ld", userId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *friends = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(friends);
            }
            else {
                completion(nil);
            }
        }
    }];
}

#pragma mark - feed related methods
- (void)getFeeds:(NSDate*)timeStamp bunch:(NSInteger)bunch completion:(void(^)(NSArray*))completion {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSS"];
    NSString *timeStampString = [NSString stringWithFormat:@"\"%@\"", [dateFormatter stringFromDate:timeStamp]];
    NSLog(@"feed2 time stamp = %@", timeStampString);
    
    OCUser *user = [Global getOCUser];
    NSString *urlString = [NSString stringWithFormat:@"%@feed2/%ld", VAL_SERVER_ADDRESS, (long)bunch];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    
    NSURLRequest * request = [self jsonURLRequest:urlString
                                           method:@"POST"
                                          headers:headers
                                             body:[timeStampString dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError = %@", [connectionError description]);
            completion(nil);
        }
        else {
            NSLog(@"%@", urlString);
            NSLog(@"response.body = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSArray * responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:nil];
            if ([responseData isKindOfClass:[NSArray class]]) {
                NSMutableArray *arrTwysts = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in responseData) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:dic];
                    if (twyst.IsComplete && !twyst.Deleted) {
                        [arrTwysts addObject:twyst];
                    }
                }
                completion(arrTwysts);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getPrivateTwysts:(NSInteger)start bunch:(NSInteger)bunch completion:(void(^)(NSArray*))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"getprivatestringgs/%ld/%ld", (long)start, (long)bunch];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *twysts = [[[SBJSON alloc] init] objectWithString:res error:nil];
                NSMutableArray *arrTwysts = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in twysts) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:dic];
                    if (twyst.IsComplete && !twyst.Deleted) {
                        [arrTwysts addObject:twyst];
                    }
                }
                completion(arrTwysts);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getMyTwysts:(NSInteger)start bunch:(NSInteger)bunch completion:(void(^)(NSArray*))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"getmytwysts/%ld/%ld", (long)start, (long)bunch];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *twysts = [[[SBJSON alloc] init] objectWithString:res error:nil];
                NSMutableArray *arrTwysts = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in twysts) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:dic];
                    if (twyst.IsComplete && !twyst.Deleted) {
                        [arrTwysts addObject:twyst];
                    }
                }
                completion(arrTwysts);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getUserLikedTwysts:(long)userId start:(NSInteger)start completion:(void(^)(NSArray*))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"gettwystsuserlikes/%ld/%ld/%ld", userId, (long)start, DEF_HOME_FEED_BUNCH];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *twysts = [[[SBJSON alloc] init] objectWithString:res error:nil];
                NSMutableArray *arrTwysts = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in twysts) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:dic];
                    if (twyst.IsComplete && !twyst.Deleted) {
                        [arrTwysts addObject:twyst];
                    }
                }
                completion(arrTwysts);
            }
            else {
                completion(nil);
            }
        }
    }];
}

#pragma mark - get all notifictions methods
- (void)getAllNotifications:(void(^)(NSDictionary*))completion {
    OCUser *user = [Global getOCUser];
    if (user) {
        NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
        [self actionPostStringRequest:@"getallnotifications/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
            if (completion) {
                if (isSuccess) {
                    id notifications = [[[SBJSON alloc] init] objectWithString:res error: nil];
                    completion(notifications);
                }
                else {
                    completion(nil);
                }
            }
        }];
    }
    else {
        completion(nil);
    }
}

#pragma mark - twyst related methods
//return all twysts of user
- (void)getAllTwystsForUser:(void (^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"getstringgs/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *twysts = [[[SBJSON alloc] init] objectWithString:res error:nil];
                NSMutableArray *arrTwysts = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in twysts) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:dic];
                    if (twyst.IsComplete && !twyst.Deleted) {
                        [arrTwysts addObject:twyst];
                    }
                }
                completion(arrTwysts);
            }
            else {
                completion(nil);
            }
        }
    }];
}
    
//return new twyst
- (void)createTwyst:(NSString*)caption allowReplies:(NSString*)allowReplies allowPass:(NSString*)allowPass visibility:(NSString*)visibility completion:(void(^)(BOOL, Twyst*))completion {
    caption = [caption stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    caption = [NSString stringWithFormat:@"\"%@\"", caption];
    
    OCUser *user = [Global getOCUser];
//    [Route("sharestringg/{stringgId}/{filename}/{imagecount}/{ismovie}/{viewlength}/{friendids}")]
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/createstringg/%@/%@/%@", VAL_SERVER_ADDRESS, allowReplies, visibility, allowPass];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    
    NSURLRequest * request = [self jsonURLRequest:urlString method:@"POST" headers:headers body:[caption dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"request body = %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError = %@", [connectionError description]);
            completion(NO, nil);
        }
        else {
            NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"create string response = %@", res);
            NSDictionary *twystDic = [[[SBJSON alloc] init] objectWithString:res error:nil];
            if (twystDic) {
                Twyst *twyst = [Twyst createNewTwystWithDictionary:twystDic];
                completion(YES, twyst);
            } else {
                completion(NO, nil);
            }
        }
    }];
}

//add reply to twyst
- (void)addReplyToTwyst:(long)twystId imageCount:(NSInteger)imageCount fileName:(NSString *)fileName isMovie:(NSString*)isMovie frameTime:(NSInteger)frameTime completion:(void (^)(ResponseType, Twyst*))completion {
    OCUser *user = [Global getOCUser];

    NSString *path = [NSString stringWithFormat:@"/addreply/%ld/%ld/%@/%@/%ld", twystId, (long)imageCount, fileName, isMovie, (long)frameTime];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            if (isSucess)   {
                NSRange range = NSMakeRange(1, res.length - 2);
                NSString *twystString = [[res substringWithRange:range] stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                NSDictionary *twystDic = [[[SBJSON alloc] init] objectWithString:twystString error:nil];
                if (twystDic) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:twystDic];
                    completion(Response_Success, twyst);
                }
                else    {
                    res = [self fixedStringFromResponse:res];
                    if ([res isEqualToString:@"stringgDeleted"])   {
                        completion(Response_Deleted_Twyst, nil);
                    }   else if ([res isEqualToString:@"notastringger"]) {
                        completion(Response_Not_Twyster, nil);
                    }   else  {
                        completion(Response_NetworkError, nil);
                    }
                }
            }   else    {
                completion(Response_NetworkError, nil);
            }
        }
    }];
}

//sharestringg/{stringgiId}/{filename}/{imagecount}/{isMovie}/{viewLength}/{friendids}"
- (void)shareTwyst:(long)twystId filename:(NSString *)filename imageCount:(NSInteger)imageCount isMovie:(NSString*)isMovie frameTime:(NSInteger)frameTime friends:(NSString *)friends completion:(void (^)(ResponseType, Twyst *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/sharestringg/%ld/%@/%ld/%@/%ld/%@", twystId, filename, (long)imageCount, isMovie, (long)frameTime, friends];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    path = [path stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            if (isSucess)   {
                NSDictionary *twystDic = [[[SBJSON alloc] init] objectWithString:res error:nil];
                if ([twystDic isKindOfClass:[NSDictionary class]]) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:twystDic];
                    completion(Response_Success, twyst);
                }
                else {
                    completion(Response_NetworkError, nil);
                }
            } else {
                completion(Response_NetworkError, nil);
            }
        }
    }];
}

//pass twyst api to friends
//sharespublicstringg/{stringgId}/{friendids}
- (void)passTwyst:(long)twystId friends:(NSString *)friends completion:(void (^)(ResponseType))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/sharespublicstringg/%ld/%@", twystId, friends];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    path = [path stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(Response_Success);
                }
                else {
                    completion(Response_NetworkError);
                }
            } else {
                completion(Response_NetworkError);
            }
        }
    }];
}

//delete my twyst from server
- (void)deleteUserTwyst:(long)twystId completion:(void (^)(ResponseType))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/deletemystring/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(Response_Success);
                }   else if ([res isEqualToString:@"stringgDeleted"]) {
                    completion(Response_Deleted_Twyst);
                }   else    {
                    completion(Response_NetworkError);
                }
            }   else    {
                completion(Response_NetworkError);
            }
        }
    }];
}

//get user list in twyst
- (void)getFriendsInTwyst:(long)twystId completion:(void (^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getfriendsinstringg/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *friends = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(friends);
            }
            else {
                completion(nil);
            }
        }
    }];
}

- (void)getFriendsInTwyst:(long)twystId start:(NSInteger)start completion:(void (^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getfriendsinstringg2/%ld/%ld/%d", twystId, (long)start, DEF_PAGE_BUNCH];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *friends = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(friends);
            }
            else {
                completion(nil);
            }
        }
    }];
}

//get list of twysts where you are in the twyst users table
- (void)getAllReceivedTwyst:(long)userId completion:(void (^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:@"myfriendsstringgs/" withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *twysts = [[[SBJSON alloc] init] objectWithString:res error:nil];
                NSMutableArray *arrTwysts = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in twysts) {
                    Twyst *twyst = [Twyst createNewTwystWithDictionary:dic];
                    if (twyst.IsComplete && !twyst.Deleted) {
                        [arrTwysts addObject:twyst];
                    }
                }
                completion(arrTwysts);
            }
            else {
                completion(nil);
            }
        }
    }];
}

//get a stringg of friend
- (void)getTwystOfFriend:(long)twystId completion:(void (^)(Twyst *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getfriendstringg/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSDictionary *twystDic = [[[SBJSON alloc] init] objectWithString:res error:nil];
                Twyst *twyst = [Twyst createNewTwystWithDictionary:twystDic];
                completion(twyst);
            }
            else {
                completion(nil);
            }
        }
    }];
}

//get all replies of twyst
- (void)getTwystReplies:(long)twystId completion:(void (^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getstringgreplies/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *replies = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(replies);
            }
            else {
                completion(nil);
            }
        }
    }];
}

//view twyst
- (void)viewTwyst:(long)twystId completion:(void (^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/viewstring/%ld/", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

// leave twyst
- (void)hideFriendTwyst:(long)twystId completion:(void (^)(ResponseType))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/hidefriendstringg/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(Response_Success);
                }   else if ([res isEqualToString:@"stringgDeleted"]) {
                    completion(Response_Deleted_Twyst);
                }   else    {
                    completion(Response_NetworkError);
                }
            }   else    {
                completion(Response_NetworkError);
            }
        }
    }];
}

//report twyst
- (void)reportTwyst:(long)twystId completion:(void (^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/reportstringg/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

//report reply
- (void)reportRely:(long)replyId completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/reportreply/%ld", replyId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

//add comment to twyst
- (void)addComment:(long)twystId comment:(NSString*)comment completion:(void(^)(BOOL))completion {
    comment = [comment stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    comment = [NSString stringWithFormat:@"\"%@\"", comment];
    
    OCUser *user = [Global getOCUser];
    NSString *urlString = [NSString stringWithFormat:@"%@/addcomment/%ld", VAL_SERVER_ADDRESS, twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    
    NSURLRequest * request = [self jsonURLRequest:urlString method:@"POST" headers:headers body:[comment dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"request body = %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"connectionError = %@", [connectionError description]);
            completion(NO);
        }
        else {
            NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"add comment response = %@", res);
            res = [self fixedStringFromResponse:res];
            if ([res isEqualToString:@"ok"])   {
                completion(YES);
            }   else    {
                completion(NO);
            }
        }
    }];
}

//get all comment of twyst
- (void)getTwystComments:(long)twystId start:(NSInteger)start completion:(void (^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getstringgcomments2/%ld/%ld/%d", twystId, (long)start, DEF_PAGE_BUNCH];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *comments = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(comments);
            }
            else {
                completion(nil);
            }
        }
    }];
}

//delete comment
- (void)deleteComment:(long)twystId commentId:(long)commentId completion:(void(^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/deletecomment/%ld/%ld", twystId, commentId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

//like twyst
- (void)likeTwyst:(long)twystId completion:(void (^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/likestringg/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

//unlike twyst
- (void)unlikeTwyst:(long)twystId completion:(void (^)(BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/unlikestringg/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSucess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSucess)   {
                if ([res isEqualToString:@"ok"])   {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }   else    {
                completion(NO);
            }
        }
    }];
}

//get liked user list in twyst
- (void)getTwystLikeUsers:(long)twystId start:(NSInteger)start completion:(void (^)(NSArray *))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/stringglikeusers2/%ld/%ld/%d", twystId, (long)start, DEF_PAGE_BUNCH];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *likes = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(likes);
            }
            else {
                completion(nil);
            }
        }
    }];
}

//get comment count and like of given twyst
- (void)getTwystPreviewInfo:(long)twystId completion:(void (^)(BOOL, NSInteger, NSInteger, NSInteger, NSInteger, NSInteger, BOOL))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getstringgpreviewinfo2/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess) {
                NSArray *temp = [res componentsSeparatedByString:@"|"];
                NSInteger twyster = [[temp objectAtIndex:0] integerValue];
                BOOL liked = [[temp objectAtIndex:1] integerValue];
                NSInteger viewCount = [[temp objectAtIndex:2] integerValue];
                NSInteger like = [[temp objectAtIndex:3] integerValue];
                NSInteger replies = [[temp objectAtIndex:4] integerValue];
                NSInteger passes = [[temp objectAtIndex:5] integerValue];
                completion(YES, twyster, like, viewCount, replies, passes, liked);
            }
            else {
                completion(NO, NSNotFound, NSNotFound, NSNotFound, NSNotFound, NSNotFound, NO);
            }
        }
    }];
}

//get view count of twyst
- (void)getTwystViewCount:(long)twystId completion:(void (^)(BOOL, NSInteger))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/getstringgviews/%ld", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            res = [self fixedStringFromResponse:res];
            if (isSuccess) {
                NSInteger viewCount = [res integerValue];
                completion(YES, viewCount);
            }
            else {
                completion(NO, NSNotFound);
            }
        }
    }];
}

//get twyst latest activities
- (void)getTwystActivity:(long)twystId completion:(void(^)(NSArray*))completion {
    OCUser *user = [Global getOCUser];
    NSString *path = [NSString stringWithFormat:@"/twystlastaction/%ld/0/10", twystId];
    NSDictionary *headers = @{@"Authorization":user.Token, @"x-sec-id":[NSString stringWithFormat:@"%ld", user.Id]};
    [self actionPostStringRequest:path withUserObject:nil headers:headers completion:^(BOOL isSuccess, NSString *res) {
        if (completion) {
            if (isSuccess) {
                NSArray *actions = [[[SBJSON alloc] init] objectWithString:res error:nil];
                completion(actions);
            }
            else {
                completion(nil);
            }
        }
    }];
}

#pragma mark - Internal methods
- (void)actionInitNetwork  {
    //load from server
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelError);
    
    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize HTTPClient
    NSString *addServer = VAL_SERVER_ADDRESS;
    NSURL *baseURL = [NSURL URLWithString:addServer];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    //we want to work with JSON-Data
    //[client setDefaultHeader:@"Accept" value:RKMIMETypeXML];
    
    // Initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // Setup our object mappings
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[OCUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"Id" : @"Id",
                                                      @"FirstName" : @"FirstName",
                                                      @"LastName" : @"LastName",
                                                      @"EmailAddress" : @"EmailAddress",
                                                      @"CreatedDate" : @"CreatedDate",
                                                      @"CoverPhoto" : @"CoverPhoto",
                                                      @"PrivateProfile" : @"PrivateProfile",
                                                      @"ForgotPass" : @"ForgotPass",
                                                      @"TwystCreated" : @"TwystCreated",
                                                      @"LikeCount" : @"LikeCount",
                                                      @"Followers" : @"Followers",
                                                      @"Following" : @"Following",
                                                      @"Phonenumber" : @"Phonenumber",
                                                      @"Bio" : @"Bio",
                                                      @"Verified" : @"Verified",
                                                      @"ProfilePicName" : @"ProfilePicName",
                                                      @"UserName" : @"UserName",
                                                      @"VerifyCode" : @"VerifyCode",
                                                      @"SendNewStringgNot" : @"SendNewStringgNot",
                                                      @"SendLikeNot" : @"SendLikeNot",
                                                      @"SendFriendNot" : @"SendFriendNot",
                                                      @"SendReplyNot" : @"SendReplyNot",
                                                      @"SendPassStringgNot" : @"SendPassStringgNot",
                                                      }];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // Update date format so that we can parse Twitter dates properly
    // Wed Sep 29 15:31:08 +0000 2010
    //    [RKObjectMapping addDefaultDateFormatterForString:@"yyyy-MM-ddTHH:mm:ss" inTimeZone:nil];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    // Set it Globally
    [userMapping setPreferredDateFormatter:dateFormatter];
    
    //2014-03-31 02:47:20 +0000
    //2014-03-28T00:00:00
    
    // Register our mappings with the provider using a response descriptor
    RKResponseDescriptor *responseLogin = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                       method:RKRequestMethodPOST
                                                                                  pathPattern:@"Login/"
                                                                                      keyPath:nil
                                                                                  statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *responseRegister = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                          method:RKRequestMethodPOST
                                                                                     pathPattern:@"Register/"
                                                                                         keyPath:nil
                                                                                     statusCodes:[NSIndexSet indexSetWithIndex:200]];
    RKResponseDescriptor *responseProfilePic = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"uploadprofilepic/:profile"
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[userMapping inverseMapping] objectClass:[OCUser class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    [objectManager addResponseDescriptor:responseLogin];
    [objectManager addResponseDescriptor:responseRegister];
    [objectManager addResponseDescriptor:responseProfilePic];
    
    [objectManager addRequestDescriptor:requestDescriptor];
}

- (NSString*) fixedStringFromResponse:(NSString*) srcString {
    NSString* cleanedString = [[srcString stringByReplacingOccurrencesOfString:@"\"" withString:@""]
                               stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
    return cleanedString;
}


#pragma update with trial and waiting using

- (void)actionPostUserRequest:(NSString*)path withUserObject:(OCUser*)user headers:(NSDictionary*)headers completion:(void (^)(BOOL, OCUser*)) completion  {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:user path:path headers:headers parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        OCUser *user = [mappingResult firstObject];
        if (completion) {
            completion(YES, user);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Hit error: %@", error);
        if (completion) {
            completion(NO, nil);
        }
    }];
}

- (void)actionPostTokenRequest:(NSString*) path withTokenObject:(OCToken*)token parameters:(NSDictionary*)parameters completion:(void (^)(BOOL, NSString*)) completion {
    
#warning This should be improved (This is the only one method which behave different)
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSMutableURLRequest *request = [objectManager requestWithObject:token method:RKRequestMethodPOST path:path headers:nil parameters:parameters];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[self generateTokenMethodBody:parameters]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        if (completion) {
            completion(YES, [NSString stringWithFormat:@"%@ %@", json[@"token_type"], json[@"access_token"]]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, nil);
        }
    }];
    [operation start];
}

- (NSData *)generateTokenMethodBody:(NSDictionary *)parameters {
    NSMutableString *body = [NSMutableString string];
    for (NSString *key in parameters.allKeys) {
        if (body.length) [body appendString:@"&"];
        [body appendFormat:@"%@=%@", key, parameters[key]];
    }
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)actionPostStringRequest:(NSString*) path withUserObject:(OCUser*)user headers:(NSDictionary*)headers completion:(void (^)(BOOL, NSString*)) completion {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    NSMutableURLRequest *request = [objectManager requestWithObject:user method:RKRequestMethodPOST path:path headers:headers parameters:nil];
    [request setValue:RKMIMETypeJSON forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Do your success callback.
        NSString *str=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (completion) {
            completion(YES, str);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //         NSInteger code = error.code;
        // -1001    @"The request timed out."
        // -1003    @"A server with the specified hostname could not be found."
        // -1009    @"The Internet connection appears to be offline."
        // -1011    @"Expected status code in (200-299), got 500"
        
        // Do your failure callback.
        if (completion) {
            completion(NO, nil);
        }
    }];
    [operation start];
}

- (NSString *)getMacAddress
{
    return [FlipframeUtils generateTimeStamp];
}

#pragma mark -

const NSString * multipartBoundary = @"-------------111";

- (NSData *)makeMultipartBody:(NSDictionary *)dic {
    NSMutableData * data = [NSMutableData data];
    
    for (NSString * key in dic) {
        NSString * value = [dic objectForKey:key];
        //set boundary
        [data appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [data appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}

- (NSURLRequest *) jsonURLRequest:(NSString *)urlString
                           method:(NSString *)method
                          headers:(NSDictionary*)headers
                             body:(NSData *)body {
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (body) {
        [request setHTTPBody:body];
    }
    
    NSArray *headerFields = [headers allKeys];
    for (NSString *field in headerFields) {
        NSString *value = [headers objectForKey:field];
        [request addValue:value forHTTPHeaderField:field];
    }
    
    return request;
}

- (void)appendFileToBody:(NSMutableData *)data filenamekey:(NSString*)filenamekey filenamevalue:(NSString*)filenamevalue filedata:(NSData*)filedata {
    [data appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", filenamekey, filenamevalue]] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"Content-type: application/octet-stream\r\n\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
    [data appendData:filedata];
    [data appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *logString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", logString);
}

@end
