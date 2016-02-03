//
//  EmptyDataCell.h
//  Twyst
//
//  Created by Niklas Ahola on 2/19/15.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyDataCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;

@property (weak, nonatomic) IBOutlet UIView *viewFriendPending;
@property (weak, nonatomic) IBOutlet UIView *viewFriendNoStringg;
@property (weak, nonatomic) IBOutlet UIView *viewFriendPrivate;
@property (weak, nonatomic) IBOutlet UIView *viewFriendAccept;

@property (weak, nonatomic) IBOutlet UIView *viewHomeFollowing;
@property (weak, nonatomic) IBOutlet UIView *viewHomePrivate;
@property (weak, nonatomic) IBOutlet UIView *viewHomeSaved;

+ (CGFloat)heightForCell;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)showFriendPending;
- (void)showFriendNoPosts;
- (void)showFriendPrivate;
- (void)showFriendAccept;

- (void)showHomeFollowing;
- (void)showHomePrivate;
- (void)showHomeSaved;

@end
