//
//  AddPeopleCell.m
//  Twyst
//
//  Created by Niklas Ahola on 9/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "AddPeopleCell.h"

@interface AddPeopleCell()  {
    
}

@end

@implementation AddPeopleCell

+ (CGFloat)heightForCell {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6Plus:
            return 66.0f;
            break;
        default:
            return 60.0f;
            break;
    }
}

+ (NSString *)reuseIdentifier {
    return @"AddPeopleCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"AddPeopleCell"];
}

- (id)init {
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    NSString * identifier = [[self class] reuseIdentifier];
    
    if ((self = [super initWithStyle:style reuseIdentifier:identifier])) {
        NSString * nibName = [[self class] nibName];
        if (nibName) {
            [[NSBundle mainBundle] loadNibNamed:nibName
                                          owner:self
                                        options:nil];
            NSAssert(self.content_ != nil, @"NIB file loaded but content property not set");
            [self.contentView addSubview:self.content_];
            self.contentView.frame = self.content_.frame;
            
            self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2;
            self.imageProfile.layer.masksToBounds = YES;
            
//            CGRect frame = self.content_.frame;
//            UIView *rollover = [[UIView alloc] initWithFrame:frame];
//            rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
//            self.selectedBackgroundView = rollover;
        }
    }
    
    return self;
}

- (NSAttributedString*)selectAllString {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            return [NSString formattedString:@[@"Select All"] fonts:@[[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.4]] colors:@[Color(103, 39, 199)]];
            break;
        case DeviceTypePhone6Plus:
            return [NSString formattedString:@[@"Select All"] fonts:@[[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.8]] colors:@[Color(103, 39, 199)]];
            break;
        default:
            return [NSString formattedString:@[@"Select All"] fonts:@[[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]] colors:@[Color(103, 39, 199)]];
            break;
    }
}

#pragma mark - configure select all cell
- (void)configureSelectAllCell:(BOOL)selected  enable:(BOOL)enable {
    // set avatar image
    _imageProfile.image = [UIImage imageNamedContentFile:@"ic-cell-select-all"];
    
    self.labelSelectAll.hidden = NO;
    self.labelUsername.hidden = YES;
    self.labelRealname.hidden = YES;
    
    // set selection image
    NSString *imageName = nil;
    if (enable) {
        imageName = selected ? @"ic-cell-share-all-on" : @"ic-cell-share-all-off";
    }
    else {
        imageName = @"ic-cell-share-all-dis";
    }
    _imageMark.image = [UIImage imageNamedContentFile:imageName];
    
    self.selectionStyle = enable ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    
    selected = enable ? selected : NO;
    self.backgroundColor = selected ? Color(250, 250, 252) : [UIColor whiteColor];
}

#pragma mark - configure friend cell
- (void)configureFriendCellWithDictionary:(NSDictionary*)requestDic
                           selectedStatus:(BOOL)selected
                              isStringger:(BOOL)isStringger {
    NSDictionary *friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
    NSString *profilePicName = [friendDic objectForKey:@"ProfilePicName"];
    [_imageProfile setImageWithURL:ProfileURL(profilePicName) placeholderImage:placeholder];
    
    self.labelSelectAll.hidden = YES;
    self.labelUsername.hidden = NO;
    self.labelRealname.hidden = NO;
    
    NSString *userName = [friendDic objectForKey:@"UserName"];
    NSString *firstName = [friendDic objectForKey:@"FirstName"];
    NSString *lastName = [friendDic objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    NSString *imageName = nil;
    if (isStringger) {
        imageName = @"ic-cell-share-friend-dis";
    }
    else {
        imageName = (selected == YES) ? @"ic-cell-share-friend-on" : @"ic-cell-share-friend-off";
    }
    _imageMark.image = [UIImage imageNamedContentFile:imageName];
    
    self.selectionStyle = isStringger ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    selected = isStringger ? NO : selected;
    self.backgroundColor = selected ? Color(250, 250, 252) : [UIColor whiteColor];
}

- (void) layoutSubviews {
    
}

- (void)awakeFromNib
{
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
