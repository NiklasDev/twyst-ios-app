//
//  PushNotificationService.m
//  Twyst
//
//  Created by Niklas Ahola on 9/16/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

#import "AppDelegate.h"
#import "PushNotificationService.h"

#define END_POINT   @"Endpoint=sb://twystapp-namespace.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=DV6/92ZXs6n4pXmSNHQgNxTASFsoJctz6QlRI+iSqUo="
#define HUB_PATH_NAME   @"twystapp-hub"

@implementation PushNotificationService
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

- (void)startNewSession {
    OCUser *user = [Global getOCUser];
    NSData *deviceToken = [Global getConfig].deviceToken;
    NSSet *categories = [NSSet setWithObjects:[NSString stringWithFormat:@"%ld", user.Id], nil];
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:END_POINT notificationHubPath:HUB_PATH_NAME];
    [hub registerNativeWithDeviceToken:deviceToken tags:categories completion:^(NSError *error) {
//        NSString *message = error == nil ? [NSString stringWithFormat:@"Success - %ld", user.Id] : [NSString stringWithFormat:@"%@", [error userInfo]];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:HUB_PATH_NAME
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Dismiss"
//                                              otherButtonTitles:nil, nil];
//        [alert show];
        NSLog(@"////////////////////////////////////////");
        NSLog(@"END-POINT = %@ \nPATH_NAME = %@", END_POINT, HUB_PATH_NAME);
        NSLog(@"Push notification subscribing: %@", error);
    }];
}

- (void)endCurrentSession {
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:END_POINT notificationHubPath:HUB_PATH_NAME];
    [hub unregisterNativeWithCompletion:^(NSError *error) {
        NSLog(@"////////////////////////////////////////");
        NSLog(@"Push notification unsubscribing: %@", error);
    }];
}

@end
