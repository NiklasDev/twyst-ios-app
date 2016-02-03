//
//  AppPermissionService.h
//  Twyst
//
//  Created by Niklas Ahola on 6/3/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPermissionService : NSObject

+ (id) sharedInstance;

- (BOOL)isCameraEnable;
- (BOOL)isMicroPhoneEnable;
- (void)presentCameraPermissionAlert:(void(^)(BOOL))block;
- (void)presentMicroPhonePermissionAlert:(void(^)(BOOL))block;

@end
