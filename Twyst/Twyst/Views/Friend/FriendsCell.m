//
//  FriendsCell.m
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "FriendManageService.h"

#import "FriendsCell.h"
#import "AppDelegate.h"
#import "FullProfileImageView.h"

@interface FriendsCell()  {
    
}

@end

@implementation FriendsCell

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
    return @"FriendsCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"FriendsCell"];
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
- (void)configureFriendCell:(NSDictionary *)requestDic index:(NSInteger)index target:(id)target selector:(SEL)selector {
    NSDictionary *friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
    
    NSString *profilePicName = [friendDic objectForKey:@"ProfilePicName"];
    [self actionSetProfile:profilePicName];
    
    NSString *userName = [friendDic objectForKey:@"UserName"];
    NSString *firstName = [friendDic objectForKey:@"FirstName"];
    NSString *lastName = [friendDic objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-check"];
    
    _btnAction.hidden = NO;
    _btnAction.tag = index;
    [_btnAction removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [_btnAction addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

#pragma mark configure result cell
- (void)configureResultCell:(NSDictionary *)resultDic index:(NSInteger)index target:(id)target selector:(SEL)selector {
    
    NSString *profilePicName = [resultDic objectForKey:@"ProfilePicName"];
    [self actionSetProfile:profilePicName];
    
    NSString *userName = [resultDic objectForKey:@"UserName"];
    NSString *firstName = [resultDic objectForKey:@"FirstName"];
    NSString *lastName = [resultDic objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    _btnAction.tag = index;
    [_btnAction removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    NSNumber *userId = [resultDic objectForKey:@"Id"];
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
        case UserRelationTypeSelf:
            _imageMark.image = nil;
            _btnAction.hidden = YES;
            break;
        default:
            break;
    }
    self.selectionStyle = (relationShip == UserRelationTypeSelf) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
}

- (void)configureFollowerCell:(NSDictionary*)resultDic index:(NSInteger)index target:(id)target selector:(SEL)selector isApproved:(BOOL)isApproved {
    NSString *profilePicName = [resultDic objectForKey:@"ProfilePicName"];
    [self actionSetProfile:profilePicName];
    
    NSString *userName = [resultDic objectForKey:@"UserName"];
    NSString *firstName = [resultDic objectForKey:@"FirstName"];
    NSString *lastName = [resultDic objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    _btnAction.tag = index;
    [_btnAction removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    if (!isApproved) {
        _imageMark.image = [UIImage imageNamedForDevice:@"ic-cell-friend-waiting"];
        _btnAction.hidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else {
        NSNumber *userId = [resultDic objectForKey:@"Id"];
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
            case UserRelationTypeSelf:
                _imageMark.image = nil;
                _btnAction.hidden = YES;
                break;
            default:
                break;
        }
        self.selectionStyle = (relationShip == UserRelationTypeSelf) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    }
}

- (void)configureSearchResultCell:(NSDictionary*)resultDic {
    NSString *profilePicName = [resultDic objectForKey:@"ProfilePicName"];
    [self actionSetProfile:profilePicName];
    
    NSString *userName = [resultDic objectForKey:@"UserName"];
    NSString *firstName = [resultDic objectForKey:@"FirstName"];
    NSString *lastName = [resultDic objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    _imageMark.image = nil;
    _btnAction.hidden = YES;
    [_btnAction removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

#pragma mark - configure request cell
- (void)configureRequestCell:(NSDictionary *)requestDic {
    OCUser *user = [Global getOCUser];
    long ownerId = [[requestDic objectForKey:@"OwnerId"] longValue];
    NSDictionary *friendDic = nil;
    BOOL isSentRequest = YES;
    if (user.Id == ownerId) {
        friendDic = [requestDic objectForKey:@"OCUser1_friendid"];
    }
    else {
        friendDic = [requestDic objectForKey:@"OCUser_ownerid"];
        isSentRequest = NO;
    }
    
    _btnAction.hidden = YES;
    
    NSString *profilePicName = [friendDic objectForKey:@"ProfilePicName"];
    [self actionSetProfile:profilePicName];
    
    NSString *userName = [friendDic objectForKey:@"UserName"];
    NSString *firstName = [friendDic objectForKey:@"FirstName"];
    NSString *lastName = [friendDic objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    NSString *imageName = isSentRequest ? @"ic-cell-friend-waiting" : @"ic-cell-friend-plus";
    _imageMark.image = [UIImage imageNamedForDevice:imageName];
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
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
