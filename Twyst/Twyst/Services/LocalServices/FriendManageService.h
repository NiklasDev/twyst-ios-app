//
//  FriendManageService.h
//  Twyst
//
//  Created by Default on 8/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendManageServiceDelegate <NSObject>

- (void)friendManagerServiceDataDidPull:(FriendDataType)type data:(NSArray*)data;

@end

@interface FriendManageService : NSObject

@property (nonatomic, retain) NSMutableArray *followers;
@property (nonatomic, retain) NSMutableArray *friends;
@property (nonatomic, retain) NSMutableArray *requests;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSMutableArray *friendRequests;

@property (nonatomic, assign) id <FriendManageServiceDelegate> delegate;

+ (id) sharedInstance;
- (void)startNewFriendSession;

- (NSArray *)getDataWithType:(FriendDataType)type;

- (void)actionGetFollowers:(void(^)(NSArray*))completion;
- (void)actionGetFollowing:(void(^)(NSArray*))completion;
- (void)actionGetReceivedRequests:(void(^)(NSArray*))completion;
- (void)actionGetSentRequests:(void(^)(NSArray*))completion;
- (void)actionSearchFriends:(NSString*)searchString completion:(void(^)(NSArray*))completion;

- (void)requesetFriend:(NSString*)friendId completion:(void(^)(BOOL))completion;
- (void)acceptRequest:(NSString*)requestId completion:(void(^)(BOOL))completion;
- (void)removeFriend:(NSString*)friendId completion:(void(^)(BOOL))completion;
- (void)declineRequest:(NSString*)requestId completion:(void(^)(BOOL))completion;
- (void)cancelRequest:(NSString*)requestId completion:(void(^)(BOOL))completion;
- (void)acceptAllRequests:(void(^)(BOOL))completion;
- (void)declineAllRequests:(void(^)(BOOL))completion;

- (UserRelationType)getUserRelationTypeShip:(NSNumber*)userId;

- (NSInteger)getFriendsCount;
- (NSInteger)getAllRcvRequestCount;
- (NSInteger)getNewRequestCount;
- (void) readAllRequests;

- (NSInteger)getFriendBadgeCount;
- (void) readAllFriendBadge;

- (void) clearCachedData;
- (void) clearCachedDataWithDataType:(FriendDataType)type;

- (void)setReceivedRequestData:(NSArray*)array;

- (NSString*)sentRequestId:(long)friendId;
- (NSString*)receivedRequestId:(long)friendId;
- (NSString*)friendshipId:(long)friendId;

@end
