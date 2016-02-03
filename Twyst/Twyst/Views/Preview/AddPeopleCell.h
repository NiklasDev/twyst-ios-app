//
//  AddPeopleCell.h
//  Twyst
//
//  Created by Niklas Ahola on 9/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPeopleCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;

@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UILabel *labelRealname;
@property (weak, nonatomic) IBOutlet UILabel *labelSelectAll;
@property (weak, nonatomic) IBOutlet UIImageView *imageMark;

+ (CGFloat)heightForCell;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)configureSelectAllCell:(BOOL)selected
                        enable:(BOOL)enable;

- (void)configureFriendCellWithDictionary:(NSDictionary*)requestDic
                           selectedStatus:(BOOL)selected
                              isStringger:(BOOL)isStringger;

@end
