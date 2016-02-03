//
//  HomeTwystCell.m
//  Twyst
//
//  Created by Niklas Ahola on 8/13/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "FlipframeFileService.h"

#import "TTwystOwnerManager.h"
#import "TSavedTwystManager.h"
#import "FFlipframeSavedLibrary.h"

#import "HomeTwystCell.h"

@interface HomeTwystCell()  {
    
}

@end

@implementation HomeTwystCell

+ (CGFloat)lineSpace {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
        {
            return 1;
        }
            break;
        case DeviceTypePhone6Plus:
        {
            return 1;
        }
            break;
        default:
        {
            return 1;
        }
            break;
    }
}

+ (CGFloat)heightForCell:(Twyst*)twyst {
    DeviceType type = [Global deviceType];
    CGFloat lineSpace = [HomeTwystCell lineSpace];
    switch (type) {
        case DeviceTypePhone6:
        {
            CGSize size = [twyst.Caption stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.6] lineSpace:lineSpace constrainedToWidth:256];
            return MAX(60, 41 + size.height);
        }
            break;
        case DeviceTypePhone6Plus:
        {
            CGSize size = [twyst.Caption stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0] lineSpace:lineSpace constrainedToWidth:280];
            return MAX(66, 45 + size.height);
        }
            break;
        default:
        {
            CGSize size = [twyst.Caption stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15] lineSpace:lineSpace constrainedToWidth:200];
            return MAX(60, 42 + size.height);
        }
            break;
    }
}

+ (CGFloat)heightForSavedCell:(FFlipframeSavedLibrary*)twyst {
    DeviceType type = [Global deviceType];
    CGFloat lineSpace = [HomeTwystCell lineSpace];
    switch (type) {
        case DeviceTypePhone6:
        {
            CGSize size = [twyst.caption stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.6] lineSpace:lineSpace constrainedToWidth:256];
            return MAX(60, 41 + size.height);
        }
            break;
        case DeviceTypePhone6Plus:
        {
            CGSize size = [twyst.caption stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0] lineSpace:lineSpace constrainedToWidth:280];
            return MAX(66, 45 + size.height);
        }
            break;
        default:
        {
            CGSize size = [twyst.caption stringSizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15] lineSpace:lineSpace constrainedToWidth:200];
            return MAX(60, 42 + size.height);
        }
            break;
    }
}

+ (NSString *)reuseIdentifier {
    return @"HomeTwystCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"HomeTwystCell"];
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
            self.imageThumb.layer.cornerRadius = 4.0f;
            self.imageThumb.layer.masksToBounds = YES;
            
            self.labelTime.font = [UIFont fontWithName:@"Mission Script" size:self.labelTime.font.pointSize];
            self.labelTime.transform = CGAffineTransformMakeScale(1.3, 1);
            
            CGRect frame = self.content_.frame;
            UIView *rollover = [[UIView alloc] initWithFrame:frame];
            rollover.backgroundColor = ColorRGBA(115, 103, 141, 0.24);
            self.selectedBackgroundView = rollover;
        }
    }
    return self;
}

- (void)configureCell:(Twyst*)twyst {
    self.twystId = twyst.Id;
    
    // set twyst theme
    NSAttributedString *themeAttrString = [NSString formattedString:@[twyst.Caption] fonts:@[self.labelTheme.font] colors:@[self.labelTheme.textColor] lineSpace:[HomeTwystCell lineSpace]];
    self.labelTheme.attributedText = themeAttrString;
    
    CGRect themeFrame = self.labelTheme.frame;
    CGRect rect = [themeAttrString boundingRectWithSize:(CGSize){themeFrame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    self.labelTheme.frame = CGRectMake(themeFrame.origin.x,
                                       themeFrame.origin.y,
                                       themeFrame.size.width,
                                       ceilf(rect.size.height));
    
    // set twyst thumbnail
    [self setThumbnailImage:twyst];
    
    // set creator / passer avatar / status
    if (twyst.ownerId > 1) {
        
        NSString *senderName = nil;
        NSArray *passer = [twyst.PassedBy componentsSeparatedByString:@","];
        if (passer.count == 0 || (passer.count > 0 && [[passer firstObject] isEqualToString:twyst.owner.UserName])) {   //creator
            senderName = [NSString stringWithFormat:@"%@ ", twyst.owner.UserName];
            self.imagePassArrow.hidden = YES;
            UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
            [self.imageAvatar setImageWithURL:ProfileURL(twyst.owner.ProfilePicName) placeholderImage:placeholder];
        }
        else { //passer
            senderName = [NSString stringWithFormat:@"%@ ", [passer firstObject]];
            self.imagePassArrow.hidden = NO;
            UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
            [self.imageAvatar setImageWithURL:ProfileURL([passer lastObject]) placeholderImage:placeholder];
        }

        NSString *timeString = [[Global getInstance] timeStringWithDate:twyst.ActionTimeStamp];
        self.labelStatus.text = senderName;
        self.labelTime.text = timeString;
        
        // layout time and pass arrow
        CGRect timeRect = [timeString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:self.labelTime.font} context:nil];
        CGRect nameRect = [senderName boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:self.labelStatus.font} context:nil];
        
        CGRect frame = self.labelTime.frame;
        frame.origin.x = self.labelStatus.frame.origin.x + nameRect.size.width;
        self.labelTime.frame = frame;
        
        if (!self.imagePassArrow.hidden) {
            frame = self.imagePassArrow.frame;
            frame.origin.x = self.labelStatus.frame.origin.x + nameRect.size.width + timeRect.size.width * 1.3 + 6;
            self.imagePassArrow.frame = frame;
        }
    }
    else {
        self.imageAvatar.image = [UIImage imageNamedContentFile:@"ic-admin-avatar"];
        self.labelStatus.text = @"TeamTwyst";
        self.labelTime.text = @"";
        self.imagePassArrow.hidden = YES;
    }
    
    // layout subviews
    CGFloat height = [[self class] heightForCell:twyst];
    [self.content_ setFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
}

- (void)configureSavedCell:(FFlipframeSavedLibrary*)twyst {
    
    OCUser *user = [Global getOCUser];
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
    [self.imageAvatar setImageWithURL:ProfileURL(user.ProfilePicName) placeholderImage:placeholder];
    
    NSAttributedString *themeAttrString = [NSString formattedString:@[twyst.caption] fonts:@[self.labelTheme.font] colors:@[self.labelTheme.textColor] lineSpace:[HomeTwystCell lineSpace]];
    self.labelTheme.attributedText = themeAttrString;
    
    CGRect themeFrame = self.labelTheme.frame;
    CGRect rect = [themeAttrString boundingRectWithSize:(CGSize){themeFrame.size.width, CGFLOAT_MAX}
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
    self.labelTheme.frame = CGRectMake(themeFrame.origin.x,
                                       themeFrame.origin.y,
                                       themeFrame.size.width,
                                       ceilf(rect.size.height));
    
    
    self.labelStatus.text = @"Saved";
    self.labelTime.text = @"";
    self.imageThumb.hidden = NO;
    self.imageThumb.image = twyst.imageThumb;
    self.imagePassArrow.hidden = YES;
    
    // layout subviews
    CGFloat height = [[self class] heightForSavedCell:twyst];
    [self.content_ setFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
}

- (void)setThumbnailImage:(Twyst*)stringg {
    NSURL *fileURL = TwystThumbURL(stringg.Id);
    [self.imageThumb setImageWithURL:fileURL placeholderImage:nil];
}

- (NSAttributedString*)statusString:(Twyst*)twyst senderName:(NSString*)senderName {
    CGFloat fontSize = self.labelStatus.font.pointSize;
    NSString *timeString = [[Global getInstance] timeStringWithDate:twyst.ActionTimeStamp];
    NSAttributedString *attrString = [NSString formattedString:@[senderName, @" ", timeString]
                                                         fonts:@[[UIFont fontWithName:@"HelveticaNeue" size:fontSize],
                                                                 [UIFont fontWithName:@"HelveticaNeue" size:fontSize],
                                                                 [UIFont fontWithName:@"Mission Script" size:fontSize]]
                                                        colors:nil];
    return attrString;
}

- (void)updateCell:(Twyst*)twyst {
    
}

@end
