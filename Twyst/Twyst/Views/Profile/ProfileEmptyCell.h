//
//  ProfileEmptyCell.h
//  Twyst
//
//  Created by Niklas Ahola on 2/19/15.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WDActivityIndicator.h"

@interface ProfileEmptyCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;

@property (weak, nonatomic) IBOutlet UIView *viewFriendNoPosts;
@property (weak, nonatomic) IBOutlet UIView *viewFriendPrivate;
@property (weak, nonatomic) IBOutlet UIView *viewProfileNoPosts;
@property (weak, nonatomic) IBOutlet UIView *viewLoadingPosts;
@property (weak, nonatomic) IBOutlet WDActivityIndicator *activityIndicator;

+ (CGFloat)heightForCell:(CGFloat)tableHeaderViewHeight;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)showProfileNoPosts:(CGFloat)tableHeaderViewHeight;
- (void)showFriendNoPosts:(CGFloat)tableHeaderViewHeight;
- (void)showFriendPrivate:(CGFloat)tableHeaderViewHeight;
- (void)showProfileLoading:(CGFloat)tableHeaderViewHeight;

@end
