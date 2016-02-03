//
//  ShareFriendCell.h
//  Twyst
//
//  Created by Niklas Ahola on 8/14/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareFriendCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UILabel *labelRealname;
@property (weak, nonatomic) IBOutlet UIImageView *imageMark;
@property (weak, nonatomic) IBOutlet UIImageView *imageSeparator;

+ (CGFloat)heightForCell;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)configureFriendCellWithDictionary:(NSDictionary*)friendDic
                           selectedStatus:(BOOL)selected;

- (void)configureAllFriendsCell:(BOOL)selected;

@end
