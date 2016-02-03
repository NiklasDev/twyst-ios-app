//
//  FlurryTrackingService.h
//  Twyst
//
//  Created by Niklas Ahola on 1/22/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FlurryCustomEventCreateTwyst,
    FlurryCustomEventAddComment,
    FlurryCustomEventAddReply,
    FlurryCustomEventRequestFriend,
    FlurryCustomEventAcceptFriend,
    FlurryCustomEventDenyFriend,
    FlurryCustomEventInviteFriend,
} FlurryCustomEvent;

@interface FlurryTrackingService : NSObject

+ (void)startNewFlurrySession;
+ (void)logEvent:(FlurryCustomEvent)event;
+ (void)logEvent:(FlurryCustomEvent)event param:(NSDictionary*)param;

@end
