//
//  ContactCell.h
//  Twyst
//
//  Created by Niklas Ahola on 8/31/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Contact.h"

@interface ContactCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *content_;

@property (strong, nonatomic) IBOutlet UIImageView *imageProfile;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelRealname;
@property (strong, nonatomic) IBOutlet UIImageView *imageMark;
@property (strong, nonatomic) IBOutlet UIButton *btnAction;
@property (retain, nonatomic) NSString *profileName;

+ (CGFloat)heightForCell;
+ (NSString *)reuseIdentifier;
+ (NSString *)nibName;

- (void)configureFriendCell:(NSDictionary*)friendDic index:(NSInteger)index target:(id)target selector:(SEL)selector;
- (void)configureFriendMessageCell:(NSDictionary*)friendDic alreadySentRequest:(BOOL)alreadySentRequest;
- (void)configureContactCell:(Contact*)contact;

@end
