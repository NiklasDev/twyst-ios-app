//
//  BaseFollowsViewController.h
//  Twyst
//
//  Created by Nahuel Morales on 8/5/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "HeaderLabel.h"
#import "UserWebService.h"
#import "BaseViewController.h"
#import "FriendManageService.h"

@interface BaseFollowsViewController : BaseViewController {
    FriendManageService *_friendService;
}

@property (nonatomic, retain) OCUser *user;
@property (weak, nonatomic) IBOutlet HeaderLabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelHelp;

- (id)initWithOCUser:(OCUser*)user;

@end
