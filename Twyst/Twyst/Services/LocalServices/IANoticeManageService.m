//
//  IANoticeManageService.m
//  Twyst
//
//  Created by Niklas Ahola on 1/7/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "UserWebService.h"
#import "FriendManageService.h"
#import "IANoticeManageService.h"

@interface IANoticeManageService() {
    NSTimer *_timer;
    NSTimeInterval _lastUpdate;
    BOOL _isWaitingResponse;
    
    UserWebService *_userWebService;
    FriendManageService *_friendService;
}

@end


@implementation IANoticeManageService

static id _sharedObject = nil;
+ (id)sharedInstance {
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
        _userWebService = [UserWebService sharedInstance];
        _friendService = [FriendManageService sharedInstance];
    }
    return self;
}

- (void)startNewIANSession {
    
    [self addNotifications];
    
    _isWaitingResponse = NO;
    
    [self checkNotification:nil];
    
    if ([Global deviceType] == DeviceTypePhone4) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                  target:self
                                                selector:@selector(onTimer_iPhone4:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    else {
        _timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)checkIANManually:(void(^)(BOOL))completion {
    [self checkNotification:^(BOOL isSuccess) {
        if (completion) {
            completion(isSuccess);
        }
    }];
}

- (void)stopIANSession {
    [self removeNotifications];
    
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - internal methods
- (void)onTimer:(NSTimer*)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (_isWaitingResponse == NO) {
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            if (now - _lastUpdate > VAL_NOTIFICATION_CHECK_INTERVAL) {
                [self checkNotification:nil];
            }
        }
    });
}

- (void)onTimer_iPhone4:(NSTimer*)sender {
    if (_isWaitingResponse == NO) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (now - _lastUpdate > VAL_NOTIFICATION_CHECK_INTERVAL) {
            [self checkNotification:nil];
        }
    }
}


- (void)checkNotification:(void(^)(BOOL))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _isWaitingResponse = YES;
        [_userWebService getAllNotifications:^(NSDictionary *result) {
            
            if (result) {
                NSArray *notifications = [result objectForKey:@"Notifications"];
                NSArray *stringgNews = [result objectForKey:@"Stringnews"];
                NSArray *rcvRequests = [result objectForKey:@"Friends"];
                
                if ([notifications isKindOfClass:[NSArray class]]) {
                    [self handleNotification:notifications];
                }
                
                if ([stringgNews isKindOfClass:[NSArray class]]) {
                    [self handleStringgNews:stringgNews];
                }
                
                if ([rcvRequests isKindOfClass:[NSArray class]]) {
                    [self handleReceivedRequests:rcvRequests];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(YES);
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(NO);
                    }
                });
            }
            
            _isWaitingResponse = NO;
            _lastUpdate = [[NSDate date] timeIntervalSince1970];
        }];
    });
}

#pragma mark - handle twyst notification methods
- (void)handleNotification:(NSArray*)notifications {
    if ([notifications count]) {
        
//        NSMutableArray *arrNotification = [[NSMutableArray alloc] init];
//        for (NSDictionary *noteDic in notifications) {
//            long senderId = [[noteDic objectForKey:@"SenderId"] longValue];
//            OCUser *user = [Global getOCUser];
//            if (senderId != user.Id) {
//                [arrNotification addObject:noteDic];
//            }
//        }
//        
        if ([notifications count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.notificationDelegate respondsToSelector:@selector(notificationDidReceive:)]) {
                    [self.notificationDelegate notificationDidReceive:notifications];
                }
            });
        }
    }
}

- (void) addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTwystDidDownload:)
                                                 name:kTwystDidDownloadNotification
                                               object:nil];
}

- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTwystDidDownloadNotification
                                                  object:nil];
}

- (void)handleTwystDidDownload:(NSNotification*)notification {
    
}

#pragma mark - handle stringg news methods
- (void)handleStringgNews:(NSArray*)stringgNews {
    if ([stringgNews count]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.newsDelegate respondsToSelector:@selector(twystNewsDidReceive:)]) {
                [self.newsDelegate twystNewsDidReceive:stringgNews];
            }
        });
    }
}

#pragma mark - handle received friend requests methods
- (void)handleReceivedRequests:(NSArray*)rcvRequests {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_friendService setReceivedRequestData:rcvRequests];
    });
}

- (void)dealloc {
    [self removeNotifications];
}

@end
