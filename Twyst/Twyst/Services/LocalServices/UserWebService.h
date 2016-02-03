//
//  UserWebService.h
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCUser.h"
#import "Twyst.h"

@interface UserWebService : NSObject

+ (id)sharedInstance;

#pragma mark - check version method

- (void)checkUpdateVersion:(NSString*)version completion:(void(^)(BOOL))completion;

#pragma mark - invite codes

- (void)inviteCodeRequestCodeWithcompletion:(void(^)(NSString *inviteCode))completion;
- (void)inviteCodeVerifyCode:(NSString *)code completion:(void(^)(BOOL isValid))completion;
- (void)inviteCodeRedeemCode:(NSString *)code completion:(void(^)(BOOL isSuccess))completion;

#pragma mark - user manage methods

- (void)token:(NSString*) email withPass:(NSString*) password completion:(void (^)(NSString*)) completion;

- (void)loginUser:(NSString*) email withPass:(NSString*) password completion:(void (^)(OCUser*)) completion;

- (void)logOutUser:(void (^)(BOOL)) completion;

- (void)registerNewUser:(NSString*) email withPass:(NSString*) password firstName:(NSString*)firstName lastName:(NSString*)lastName completion:(void (^)(OCUser*, BOOL)) completion;

- (void)getOCUser:(long)userId completion:(void(^)(OCUser*))completion;

#pragma mark - password manage methods

- (void)forgotPassword:(NSString*) email completion:(void (^)(NSString*)) completion;

- (void)updatePassword:(NSString*) newPassword completion:(void (^)(OCUser*)) completion;

#pragma mark - update profile method

- (void)updateProfile:(OCUser*) user completion:(void (^)(NSInteger)) completion;

- (void)updateEmail:(NSString*) email completion:(void (^)(NSInteger))completion;

- (void)uploadProfilePic:(NSString*)fileName completion:(void (^)(OCUser*)) completion;

#pragma mark - friend related methods

- (void)searchFriends:(NSString*)searchString completion:(void(^)(NSArray*))completion;

- (void)getSentRequests:(void(^)(NSArray*))completion;

- (void)getReceivedRequests:(void(^)(NSArray*))completion;

- (void)requestFriend:(NSString*)friendId completion:(void(^)(BOOL))completion;

- (void)acceptFriendRequest:(NSString*)requestId completion:(void(^)(BOOL))completion;

- (void)acceptAllFriendRequest:(void(^)(BOOL))completion;

- (void)cancelFriendRequest:(NSString*)requestId completion:(void(^)(BOOL))completion;

- (void)declineAllFriendRequest:(void(^)(BOOL))completion;

- (void)deleteFriend:(NSString*)friendId completion:(void(^)(BOOL))completion;

- (void)getFriendList:(long)userId completion:(void(^)(NSArray *))completion;

- (void)getFriendFollowersList:(long)userId completion:(void(^)(NSArray *))completion;

- (void)verifyPhone:(NSString*)code completion:(void(^)(BOOL))completion;

- (void)sendVerificationCode:(NSString*)code completion:(void(^)(BOOL))completion;

- (void)searchFriendByPhoneCode:(NSString*)phoneCodes completion:(void(^)(NSArray*))completion;

- (void)getFriendProfile:(long)friendId start:(NSInteger)start completion:(void(^)(NSDictionary*))completion;

- (void)getUsersFollower:(long)userId completion:(void(^)(NSArray *))completion;

- (void)getUsersFollowing:(long)userId completion:(void(^)(NSArray *))completion;

#pragma mark - home feed related methods

//get static amount feeds from the time stamp
- (void)getFeeds:(NSDate*)timeStamp bunch:(NSInteger)bunch completion:(void(^)(NSArray*))completion;

- (void)getPrivateTwysts:(NSInteger)start bunch:(NSInteger)bunch completion:(void(^)(NSArray*))completion;

- (void)getMyTwysts:(NSInteger)start bunch:(NSInteger)bunch completion:(void(^)(NSArray*))completion;

- (void)getUserLikedTwysts:(long)userId start:(NSInteger)start completion:(void(^)(NSArray*))completion;

#pragma mark - get notifications method
//get all notifications (twyst notifications, twyst news, friends requests)
- (void)getAllNotifications:(void(^)(NSDictionary*))completion;

#pragma mark - twyst related methods

//return all twysts of user
- (void)getAllTwystsForUser:(void(^)(NSArray*))completion;

//return new twyst
- (void)createTwyst:(NSString*)caption allowReplies:(NSString*)allowReplies allowPass:(NSString*)allowPass visibility:(NSString*)visibility completion:(void(^)(BOOL, Twyst*))completion;

//add reply to twyst
- (void)addReplyToTwyst:(long)twystId imageCount:(NSInteger)imageCount fileName:(NSString *)fileName isMovie:(NSString*)isMovie frameTime:(NSInteger)frameTime completion:(void (^)(ResponseType, Twyst*))completion;

//share twyst to friends to get reply
- (void)shareTwyst:(long)twystId filename:(NSString *)filename imageCount:(NSInteger)imageCount isMovie:(NSString*)isMovie frameTime:(NSInteger)frameTime friends:(NSString *)friends completion:(void (^)(ResponseType, Twyst *))completion;

//pass twyst to friends
- (void)passTwyst:(long)twystId friends:(NSString *)friends completion:(void (^)(ResponseType))completion;

//delete my twyst from server
- (void)deleteUserTwyst:(long)twystId completion:(void(^)(ResponseType response))completion;

//get user list in twyst
- (void)getFriendsInTwyst:(long)twystId completion:(void(^)(NSArray*))completion;
- (void)getFriendsInTwyst:(long)twystId start:(NSInteger)start completion:(void(^)(NSArray*))completion;

//get list of twysts where you are in the twyst users table
- (void)getAllReceivedTwyst:(long)userId completion:(void(^)(NSArray*))completion;

//get a twyst of friend
- (void)getTwystOfFriend:(long)twystId completion:(void(^)(Twyst*))completion;

//get all replies of twyst
- (void)getTwystReplies:(long)twystId completion:(void(^)(NSArray*))completion;

//view twyst
- (void)viewTwyst:(long)twystId completion:(void(^)(BOOL))completion;

//leave friend twyst
- (void)hideFriendTwyst:(long)twystId completion:(void(^)(ResponseType response))completion;

//report twyst
- (void)reportTwyst:(long)twystId completion:(void(^)(BOOL))completion;

//report reply
- (void)reportRely:(long)replyId completion:(void(^)(BOOL))completion;

//add comment to twyst
- (void)addComment:(long)twystId comment:(NSString*)comment completion:(void(^)(BOOL))completion;

//get all comment of twyst
- (void)getTwystComments:(long)twystId start:(NSInteger)start completion:(void(^)(NSArray*))completion;

//delete comment
- (void)deleteComment:(long)twystId commentId:(long)commentId completion:(void(^)(BOOL))completion;

//like twyst
- (void)likeTwyst:(long)twystId completion:(void(^)(BOOL))completion;

//unlike twyst
- (void)unlikeTwyst:(long)twystId completion:(void(^)(BOOL))completion;

//get liked user list in twyst
//- (void)getTwystLikeUsers:(long)twystId completion:(void(^)(NSArray*))completion;
- (void)getTwystLikeUsers:(long)twystId start:(NSInteger)start completion:(void(^)(NSArray*))completion;

//get comment count and like of given twyst
- (void)getTwystPreviewInfo:(long)twystId completion:(void (^)(BOOL, NSInteger, NSInteger, NSInteger, NSInteger, NSInteger, BOOL))completion;

//get view count of twyst
- (void)getTwystViewCount:(long)twystId completion:(void(^)(BOOL, NSInteger))completion;

//get twyst latest activities
- (void)getTwystActivity:(long)twystId completion:(void(^)(NSArray*))completion;

@end
