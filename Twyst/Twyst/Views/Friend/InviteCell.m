//
//  InviteCell.m
//  Twyst
//
//  Created by Niklas Ahola on 8/31/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "FriendManageService.h"
#import "ContactManageService.h"

#import "InviteCell.h"
#import "FullProfileImageView.h"

@interface InviteCell()  {
    
}

@end

@implementation InviteCell

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
    return @"InviteCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"InviteCell"];
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
            
            CGRect frame = self.content_.frame;
            UIView *rollover = [[UIView alloc] initWithFrame:frame];
            rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
            self.selectedBackgroundView = rollover;
        }
    }
    
    return self;
}

#pragma mark configure friend cell
- (void)configureInviteCell:(Contact*)contact {

    _labelRealname.text = contact.fullName;
    
    if (![[ContactManageService sharedInstance] isInvitedAlready:contact.phone]) {
        _imageStatus.image = [UIImage imageNamedForDevice:@"ic-cell-people-invite"];
//        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        _imageStatus.image = [UIImage imageNamedForDevice:@"ic-cell-people-sent"];
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
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
