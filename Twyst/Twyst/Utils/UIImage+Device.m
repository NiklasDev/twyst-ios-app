//
//  UIImage+Device.m
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

@implementation UIImage (Device)
+ (NSString*)imageNameForDevice:(NSString*)name {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            name = [name stringByAppendingString:@"-4.7inch@2x"];
            break;
        case DeviceTypePhone6Plus:
            name = [name stringByAppendingString:@"-5.5inch@3x"];
            break;
        default:
            name = [name stringByAppendingString:@"@2x"];
            break;
    }
    return name;
}

+ (UIImage*)imageNamedContentFile:(NSString*)bundleName {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6Plus:
            bundleName = [bundleName stringByAppendingString:@"@3x"];
            break;
        default:
            bundleName = [bundleName stringByAppendingString:@"@2x"];
            break;
    }
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"png"];
    return [UIImage imageWithContentsOfFile:fileLocation];
}

+ (UIImage*)imageNamedContentFile:(NSString*)bundleName extension:(NSString*)extension {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6Plus:
            bundleName = [bundleName stringByAppendingString:@"@3x"];
            break;
        default:
            bundleName = [bundleName stringByAppendingString:@"@2x"];
            break;
    }
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:bundleName ofType:extension];
    return [UIImage imageWithContentsOfFile:fileLocation];
}

+ (UIImage*)imageNamedForDevice:(NSString*)name {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            name = [name stringByAppendingString:@"-4.7inch"];
            break;
        case DeviceTypePhone6Plus:
            name = [name stringByAppendingString:@"-5.5inch"];
            break;
        default:
            break;
    }
    return [UIImage imageNamedContentFile:name];
}

+ (UIImage*)imageNamedForAllDevices:(NSString*)name {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone4:
            name = [name stringByAppendingString:@"-3.5inch"];
            break;
        case DeviceTypePhone6:
            name = [name stringByAppendingString:@"-4.7inch"];
            break;
        case DeviceTypePhone6Plus:
            name = [name stringByAppendingString:@"-5.5inch"];
            break;
        default:
            break;
    }
    return [UIImage imageNamedContentFile:name];
}

@end
