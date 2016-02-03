//
//  IANoticeManageService.h
//  Twyst
//
//  Created by Niklas Ahola on 1/7/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

// in-app-notice manage service

#import <Foundation/Foundation.h>

@protocol IANoticeNotificationDelegate <NSObject>
- (void)notificationDidReceive:(NSArray*)notifications;
@end

@protocol IANoticeTwystNewsDelegate <NSObject>
- (void)twystNewsDidReceive:(NSArray*)news;
@end

@interface IANoticeManageService : NSObject

@property (nonatomic, assign) id <IANoticeNotificationDelegate> notificationDelegate;
@property (nonatomic, assign) id <IANoticeTwystNewsDelegate> newsDelegate;

+ (id)sharedInstance;

- (void)startNewIANSession;
- (void)stopIANSession;
- (void)checkIANManually:(void(^)(BOOL))completion;

@end
