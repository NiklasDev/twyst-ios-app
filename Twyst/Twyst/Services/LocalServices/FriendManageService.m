//
//  FriendManageService.m
//  Twyst
//
//  Created by Default on 8/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "FriendManageService.h"
#import "FlurryTrackingService.h"

@interface FriendManageService() {
    NSMutableArray *_followers;
    NSMutableArray *_friends;
    NSMutableArray *_receivedRequests;
    NSMutableArray *_results;
    NSMutableArray *_sentRequests;
    
    NSString *_searchString;
    
    UserWebService *_userWebService;
}

@end


@implementation FriendManageService

@synthesize friends = _friends;
@synthesize requests = _receivedRequests;
@synthesize results = _results;
@synthesize friendRequests = _sentRequests;

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
    if (self) {
        _followers = [[NSMutableArray alloc] init];
        _friends = [[NSMutableArray alloc] init];
        _receivedRequests = [[NSMutableArray alloc] init];
        _results = [[NSMutableArray alloc] init];
        _sentRequests = [[NSMutableArray alloc] init];
        
        _userWebService = [UserWebService sharedInstance];
    }
    return self;
}

- (void)startNewFriendSession {
    [_followers removeAllObjects];
    [_friends removeAllObjects];
    [_receivedRequests removeAllObjects];
    [_results removeAllObjects];
    [_sentRequests removeAllObjects];
    
    [self actionGetSentRequests:^(NSArray *sentRequests){
        [self actionGetFollowing:^(NSArray *friends){
            [self actionGetFollowers:^(NSArray *followers){}];
        }];
    }];
}

- (NSArray *)getDataWithType:(FriendDataType)type {
    switch (type) {
        case FriendDataTypeFriend:
            return _friends;
            break;
        case FriendDataTypeRcvRequest:
            return _receivedRequests;
            break;
        case FriendDataTypeSentRequest:
            return _sentRequests;
            break;
        case FriendDataTypeSearchResult:
            return _results;
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark -
- (void)requesetFriend:(NSString*)friendId completion:(void(^)(BOOL))completion {
    [_userWebService requestFriend:friendId completion:^(BOOL isSuccess) {
        if (isSuccess) {
            OCUser *user = [Global getOCUser];
            NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user.UserName, @"username", friendId, @"friendId", nil];
            [FlurryTrackingService logEvent:FlurryCustomEventRequestFriend param:param];
            
            // update friends & sent requests
            [self actionGetFollowing:^(NSArray *friends) {
                [self actionGetSentRequests:^(NSArray *sentRequests) {
                    completion(YES);
                }];
            }];
        }
        else {
            completion(NO);
        }
    }];
}

- (void)acceptRequest:(NSString*)requestId completion:(void(^)(BOOL))completion {
    [_userWebService acceptFriendRequest:requestId completion:^(BOOL isSuccess) {
        if (isSuccess) {
            OCUser *user = [Global getOCUser];
            NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user.UserName, @"username", requestId, @"requestId", nil];
            [FlurryTrackingService logEvent:FlurryCustomEventAcceptFriend param:param];
            [self actionGetReceivedRequests:^(NSArray *rcvRequests){
                [self actionGetFollowing:^(NSArray *friends){
                    completion(YES);
                }];
            }];
        }
        else {
            completion(NO);
        }
    }];
}

- (void)removeFriend:(NSString*)friendId completion:(void(^)(BOOL))completion {
    [_userWebService deleteFriend:friendId completion:^(BOOL isSuccess) {
        if (isSuccess) {
            [self actionGetFollowing:^(NSArray *friends){
                completion(YES);
            }];
        }
        else {
            completion(NO);
        }
    }];
}

- (void)declineRequest:(NSString*)requestId completion:(void(^)(BOOL))completion {
    [_userWebService cancelFriendRequest:requestId completion:^(BOOL isSuccess) {
        if (isSuccess) {
            OCUser *user = [Global getOCUser];
            NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user.UserName, @"username", requestId, @"requestId", nil];
            [FlurryTrackingService logEvent:FlurryCustomEventDenyFriend param:param];
            [self actionGetReceivedRequests:^(NSArray *rcvRequests) {
                completion(YES);
            }];
        }
        else {
            completion(NO);
        }
    }];
}

- (void)cancelRequest:(NSString*)requestId completion:(void(^)(BOOL))completion {
    [_userWebService cancelFriendRequest:requestId completion:^(BOOL isSuccess) {
        if (isSuccess) {
            [self actionGetSentRequests:^(NSArray *sentRequests) {
                completion(YES);
            }];
        }
        else {
            completion(NO);
        }
    }];
}

- (void)acceptAllRequests:(void(^)(BOOL))completion {
    [_userWebService acceptAllFriendRequest:^(BOOL isSuccess) {
        if (isSuccess) {
            [_receivedRequests removeAllObjects];
            [self actionGetFollowing:^(NSArray *friends){
                completion(YES);
            }];
        }
        else {
            completion(NO);
        }
    }];
}

- (void)declineAllRequests:(void(^)(BOOL))completion {
    [_userWebService declineAllFriendRequest:^(BOOL isSuccess) {
        if (isSuccess) {
            [_receivedRequests removeAllObjects];
            completion(YES);
        }
        else {
            completion(NO);
        }
    }];
}

#pragma mark -
- (UserRelationType)getUserRelationTypeShip:(NSNumber*)userId {
    UserRelationType relationShip = UserRelationTypeNone;
    
    OCUser *user = [Global getOCUser];
    if (user.Id == [userId integerValue]) {
        relationShip = UserRelationTypeSelf;
    }
    else if ([self isSentAlready:userId]) {
        relationShip = UserRelationTypeRequested;
    }
    else if ([self isReceivedAlready:userId]) {
        relationShip = UserRelationTypeReceived;
    }
    else if ([self isFriendAlready:userId]) {
        relationShip = UserRelationTypeFriend;
    }
    return relationShip;
}

- (void) clearCachedData {
    [_friends removeAllObjects];
    [_results removeAllObjects];
    [_receivedRequests removeAllObjects];
    [_sentRequests removeAllObjects];
}

- (void) clearCachedDataWithDataType:(FriendDataType)type {
    switch (type) {
        case FriendDataTypeFriend:
            [_friends removeAllObjects];
            break;
        case FriendDataTypeRcvRequest:
            [_receivedRequests removeAllObjects];
            break;
        case FriendDataTypeSentRequest:
            [_sentRequests removeAllObjects];
            break;
        case FriendDataTypeSearchResult:
            [_results removeAllObjects];
            break;
        default:
            break;
    }
}

#pragma mark -
- (NSInteger)getFriendsCount {
    return [_friends count];
}

- (NSInteger)getAllRcvRequestCount {
    return [_receivedRequests count];
}

- (NSInteger)getNewRequestCount {
    NSArray *oldRequests = [[NSUserDefaults standardUserDefaults] objectForKey:[self getRequestKey]];
    NSInteger newRequestCount = 0;
    for (NSDictionary *requestDic in _receivedRequests) {
        NSNumber *requestId = [requestDic objectForKey:@"Id"];
        if (![oldRequests containsObject:requestId]) {
            newRequestCount ++;
        }
    }
    return newRequestCount;
}

- (void) readAllRequests {
    NSString *requestKey = [self getRequestKey];
    NSArray *oldRequests = [[NSUserDefaults standardUserDefaults] objectForKey:requestKey];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:oldRequests];
    for (NSDictionary *requestDic in _receivedRequests) {
        NSNumber *requestId = [requestDic objectForKey:@"Id"];
        if (![array containsObject:requestId]) {
            [array addObject:requestId];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:requestKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
- (NSInteger)getFriendBadgeCount {
    NSArray *oldRequests = [[NSUserDefaults standardUserDefaults] objectForKey:[self getFriendBadgeKey]];
    NSInteger newRequestCount = 0;
    for (NSDictionary *requestDic in _receivedRequests) {
        NSNumber *requestId = [requestDic objectForKey:@"Id"];
        if (![oldRequests containsObject:requestId]) {
            newRequestCount ++;
        }
    }
    return newRequestCount;
}

- (void) readAllFriendBadge {
    NSString *requestKey = [self getFriendBadgeKey];
    NSArray *oldRequests = [[NSUserDefaults standardUserDefaults] objectForKey:requestKey];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:oldRequests];
    for (NSDictionary *requestDic in _receivedRequests) {
        NSNumber *requestId = [requestDic objectForKey:@"Id"];
        if (![array containsObject:requestId]) {
            [array addObject:requestId];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:requestKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[AppDelegate sharedInstance] setFriendBadge:0];
}

- (void)setReceivedRequestData:(NSArray*)array {
    [_receivedRequests removeAllObjects];
    [_receivedRequests addObjectsFromArray:array];
    NSInteger newRequests = [self getFriendBadgeCount];
    [[AppDelegate sharedInstance] setFriendBadge:newRequests];
}

- (NSString*)sentRequestId:(long)friendId {
    for (NSDictionary *requestDic in _sentRequests) {
        NSDictionary *friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
        if ([[friendDic objectForKey:@"Id"] longValue] == friendId) {
            NSNumber *requestId = [requestDic objectForKey:@"Id"];
            return [requestId stringValue];
        }
    }
    return nil;
}

- (NSString*)receivedRequestId:(long)friendId {
    for (NSDictionary *requestDic in _receivedRequests) {
        NSDictionary *friendDic = [requestDic objectForKey:@"OCUser_ownerid"];
        if ([[friendDic objectForKey:@"Id"] longValue] == friendId) {
            NSNumber *requestId = [requestDic objectForKey:@"Id"];
            return [requestId stringValue];
        }
    }
    return nil;
}

- (NSString*)friendshipId:(long)friendId {
    for (NSDictionary *requestDic in _friends) {
        NSDictionary *friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
        if ([[friendDic objectForKey:@"Id"] longValue] == friendId) {
            NSNumber *requestId = [requestDic objectForKey:@"Id"];
            return [requestId stringValue];
        }
    }
    return nil;
}

#pragma mark - internal methods
- (void)actionGetFollowers:(void(^)(NSArray*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OCUser *user = [Global getOCUser];
        [_userWebService getUsersFollower:user.Id completion:^(NSArray *array) {
            if (array) {
                NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSComparisonResult resut = [(NSString *)[[obj1 objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"]
                                                compare:(NSString *)[[obj2 objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"]
                                                options:NSCaseInsensitiveSearch];
                    return resut;
                }];
                [_followers removeAllObjects];
                [_followers addObjectsFromArray:sortedArray];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(_followers);
            });
        }];
    });
}

- (void)actionGetFollowing:(void(^)(NSArray*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OCUser *user = [Global getOCUser];
        [_userWebService getUsersFollowing:user.Id completion:^(NSArray *array) {
            if (array) {
                NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSComparisonResult resut = [(NSString *)[[obj1 objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"]
                                                compare:(NSString *)[[obj2 objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"]
                                                options:NSCaseInsensitiveSearch];
                    return resut;
                }];
                [_friends removeAllObjects];
                [_friends addObjectsFromArray:sortedArray];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(_friends);
            });
        }];
    });
}

- (void)actionGetReceivedRequests:(void(^)(NSArray*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_userWebService getReceivedRequests:^(NSArray *array) {
            [_receivedRequests removeAllObjects];
            [_receivedRequests addObjectsFromArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(_receivedRequests);
            });
        }];
    });
}

- (void)actionSearchFriends:(NSString*)searchString completion:(void(^)(NSArray*))completion {
    _searchString = searchString;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_userWebService searchFriends:_searchString completion:^(NSArray *array) {
            [_results removeAllObjects];
            [_results addObjectsFromArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(_results);
            });
        }];
    });
}

- (void)actionGetSentRequests:(void(^)(NSArray*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_userWebService getSentRequests:^(NSArray *array) {
            NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSComparisonResult resut = [(NSString *)[[obj1 objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"]
                                            compare:(NSString *)[[obj2 objectForKey:@"OCUser1_friendid"] objectForKey:@"UserName"]
                                            options:NSCaseInsensitiveSearch];
                return resut;
            }];
            [_sentRequests removeAllObjects];
            [_sentRequests addObjectsFromArray:sortedArray];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(_sentRequests);
            });
        }];
    });
}

- (BOOL)isFriendAlready:(NSNumber*)userId {
    for (NSDictionary *dic in _friends) {
        NSDictionary *friendDic = [dic objectForKey:@"OCUser1_friendid"];
        NSString *friendId = [friendDic objectForKey:@"Id"];
        if ([friendId isEqual:userId]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSentAlready:(NSNumber*)userId {
    for (NSDictionary *dic in _sentRequests) {
        NSDictionary *friendDic = [dic objectForKey:@"OCUser1_friendid"];
        NSString *friendId = [friendDic objectForKey:@"Id"];
        if ([friendId isEqual:userId]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isReceivedAlready:(NSNumber*)userId {
    for (NSDictionary *dic in _receivedRequests) {
        NSDictionary *friendDic = [dic objectForKey:@"OCUser_ownerid"];
        NSString *friendId = [friendDic objectForKey:@"Id"];
        if ([friendId isEqual:userId]) {
            return YES;
        }
    }
    return NO;
}

- (NSString*) getRequestKey {
    OCUser *user = [Global getOCUser];
    return [NSString stringWithFormat:@"Old_Request_Key_%ld", user.Id];
}

- (NSString*) getFriendBadgeKey {
    OCUser *user = [Global getOCUser];
    return [NSString stringWithFormat:@"Old_Badge_Key_%ld", user.Id];
}

@end
