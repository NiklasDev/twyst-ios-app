//
//  ShareFriendCell.m
//  Twyst
//
//  Created by Niklas Ahola on 8/14/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "ShareFriendCell.h"
#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

@interface ShareFriendCell()  {
    
}

@end

@implementation ShareFriendCell

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
    return @"ShareFriendCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"ShareFriendCell"];
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
//            
//            CGRect frame = self.content_.frame;
//            UIView *rollover = [[UIView alloc] initWithFrame:frame];
//            rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
//            self.selectedBackgroundView = rollover;
        }
    }
    
    return self;
}

- (void)configureAllFriendsCell:(BOOL)selected {
    _imageProfile.image = [UIImage imageNamedContentFile:@"ic-cell-select-all"];
    
    _labelRealname.text = @"Followers";
    _labelUsername.text = @"Send to everyone";
    
    CGFloat fontSize = _labelRealname.font.pointSize;
    NSString *fontName = selected ? @"HelveticaNeue-Bold" : @"HelveticaNeue-Medium";
    _labelRealname.font = [UIFont fontWithName:fontName size:fontSize];
    
    NSString *imageName = (selected == YES) ? @"ic-cell-share-all-on" : @"ic-cell-share-all-off";
    _imageMark.image = [UIImage imageNamedContentFile:imageName];
    
    _imageSeparator.hidden = YES;
    
    self.backgroundColor = selected ? Color(250, 250, 252) : [UIColor whiteColor];
}

- (void)configureFriendCellWithDictionary:(NSDictionary*)friendDic
                           selectedStatus:(BOOL)selected {
    
    NSDictionary *friend = [friendDic objectForKey:@"OCUser1_friendid"];
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
    NSString *profilePicName = [friend objectForKey:@"ProfilePicName"];
    [_imageProfile setImageWithURL:ProfileURL(profilePicName) placeholderImage:placeholder];

    NSString *userName = [friend objectForKey:@"UserName"];
    NSString *firstName = [friend objectForKey:@"FirstName"];
    NSString *lastName = [friend objectForKey:@"LastName"];
    _labelUsername.text = userName;
    _labelRealname.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    CGFloat fontSize = _labelRealname.font.pointSize;
    NSString *fontName = selected ? @"HelveticaNeue-Bold" : @"HelveticaNeue-Medium";
    _labelRealname.font = [UIFont fontWithName:fontName size:fontSize];
    
    NSString *imageName = (selected == YES) ? @"ic-cell-share-friend-on" : @"ic-cell-share-friend-off";
    _imageMark.image = [UIImage imageNamedContentFile:imageName];
    
    _imageSeparator.hidden = NO;
    
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
