//
//  AppPermissionService.m
//  Twyst
//
//  Created by Niklas Ahola on 6/3/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppPermissionService.h"

@interface AppPermissionService() <UIAlertViewDelegate>

@end

@implementation AppPermissionService

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

- (BOOL)isCameraEnable {
//    return YES;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus == AVAuthorizationStatusAuthorized;
}

- (BOOL)isMicroPhoneEnable {
//    return YES;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return authStatus == AVAuthorizationStatusAuthorized;
}

- (void)presentCameraPermissionAlert:(void(^)(BOOL))block {
    [self presentMediaPermissionAlert:AVMediaTypeVideo block:block];
}

- (void)presentMicroPhonePermissionAlert:(void(^)(BOOL))block {
    [self presentMediaPermissionAlert:AVMediaTypeAudio block:block];
}

- (void)presentMediaPermissionAlert:(NSString*)mediaType block:(void(^)(BOOL))block {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusDenied){
        // denied
        [self showDeniedAlert:mediaType];
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            block(granted);
        }];
    } else {
        // impossible, unknown authorization status
    }
}

- (void)showDeniedAlert:(NSString*)mediaType {
    if ([mediaType isEqualToString:AVMediaTypeVideo]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Permission Required"
                                                        message:@"To share a post, Twyst needs permission to access the camera on your device. Click the Settings button, them toggle on the switch for Camera"
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:@"Settings", nil];
        alert.tag = 100;
        [alert show];
    }
    else if ([mediaType isEqualToString:AVMediaTypeAudio]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone Permission Required"
                                                        message:@"To share a post, Twyst needs permission to access the microphone on your device. Click the Settings button, them toggle on the switch for Microphone"
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:@"Settings", nil];
        alert.tag = 200;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
