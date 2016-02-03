//
//  TwystPeopleViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "HeaderLabel.h"
#import "UserWebService.h"
#import "BaseViewController.h"
#import "FriendManageService.h"

@interface TwystPeopleViewController : BaseViewController {
    FriendManageService *_friendService;
}

@property (nonatomic, assign) long twystId;
@property (nonatomic, assign) NSInteger twysterCount;

- (id)initWithTwystId:(long)twystId;

@end
