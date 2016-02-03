//
//  Config.m
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "Config.h"

@implementation Config

- (id) init {
    self = [super init];
    if (self != nil)    {
        
    }
    return self;
}

-(void) save    {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:self.isSaveVideo forKey:@"isSaveVideo"];
    
    [userDefaults setBool:self.isFirstTwystTime forKey:@"isFirstTwystTime"];
    [userDefaults setBool:self.isFirstCameraReplyTime forKey:@"isFirstCameraReplyTime"];
    
    [userDefaults setBool:self.isFirstEditTime forKey:@"isFirstEditTime"];
    [userDefaults setBool:self.isFirstEditVideoTime forKey:@"isFirstEditVideoTime"];
    
    [userDefaults setBool:self.isFirstPreviewTime forKey:@"isFirstPreviewTime"];
    
    [userDefaults setInteger:self.selfieStripSize forKey:@"selfieStripSize"];
    [userDefaults setInteger:self.selfieIntervalTime forKey:@"selfieIntervalTime"];
    
    [userDefaults setObject:self.email forKey:@"email"];
    [userDefaults setObject:self.password forKey:@"password"];
    
    double duserId = (double) self.userId;
    [userDefaults setDouble:duserId forKey:@"userId"];
    
    [userDefaults setObject:self.deviceToken forKey:@"deviceToken"];
    
    [userDefaults synchronize];
}

- (void) load   {
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:YES], @"isSaveVideo",
                                          
                                          [NSNumber numberWithBool:YES], @"isFirstTwystTime",
                                          [NSNumber numberWithBool:YES], @"isFirstCameraReplyTime",
                                          
                                          [NSNumber numberWithBool:YES], @"isFirstEditTime",
                                          [NSNumber numberWithBool:YES], @"isFirstEditVideoTime",
                                          
                                          [NSNumber numberWithBool:YES], @"isFirstPreviewTime",
                                          
                                          [NSNumber numberWithInteger:4], @"selfieStripSize",
                                          [NSNumber numberWithInteger:3], @"selfieIntervalTime",
                                          [NSNumber numberWithBool:NO], @"isOnline",
                                          nil, @"email",
                                          nil, @"password",
                                          nil, @"deviceToken",
                                          nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:userDefaultsDefaults];
    
    self.isSaveVideo = [userDefaults boolForKey:@"isSaveVideo"];

    self.isFirstTwystTime = [userDefaults boolForKey:@"isFirstTwystTime"];
    self.isFirstCameraReplyTime = [userDefaults boolForKey:@"isFirstCameraReplyTime"];
    
    self.isFirstEditTime = [userDefaults boolForKey:@"isFirstEditTime"];
    self.isFirstEditVideoTime = [userDefaults boolForKey:@"isFirstEditVideoTime"];
    
    self.isFirstPreviewTime = [userDefaults boolForKey:@"isFirstPreviewTime"];
        
    self.selfieStripSize = [userDefaults integerForKey:@"selfieStripSize"];
    self.selfieIntervalTime = [userDefaults integerForKey:@"selfieIntervalTime"];
    
    self.userId = [userDefaults integerForKey:@"userId"];
    self.email = [userDefaults stringForKey:@"email"];
    self.password = [userDefaults stringForKey:@"password"];
    
    self.deviceToken = [userDefaults objectForKey:@"deviceToken"];
}

//user methods
- (void) addLoggedInUser:(OCUser*) ocUser   {
    self.userId = ocUser.Id;
    self.email = ocUser.EmailAddress;
    self.password = ocUser.Password;
    [self save];
}

- (void) removeCurrentUser  {
    self.email = nil;
    self.password = nil;
    [self save];
}



@end