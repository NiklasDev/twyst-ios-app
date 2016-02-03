//
//  UIImage+Device.h
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Device)

+ (NSString*)imageNameForDevice:(NSString*)name;
+ (UIImage*)imageNamedForDevice:(NSString*)name;
+ (UIImage*)imageNamedForAllDevices:(NSString*)name;
+ (UIImage*)imageNamedContentFile:(NSString*)bundleName;
+ (UIImage*)imageNamedContentFile:(NSString*)bundleName extension:(NSString*)extension;

@end
