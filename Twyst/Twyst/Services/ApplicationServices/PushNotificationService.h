//
//  PushNotificationService.h
//  Twyst
//
//  Created by Niklas Ahola on 9/16/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationService : NSObject

+ (id) sharedInstance;

- (void)startNewSession;
- (void)endCurrentSession;

@end
