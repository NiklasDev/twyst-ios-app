//
//  InviteCell.h
//  Twyst
//
//  Created by Niklas Ahola on 8/31/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Contact.h"

@interface InviteCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;

@property (weak, nonatomic) IBOutlet UILabel *labelRealname;
@property (weak, nonatomic) IBOutlet UIImageView *imageStatus;

+ (CGFloat)heightForCell;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)configureInviteCell:(Contact*)contact;

@end
