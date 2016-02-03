//
//  TwystNewsCell.m
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "TTwystNews.h"
#import "TTwystOwnerManager.h"
#import "TStillframeRegular.h"
#import "TSavedTwystManager.h"

#import "FlipframeFileService.h"

#import "StringgNewsCell.h"

@interface StringgNewsCell()  {
    
}

@end

@implementation StringgNewsCell

+ (CGFloat)heightForCell:(TTwystNews*)news {
    NSAttributedString *attrString = [StringgNewsCell attributedStringgWithNews:news];
    CGRect rect = [attrString boundingRectWithSize:(CGSize){[StringgNewsCell newsWidth], CGFLOAT_MAX}
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                           context:nil];
    CGFloat textHeight = ceilf(rect.size.height);
    
    DeviceType type = [Global deviceType];
    CGFloat height = 0;
    switch (type) {
        case DeviceTypePhone6:
            height = MAX(60, 21 + textHeight);
            break;
        case DeviceTypePhone6Plus:
            height = MAX(66, 24 + textHeight);
            break;
        default:
            height = MAX(60, 21 + textHeight);
            break;
    }
    return height;
}

+ (NSString *)reuseIdentifier {
    return @"StringgNewsCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"StringgNewsCell"];
}

+ (NSAttributedString*)attributedStringgWithNews:(TTwystNews*)news {
    NSString *nameString = [StringgNewsCell nameStringg:news];
    NSString *statusString = [StringgNewsCell statusString:news];
    NSString *timeString = [StringgNewsCell timeString:news];
    
    DeviceType type = [Global deviceType];
    if (type == DeviceTypePhone6) {
        return [NSString formattedString:@[nameString, statusString, timeString] fonts:@[[UIFont fontWithName:@"HelveticaNeue-Bold" size:15], [UIFont fontWithName:@"HelveticaNeue" size:15], [UIFont fontWithName:@"HelveticaNeue" size:15]] colors:@[Color(49, 47, 60), Color(47, 47, 47), Color(197, 187, 218)] lineSpace:4];
    }
    else if (type == DeviceTypePhone6Plus) {
        return [NSString formattedString:@[nameString, statusString, timeString] fonts:@[[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.3], [UIFont fontWithName:@"HelveticaNeue" size:16.3], [UIFont fontWithName:@"HelveticaNeue" size:16.3]] colors:@[Color(49, 47, 60), Color(47, 47, 47), Color(197, 187, 218)] lineSpace:4];
    }
    else {
        return [NSString formattedString:@[nameString, statusString, timeString] fonts:@[[UIFont fontWithName:@"HelveticaNeue-Bold" size:15], [UIFont fontWithName:@"HelveticaNeue" size:15], [UIFont fontWithName:@"HelveticaNeue" size:15]] colors:@[Color(49, 47, 60), Color(47, 47, 47), Color(197, 187, 218)] lineSpace:4];
    }
}

+ (CGFloat)newsWidth {
    DeviceType type = [Global deviceType];
    CGFloat width = 0;
    switch (type) {
        case DeviceTypePhone6:
            width = 258.0f;
            break;
        case DeviceTypePhone6Plus:
            width = 286.0f;
            break;
        default:
            width = 204.0f;
            break;
    }
    return width;
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
            
            self.imageAvatar.layer.cornerRadius = self.imageAvatar.frame.size.width / 2;
            self.imageAvatar.layer.masksToBounds = YES;
            self.imageThumb.layer.cornerRadius = 4;
            self.imageThumb.layer.masksToBounds = YES;
            
            CGRect frame = self.content_.frame;
            UIView *rollover = [[UIView alloc] initWithFrame:frame];
            rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
            self.selectedBackgroundView = rollover;
        }
    }
    return self;
}

- (void)configureCell:(TTwystNews*)news {
    long sender = [news.senderId longValue];
    TTwystOwner *tOwner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:sender];
    UIImage *profilePlaceHolder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
    [_imageAvatar setImageWithURL:ProfileURL(tOwner.profilePicName) placeholderImage:profilePlaceHolder];
    
    NSAttributedString *attrString = [StringgNewsCell attributedStringgWithNews:news];
    self.labelDesc.attributedText = attrString;
    
    [self setThumbnailImage:news completion:^(UIImage *image) {}];
    
    if ([news.isUnread boolValue]) {
        self.content_.backgroundColor = Color(249, 248, 251);
    }
    else {
        self.content_.backgroundColor = Color(255, 255, 255);
    }
    
    // layout view
    [self adjustSubViews:news];
}

- (void) adjustSubViews:(TTwystNews*)news {
    CGFloat height = [[self class] heightForCell:news];
    self.content_.frame = CGRectMake(0, 0, SCREEN_WIDTH, height);
    self.contentView.frame = self.content_.frame;

    self.imageSeparator.center = CGPointMake(self.imageSeparator.center.x, height - 0.5);
    
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            if (height > 60) {
                self.labelDesc.frame = CGRectMake(59, 0, [[self class] newsWidth], height - 4);
            }
            else {
                self.labelDesc.frame = CGRectMake(59, 0, [[self class] newsWidth], height);
            }
            break;
        case DeviceTypePhone6Plus:
            if (height > 66) {
                self.labelDesc.frame = CGRectMake(65, 0, [[self class] newsWidth], height - 6);
            }
            else {
                self.labelDesc.frame = CGRectMake(65, 0, [[self class] newsWidth], height);
            }
            break;
        default:
            if (height > 60) {
                self.labelDesc.frame = CGRectMake(60, 0, [[self class] newsWidth], height - 4);
            }
            else {
                self.labelDesc.frame = CGRectMake(60, 0, [[self class] newsWidth], height);
            }
            break;
    }
}

+ (NSString*)nameStringg:(TTwystNews*)news {
    NSString *type = news.type;
    if ([type isEqualToString:@"comment"]) {
        NSInteger commentCount = [news.commentCount integerValue];
        if (commentCount == 1) {
            return [NSString stringWithFormat:@"%ld comment", (long)commentCount];
        }
        else {
            return [NSString stringWithFormat:@"%ld comments", (long)commentCount];
        }
    }
    else {
        return news.senderName;
    }
}

+ (NSString*)statusString:(TTwystNews*)news {
    NSString *type = news.type;
    long twystOwnerId = [news.twystOwnerId longValue];
    OCUser *user = [Global getOCUser];
    NSString *owner = (twystOwnerId == user.Id) ? @"your" : @"this";
    
    NSString *status = nil;
    if ([type isEqualToString:@"Like"]) {
        status = [NSString stringWithFormat:@" likes %@ twyst. ", owner];
    }
    else if ([type isEqualToString:@"comment"]) {
        status = [NSString stringWithFormat:@" on %@ twyst \"%@\" ", owner, news.twystCaption];
    }
    else if ([type isEqualToString:@"Pass"]) {
        status = @" passed you a twyst ";
    }
    else if ([type isEqualToString:@"Reply"]) {
        status = [NSString stringWithFormat:@" replied to %@ twyst. ", owner];
    }
    else if ([type isEqualToString:@"Follow"]) {
        status = @" started following you. ";
    }
    return status;
}

+ (NSString*)timeString:(TTwystNews*)news {
    NSString *Created = news.created;
    return [[Global getInstance] timeStringWithDateString:Created];
}

- (void)setThumbnailImage:(TTwystNews*)news completion:(void(^)(UIImage*))completion {
    if ([news.type isEqualToString:@"Follow"]) {
        self.imageThumb.contentMode = UIViewContentModeCenter;
        self.imageThumb.image = [UIImage imageNamedForDevice:@"ic-notifications-follow"];
    }
    else {
        long twystId = [news.twystId longValue];
        self.imageThumb.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageThumb setImageWithURL:TwystThumbURL(twystId) placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            completion(image);
        }];
    }
}

@end
