//
//  ContactCell.m
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

#import "ContactCell.h"
#import "FullProfileImageView.h"

@interface ContactCell()  {
    
}

@end

@implementation ContactCell

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
    return @"ContactCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"ContactCell"];
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
            
            CGRect frame = self.content_.frame;
            UIView *rollover = [[UIView alloc] initWithFrame:frame];
            rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
            self.selectedBackgroundView = rollover;
        }
    }
    
    return self;
}

#pragma mark configure friend cell
- (void)configureFriendCell:(NSDictionary*)friendDic index:(NSInteger)index target:(id)target selector:(SEL)selector {
    
    NSString *profilePicName = [friendDic objectForKey:@"ProfilePicName"];
    [self actionSetProfile:profilePicName];
        
    NSString *userName = [friendDic objectForKey:@"UserName"];
    NSString *firstName = [friendDic objectForKey:@"FirstName"];
    NSString *lastName = [friendDic objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    _btnAction.tag = index;
    [_btnAction removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    NSNumber *userId = [friendDic objectForKey:@"Id"];
    UserRelationType relationShip = [[FriendManageService sharedInstance] getUserRelationTypeShip:userId];
    
    switch (relationShip) {
        case UserRelationTypeFriend:
            _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-check"];
            _btnAction.hidden = NO;
            [_btnAction addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            break;
        case UserRelationTypeNone:
            _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-plus"];
            _btnAction.hidden = NO;
            [_btnAction addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            break;
        case UserRelationTypeRequested:
            _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-waiting"];
            _btnAction.hidden = YES;
            break;
        case UserRelationTypeReceived:
            _imageMark.image = [UIImage imageNamedContentFile:@"ic-cell-friend-plus"];
            _btnAction.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)configureFriendMessageCell:(NSDictionary*)friendDic alreadySentRequest:(BOOL)alreadySentRequest {
    [self configureFriendCell:friendDic index:0 target:nil selector:nil];
    _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-plus"];
    _btnAction.hidden = YES;
    if (!alreadySentRequest) {
        _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-mail"];
    }
    else {
        _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-mail-sent"];
    }
}

- (void)configureContactCell:(Contact*)contact {
    [self actionSetProfile:nil];
    
    _labelUsername.text = contact.fullName;
    _labelRealname.text = @"Invite";
    
    _btnAction.hidden = YES;
    if (![[ContactManageService sharedInstance] isInvitedAlready:contact.phone]) {
        _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-mail"];
    }
    else {
        _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-mail-sent"];
    }
}

#pragma mark -
- (void)actionSetProfile:(NSString*)profilePicName {
    if (IsNSStringValid(profilePicName)) {
        self.profileName = [NSString stringWithString:profilePicName];
    }
    else {
        self.profileName = nil;
    }
    
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
    [_imageProfile setImageWithURL:ProfileURL(profilePicName) placeholderImage:placeholder];
}

- (IBAction)handleTapProfile {
    if (IsNSStringValid(self.profileName)) {
        FullProfileImageView *fullImageView = [[FullProfileImageView alloc] initWithProfileName:self.profileName];
        [fullImageView showInView:[AppDelegate sharedInstance].window];
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
