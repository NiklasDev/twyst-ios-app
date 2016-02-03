//
//  FollowingViewController.m
//  Twyst
//
//  Created by Wang Fang on 3/24/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FollowingViewController.h"
#import "AppDelegate.h"

#import "UserWebService.h"
#import "FriendManageService.h"

@interface FollowingViewController ()

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labelTitle.text = @"Following";
    self.labelHelp.text = @"Following no one.";
}

- (void)actionLoadArrayPeople:(void(^)(NSArray*))completion {
    if (self.user.Id == [Global getOCUser].Id) {
        [_friendService actionGetFollowing:^(NSArray *friends) {
            [_friendService actionGetSentRequests:^(NSArray *requests) {
                if (friends && requests) {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObjectsFromArray:friends];
                    [array addObjectsFromArray:requests];
                    completion(array);
                } else {
                    completion(nil);
                }
            }];
        }];
    }
    else {
        [[UserWebService sharedInstance] getUsersFollowing:self.user.Id
                                                completion:^(NSArray *following) {
                                                    if (following) {
                                                        completion(following);
                                                    }
                                                    else {
                                                        completion(nil);
                                                    }
                                                }];
    }
}

@end
