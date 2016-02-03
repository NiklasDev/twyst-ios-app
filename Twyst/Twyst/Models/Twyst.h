//
//  Twyst.h
//  Twyst
//
//  Created by Niklas Ahola on 8/27/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "OCUser.h"
#import <Foundation/Foundation.h>

@class TTwyst;

@interface Twyst : NSObject

@property (nonatomic, assign) long Id;
@property (nonatomic, retain) NSString *Caption;
@property (nonatomic, assign) NSInteger MemberCount;
@property (nonatomic, assign) BOOL IsComplete;
@property (nonatomic, assign) BOOL Deleted;
@property (nonatomic, assign) NSInteger Status;
@property (nonatomic, retain) NSDate *DateFinalized;
@property (nonatomic, retain) NSString *AllowReplies;
@property (nonatomic, assign) BOOL AllowPass;
@property (nonatomic, retain) NSString *Visibility;
@property (nonatomic, assign) NSInteger ViewCount;
@property (nonatomic, assign) NSInteger ReplyCount;
@property (nonatomic, assign) NSInteger ImageCount;
@property (nonatomic, assign) NSInteger UserLike;
@property (nonatomic, assign) NSInteger CommentCount;
@property (nonatomic, retain) NSString *PassedBy;

@property (nonatomic, retain) NSString *ActionType;
@property (nonatomic, retain) NSString *ActionUserName;
@property (nonatomic, assign) long ActionSenderId;
@property (nonatomic, retain) NSDate *ActionTimeStamp;

@property (nonatomic, assign) long ownerId;
@property (nonatomic, assign) long userId;
@property (nonatomic, assign) BOOL isMyFeed;    // is Public stringg
@property (nonatomic, assign) BOOL isAdmin;     // created from admin or not
@property (nonatomic, retain) OCUser *owner;

+ (Twyst*)createNewTwyst;
+ (Twyst*)createNewTwystWithDictionary:(NSDictionary*)dic;
+ (Twyst*)createNewTwystWithTTwyst:(TTwyst*)tTywst;

@end
