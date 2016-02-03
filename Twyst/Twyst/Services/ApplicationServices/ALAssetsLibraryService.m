//
//  ALAssetsLibraryService.m
//  Twyst
//
//  Created by Niklas Ahola on 2/3/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "ALAssetsLibraryService.h"

@implementation ALAssetsLibraryService

static id _sharedObject = nil;
+ (ALAssetsLibrary*)defaultAssetsLibrary {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

@end
