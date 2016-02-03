//
//  FollowersViewController.m
//  Twyst
//
//  Created by Nahuel Morales on 8/5/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FollowersViewController.h"
#import "AppDelegate.h"

#import "UserWebService.h"
#import "FriendManageService.h"

@interface FollowersViewController ()

@end

@implementation FollowersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labelTitle.text = @"Followers";
    self.labelHelp.text = @"No followers yet.";
}

- (void)actionLoadArrayPeople:(void(^)(NSArray*))completion {
    if (self.user.Id == [Global getOCUser].Id) {
        [_friendService actionGetFollowers:^(NSArray *followers) {
            [_friendService actionGetReceivedRequests:^(NSArray *requests) {
                if (followers && requests) {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObjectsFromArray:followers];
                    [array addObjectsFromArray:requests];
                    completion(array);
                } else {
                    completion(nil);
                }
            }];
        }];
    }
    else {
        [[UserWebService sharedInstance] getUsersFollower:self.user.Id
                                               completion:^(NSArray *followers) {
                                                   if (followers) {
                                                       completion(followers);
                                                   }
                                                   else {
                                                       completion(nil);
                                                   }
                                               }];
    }
}

@end
