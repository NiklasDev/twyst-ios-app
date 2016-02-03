//
//  TLibraryTwystManager.m
//  Twyst
//
//  Created by Niklas Ahola on 9/8/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "TLibraryTwystManager.h"

@implementation TLibraryTwystManager

static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

#pragma class definition
- (id) init {
    self = [super init];
    if (self)   {
        self.entityName = DEF_DB_ENTITY_NAME_TLibraryTwyst;
    }
    return self;
}

@end
