//
//  Twyst.m
//  Twyst
//
//  Created by Niklas Ahola on 8/27/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "Twyst.h"
#import "TTwyst.h"
#import "TTwystNews.h"
#import "TTwystOwnerManager.h"

@implementation Twyst

+ (Twyst*)createNewTwyst {
    return [[Twyst alloc] init];
}

+ (Twyst*)createNewTwystWithDictionary:(NSDictionary*)dic {
    return [[Twyst alloc] initWithDictionary:dic];
}

+ (Twyst*)createNewTwystWithTTwyst:(TTwyst*)tTwyst {
    return [[Twyst alloc] initWithTTwyst:tTwyst];
}

- (id) init {
    self = [super init];
    if (self)   {
        self.Id = 0;
        self.Caption = @"";
        self.MemberCount = 0;
        self.IsComplete = NO;
        self.Deleted = NO;
        self.Status = 0;
        self.DateFinalized = [NSDate date];
        self.AllowReplies = @"yes";
        self.AllowPass = YES;
        self.Visibility = @"friends";
        self.ViewCount = 0;
        self.ReplyCount = 0;
        self.ImageCount = 0;
        self.ownerId = 0;
        self.UserLike = 0;
        self.CommentCount = 0;
        self.PassedBy = @"";

        self.isMyFeed = NO;
        self.isAdmin = NO;
        self.userId = [Global getOCUser].Id;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary*)dic {
    self = [super init];
    if (self) {
        self.Id = [[dic objectForKey:@"Id"] longValue];
        self.Caption = [dic objectForKey:@"Caption"];
        self.MemberCount = [[dic objectForKey:@"MemberCount"] integerValue];
        self.IsComplete = [[dic objectForKey:@"IsComplete"] boolValue];
        self.Deleted = [[dic objectForKey:@"Deleted"] boolValue];
        self.Status = [[dic objectForKey:@"Status"] integerValue];
        self.AllowReplies = [dic objectForKey:@"AllowReplies"];
        self.AllowPass = [[dic objectForKey:@"AllowPass"] boolValue];
        self.Visibility = [dic objectForKey:@"Visibility"];
        self.ViewCount = [[dic objectForKey:@"ViewCount"] integerValue];
        self.ReplyCount = [[dic objectForKey:@"ReplyCount"] integerValue];
        self.ImageCount = [[dic objectForKey:@"ImageCount"] integerValue];
        self.UserLike = [[dic objectForKey:@"UserLike"] integerValue];
        self.CommentCount = [[dic objectForKey:@"CommentCount"] integerValue];
        self.ownerId = [[dic objectForKey:@"UserId"] longValue];
        
        id passedBy = [dic objectForKey:@"PassedBy"];
        if ([passedBy isKindOfClass:[NSString class]]) {
            self.PassedBy = passedBy;
        }
        
        self.isAdmin = (self.ownerId == 1);
        self.userId = [Global getOCUser].Id;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        
        NSString *DateFinalized = [dic objectForKey:@"DateFinalized"];
        if (IsNSStringValid(DateFinalized)) {
            self.DateFinalized = [dateFormatter dateFromString:[DateFinalized substringToIndex:19]];
        }
        else {
            self.DateFinalized = [[Global getInstance] localDateToUTCDate:[NSDate date]];
        }
        
        NSString *actionType = [dic objectForKey:@"ActionType"];
        NSString *actionUserName = [dic objectForKey:@"ActionUserName"];
        NSNumber *actionSenderId = [dic objectForKey:@"ActionSenderId"];
        NSString *actionTimeStamp = [dic objectForKey:@"ActionTimeStamp"];
        
        if (IsNSStringValid(actionType)) {
            self.ActionType = actionType;
        }
        if (IsNSStringValid(actionUserName)) {
            self.ActionUserName = actionUserName;
        }
        if ([actionSenderId isKindOfClass:[NSNumber class]]) {
            self.ActionSenderId = [actionSenderId longValue];
        }
        if (IsNSStringValid(actionTimeStamp)) {
            self.ActionTimeStamp = [dateFormatter dateFromString:[actionTimeStamp substringToIndex:19]];
        }
        
        NSDictionary *userDic = [dic objectForKey:@"OCUser"];
        OCUser *user = [OCUser createNewUserWithDictionary:userDic];
        self.owner = user;
    }
    return self;
}

- (id) initWithTTwyst:(TTwyst*)tTwyst {
    self = [super init];
    if (self) {
        self.Id = [tTwyst.twystId longValue];
        self.Caption = tTwyst.caption;
        self.MemberCount = [tTwyst.memberCount integerValue];
        self.IsComplete = YES;
        self.Deleted = NO;
        self.Status = [tTwyst.status integerValue];
        self.AllowReplies = tTwyst.allowReplies;
        self.AllowPass = [tTwyst.allowPass boolValue];
        self.Visibility = tTwyst.visibility;
        self.ViewCount = [tTwyst.viewCount integerValue];
        self.ReplyCount = [tTwyst.replyCount integerValue];
        self.ImageCount = [tTwyst.imageCount integerValue];
        self.ownerId = [tTwyst.ownerId longValue];
        self.PassedBy = @"";
        
        self.isAdmin = (self.ownerId == 1);
        self.userId = [Global getOCUser].Id;
        
        self.DateFinalized = tTwyst.dateFinalized;
        self.ActionType = tTwyst.actionType;
        self.ActionSenderId = [tTwyst.actionSenderId longValue];
        self.ActionUserName = tTwyst.actionUsername;
        self.ActionTimeStamp = tTwyst.actionTimeStamp;
        
        TTwystOwner *tOwner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:self.ownerId];
        OCUser *owner = [[TTwystOwnerManager sharedInstance] getOCUserFromTwystOwner:tOwner];
        self.owner = owner;
    }
    return self;
}

@end
