//
//  Global.m
//  Twyst
//
//  Created by Niklas Ahola on 8/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "AppDelegate.h"

#import "TTwystNewsManager.h"
#import "TSavedTwystManager.h"

#import "UserWebService.h"
#import "UserLocalServices.h"
#import "FlipframeFileService.h"

#import "Global.h"
#import "Config.h"
#import "OCUser.h"
#import "Reachability.h"

const int kNumSampleImages = 35;
@interface Global() {
    NSDateFormatter *_dateFormatterUTC;
    NSDateFormatter *_dateFormatterLocal;
}

@end
@implementation Global

#pragma Instance methods
- (id) init {
    self = [super init];
    if (self)   {
        _dateFormatterUTC = [NSDateFormatter new];
        [_dateFormatterUTC setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [_dateFormatterUTC setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        _dateFormatterLocal = [NSDateFormatter new];
        [_dateFormatterLocal setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [_dateFormatterLocal setTimeZone:[NSTimeZone systemTimeZone]];
        
        //check device type
        self.deviceType = [self checkDeviceType];
        
        //init config
        self.config = [[Config alloc] init];
        [self.config load];
        
        //start network notification
        [[Reachability reachabilityForInternetConnection] startNotifier];
        
        //check update
//        [self checkUpdateApp];
        
        //init user
        [self syncUser];
        
        //create local directories
        [[FlipframeFileService sharedInstance] createDirectories];
    }
    return self;
}

-(void)checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"Network Status Changed: NotReachable");
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"Network Status Changed: ReachableViaWiFi");
            [self actionEnableNetwork];
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"Network Status Changed: ReachableViaWWAN");
            break;
        }
    }
}

- (void) actionEnableNetwork    {
    //sync user
    [self syncUser];
}

- (void) checkUpdateApp {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[UserWebService sharedInstance] checkUpdateVersion:DEF_VERSION_STRING completion:^(BOOL isUpdate) {
            if (isUpdate) {
                [[AppDelegate sharedInstance] showUpdateVersionView];
            }
        }];
    });
}

- (void) syncUser   {
    [self syncUser:^(OCUser *user) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLoginNotification object:nil];
    }];
}

- (void) syncUser:(void (^)(OCUser*)) completion   {
    OCUser *ocUser = [[UserLocalServices sharedInstance] ocUser];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[UserWebService sharedInstance] loginUser:ocUser.UserName withPass:ocUser.Password completion:^(OCUser *ocUser2) {
            if (ocUser2) {
                if (completion) {
                    completion(ocUser2);
                }
            }
        }];
    });
}

- (DeviceType)checkDeviceType {
    DeviceType deviceType = DeviceTypePhone4;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenHeight < 568.0) {
            deviceType = DeviceTypePhone4;
        }
        else if (screenHeight == 568.0) {
            deviceType = DeviceTypePhone5;
        }
        else if (screenHeight == 667.0) {
            deviceType = DeviceTypePhone6;
        }
        else if (screenHeight == 736.0) {
            deviceType = DeviceTypePhone6Plus;
        }
    }
    return deviceType;
}

#pragma mark--

#pragma Static methods
static Global* _instance;
+ (Global*) getInstance   {
    @synchronized(self)  {
        if (_instance == nil)
        {
            _instance = [[Global alloc] init];
        }
        return _instance;
    }
}

+ (void) startUp    {
    [Global getInstance];
}

+ (DeviceType) deviceType  {
    return [self getInstance].deviceType;
}

+ (Config*) getConfig   {
    return [self getInstance].config;
}

+ (void) loadConfig {
    [[self getConfig] load];
}

+ (void) saveConfig {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self getConfig] save];
    });
}

+ (NSString *)getInviteCode {
    return [[UserLocalServices sharedInstance] inviteCode];
}

+ (void)setInviteCode:(NSString *)inviteCode {
    [[UserLocalServices sharedInstance] setInviteCode:inviteCode];
}

+ (OCUser*) getOCUser   {
    return [[UserLocalServices sharedInstance] ocUser];
}

+ (void) updateOCUser:(OCUser*) ocUser    {
    [[UserLocalServices sharedInstance] updateOCUser:ocUser];
}

+ (void) recoverOCUser {
    [[UserLocalServices sharedInstance] recoverOCUser];
}

+ (void) saveOCUser {
    [[UserLocalServices sharedInstance] saveOCUser];
}

#pragma mark--

#pragma new refactor code
- (void) startNewFlipframeModel:(FlipframeInputType) inputType withService:(FlipframeInputService*) inputService {
    self.currentFlipframeModel = nil;
    FlipframePhotoModel *flipframePhotoModel = [[FlipframePhotoModel alloc] initWithType:inputType withService:inputService];
    self.currentFlipframeModel = flipframePhotoModel;
}

- (void) startNewFlipframeModel:(FlipframeInputType)inputType withVideoURL:(NSURL*)videoURL duration:(CGFloat)duration isCapture:(BOOL)isCapture isMirrored:(BOOL)isMirrored {
    self.currentFlipframeModel = nil;
    FlipframeVideoModel *flipframeVideoModel = [[FlipframeVideoModel alloc] initWithType:inputType videoURL:videoURL duration:duration isCapture:isCapture isMirrored:isMirrored];
    self.currentFlipframeModel = flipframeVideoModel;
}

+ (FlipframePhotoModel*) getCurrentFlipframePhotoModel    {
    FlipframePhotoModel *flipframeModel = (FlipframePhotoModel*)[self getInstance].currentFlipframeModel;
    return flipframeModel;
}

+ (FlipframeVideoModel*) getCurrentFlipframeVideoModel {
    FlipframeVideoModel *flipframeModel = (FlipframeVideoModel*)[self getInstance].currentFlipframeModel;
    return flipframeModel;
}

+ (void) postLibraryItemDidSaveNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryItemDidSaveNotification object:nil];
}

+ (void) postLibraryItemDidDeleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLibraryItemDidDeleteNotification object:nil];
}

+ (void) postTwystDidCreateNotification:(Twyst*)twyst {
    NSDictionary *userInfo = @{@"Twyst":twyst};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwystDidCreateNotification object:nil userInfo:userInfo];
}

+ (void) postTwystDidReplyNotification:(Twyst*)twyst {
    NSDictionary *userInfo = @{@"Twyst":twyst};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwystDidReplyNotification object:nil userInfo:userInfo];
}

+ (void) postTwystDidDeleteNotification:(Twyst*)twyst {
    NSDictionary *userInfo = @{@"Twyst":twyst};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwystDidDeleteNotification object:nil userInfo:userInfo];
}

+ (void) postTwystDidLeaveNotification:(Twyst*)twyst {
    NSDictionary *userInfo = @{@"Twyst":twyst};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTwystDidLeaveNotification object:nil userInfo:userInfo];
}

- (NSDate*)localDateToUTCDate:(NSDate*)localDate {
    NSString *localDateString = [_dateFormatterUTC stringFromDate:localDate];
    NSDate *dateUTC = [_dateFormatterLocal dateFromString:localDateString];
    return dateUTC;
}

- (NSString*)timeStringWithDateString:(NSString*)dateString {
    NSDate *date = [_dateFormatterLocal dateFromString:dateString];
    NSString *now = [_dateFormatterUTC stringFromDate:[NSDate date]];
    NSDate *nowUTC = [_dateFormatterLocal dateFromString:now];
    
    NSTimeInterval deltaTime = [nowUTC timeIntervalSince1970] - [date timeIntervalSince1970];
    return [self timeStringWithTimeStamp:deltaTime];
}

- (NSString*)timeStringWithDate:(NSDate *)date {
    NSString *now = [_dateFormatterUTC stringFromDate:[NSDate date]];
    NSDate *nowUTC = [_dateFormatterLocal dateFromString:now];
    
    NSTimeInterval deltaTime = [nowUTC timeIntervalSince1970] - [date timeIntervalSince1970];
    return [self timeStringWithTimeStamp:deltaTime];
}

- (NSString*)timeStringWithTimeStamp:(NSTimeInterval)deltaTime {
    if (deltaTime < 120) {
        return @"1m";
    }
    else if (deltaTime < 3600) {
        return [NSString stringWithFormat:@"%.0fm", (deltaTime / 60)];
    }
    else if (deltaTime < 86400) {
        int hour = (int)(deltaTime / 3600);
        if (hour == 1) {
            return @"1h";
        }
        else {
            return [NSString stringWithFormat:@"%dh", hour];
        }
    }
    else if (deltaTime < 604800) {
        int day = (int)(deltaTime / 86400);
        if (day == 1) {
            return @"1d";
        }
        else {
            return [NSString stringWithFormat:@"%dd", day];
        }
    }
    else {
        return [NSString stringWithFormat:@"%.0fw", deltaTime / 604800];
    }
}

@end
