//
//  TUserManager.m
//  Twyst
//
//  Created by Niklas Ahola on 5/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TUserManager.h"

@implementation TUserManager
static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}
- (id) init {
    self = [super init];
    if (self)   {
        self.entityName = DEF_DB_ENTITY_NAME_TUser;
    }
    return self;
}
- (TUser*) getLatestUser    {
    NSArray *users = [self loadAll];
    if (users)  {
        if (users.count > 0)    {
            return [users lastObject];
        }
    }
    return nil;
}

@end
