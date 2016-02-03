//
//  TUserManager.h
//  Twyst
//
//  Created by Niklas Ahola on 5/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TUser.h"
#import "DataManager.h"
#import "AppDelegate.h"

@interface TUserManager : DataManager

- (TUser*) getLatestUser;

@end
