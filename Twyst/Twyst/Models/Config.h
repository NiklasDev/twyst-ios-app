//
//  Config.h
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCUser.h"

@interface Config : NSObject

@property (nonatomic) BOOL isSaveVideo;

@property (nonatomic) BOOL isFirstTwystTime;
@property (nonatomic) BOOL isFirstCameraReplyTime;

@property (nonatomic) BOOL isFirstEditTime;
@property (nonatomic) BOOL isFirstEditVideoTime;

@property (nonatomic) BOOL isFirstPreviewTime;

@property (nonatomic, assign) long selfieStripSize;
@property (nonatomic, assign) long selfieIntervalTime;

//user local storage
@property (nonatomic, assign) long userId;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, retain) NSData *deviceToken;

- (void) save;
- (void) load;
- (void) removeCurrentUser;
- (void) addLoggedInUser:(OCUser*) ocUser;
@end
