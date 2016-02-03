//
//  FlurryTrackingService.m
//  Twyst
//
//  Created by Niklas Ahola on 1/22/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#define DEF_FLURRY_API_KEY  @"9KWJ9HN5V5CHNVZXD7XH"

#import "Flurry.h"
#import "FlurryTrackingService.h"

@implementation FlurryTrackingService

+ (void)startNewFlurrySession {
    [Flurry setDebugLogEnabled:YES];
    [Flurry setLogLevel:FlurryLogLevelAll];
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:DEF_FLURRY_API_KEY];
}

+ (NSString*)customEventName:(FlurryCustomEvent)event {
    NSString *eventName = nil;
    switch (event) {
        case FlurryCustomEventCreateTwyst:
            eventName = @"Create a Twyst";
            break;
        case FlurryCustomEventAddComment:
            eventName = @"Add a Comment";
            break;
        case FlurryCustomEventAddReply:
            eventName = @"Add a reply";
            break;
        case FlurryCustomEventRequestFriend:
            eventName = @"Request a friend";
            break;
        case FlurryCustomEventAcceptFriend:
            eventName = @"Confirm a friend";
            break;
        case FlurryCustomEventDenyFriend:
            eventName = @"Deny friend request";
            break;
        case FlurryCustomEventInviteFriend:
            eventName = @"Text a friend an app link";
            break;
        default:
            break;
    }
    return eventName;
}

+ (void)logEvent:(FlurryCustomEvent)event {
    NSString *eventName = [[self class] customEventName:event];
    [Flurry logEvent:eventName];
}

+ (void)logEvent:(FlurryCustomEvent)event param:(NSDictionary*)param {
    NSString *eventName = [[self class] customEventName:event];
    [Flurry logEvent:eventName withParameters:param];
}

@end
