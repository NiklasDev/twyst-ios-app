//
//  Global.h
//  Twyst
//
//  Created by Niklas Ahola on 8/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Twyst.h"
#import "Config.h"
#import "EditPhotoService.h"
#import "FFlipframeSaved.h"
#import "FlipframePhotoModel.h"
#import "FlipframeVideoModel.h"

@interface Global : NSObject

@property (nonatomic, retain) Config *config;
@property (nonatomic, assign) DeviceType deviceType;
@property (nonatomic, assign) BOOL isCancelCameraProcessing;

@property (nonatomic, retain) NSMutableArray *reportedReplies;


+ (Global*) getInstance;

+ (void) startUp;
+ (DeviceType) deviceType;

+ (NSString *)getInviteCode;
+ (void)setInviteCode:(NSString *)inviteCode;

+ (OCUser*) getOCUser;
+ (void) updateOCUser:(OCUser*) ocUser;
+ (void) saveOCUser;
+ (void) recoverOCUser;

+ (Config*) getConfig;
+ (void) saveConfig;

- (void) syncUser;
- (void) syncUser:(void (^)(OCUser*)) completion;

//new refactor
@property (nonatomic, retain) FlipframeModel *currentFlipframeModel;

- (void) startNewFlipframeModel:(FlipframeInputType)inputType withService:(FlipframeInputService*)inputService;
- (void) startNewFlipframeModel:(FlipframeInputType)inputType withVideoURL:(NSURL*)videoURL duration:(CGFloat)duration isCapture:(BOOL)isCapture isMirrored:(BOOL)isMirrored;

+ (FlipframePhotoModel*) getCurrentFlipframePhotoModel;
+ (FlipframeVideoModel*) getCurrentFlipframeVideoModel;

// 
+ (void) postLibraryItemDidSaveNotification;
+ (void) postLibraryItemDidDeleteNotification;
+ (void) postTwystDidCreateNotification:(Twyst*)twyst;
+ (void) postTwystDidReplyNotification:(Twyst*)twyst;
+ (void) postTwystDidDeleteNotification:(Twyst*)twyst;
+ (void) postTwystDidLeaveNotification:(Twyst*)twyst;

- (NSString*)timeStringWithDateString:(NSString*)dateString;
- (NSString*)timeStringWithDate:(NSDate*)date;
- (NSDate*)localDateToUTCDate:(NSDate*)date;

@end
