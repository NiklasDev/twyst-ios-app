//
//  ProfileFeedCell.m
//  Twyst
//
//  Created by Wang Fang on 3/20/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "ContactManageService.h"
#import "FlipframeFileService.h"

#import "ExtraTagButton.h"
#import "ProfileFeedCell.h"

@interface ProfileFeedCell() {
    
}

@end

@implementation ProfileFeedCell

+ (CGFloat)heightForCell {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            return 227;
            break;
        case DeviceTypePhone6Plus:
            return 250;
            break;
        default:
            return 192;
            break;
    }
}

+ (NSString *)reuseIdentifier {
    return @"ProfileFeedCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"ProfileFeedCell"];
}

- (id)initWithTarget:(id)target selector:(SEL)selector {
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
            
            self.rightContainer.layer.cornerRadius = 3;
            self.rightContainer.layer.masksToBounds = YES;
            self.rightContainer.layer.borderWidth = 1;
            self.rightContainer.layer.borderColor = Color(196, 196, 196).CGColor;
            self.rightContainer.clipsToBounds = YES;
            
            self.leftContainer.layer.cornerRadius = 3;
            self.leftContainer.layer.masksToBounds = YES;
            self.leftContainer.layer.borderWidth = 1;
            self.leftContainer.layer.borderColor = Color(196, 196, 196).CGColor;
            self.leftContainer.clipsToBounds = YES;
            
            UIButton *rightButton = (UIButton*)[self.rightContainer viewWithTag:500];
            [rightButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            UIButton *leftButton = (UIButton*)[self.leftContainer viewWithTag:500];
            [leftButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *rightTimeLabel = (UILabel*)[self.rightContainer viewWithTag:400];
            rightTimeLabel.font = [UIFont fontWithName:@"Mission Script" size:rightTimeLabel.font.pointSize];
            rightTimeLabel.transform = CGAffineTransformMakeScale(1.3, 1);
            UILabel *leftTimeLabel = (UILabel*)[self.leftContainer viewWithTag:400];
            leftTimeLabel.font = [UIFont fontWithName:@"Mission Script" size:leftTimeLabel.font.pointSize];
            leftTimeLabel.transform = CGAffineTransformMakeScale(1.3, 1);
        }
    }
    
    return self;
}

- (void)configureCell:(Twyst*)leftTwyst leftIndex:(NSInteger)leftIndex rightTwyst:(Twyst*)rightTwyst rightIndex:(NSInteger)rightIndex {
    [self configureTwyst:self.leftContainer twyst:leftTwyst index:leftIndex];
    [self configureTwyst:self.rightContainer twyst:rightTwyst index:rightIndex];
}

- (void)configureTwyst:(UIView*)container twyst:(Twyst*)twyst index:(NSInteger)index {

    container.hidden = twyst ? NO : YES;
    if (twyst) {
        UIImageView *imageThumb = (UIImageView*)[container viewWithTag:100];
        UILabel *labelTheme = (UILabel*)[container viewWithTag:200];
        UILabel *labelUsername = (UILabel*)[container viewWithTag:300];
        UILabel *labelTime = (UILabel*)[container viewWithTag:400];
        ExtraTagButton *button = (ExtraTagButton*)[container viewWithTag:500];
        
        [self setThumbnailImage:imageThumb twyst:twyst];
        labelTheme.text = twyst.Caption;
        labelUsername.text = twyst.owner.UserName;
        labelTime.text = [[Global getInstance] timeStringWithDate:twyst.ActionTimeStamp];
        button.extraTag = index;
        
        CGSize size = [twyst.owner.UserName stringSizeWithFont:labelUsername.font constrainedToWidth:CGFLOAT_MAX];
        CGRect timeFrame = labelTime.frame;
        timeFrame.origin.x = labelUsername.frame.origin.x + size.width + 2;
        labelTime.frame = timeFrame;
    }
}

- (void)setThumbnailImage:(UIImageView*)imageView twyst:(Twyst*)twyst {
    NSURL *fileURL = TwystThumbURL(twyst.Id);
    [imageView setImageWithURL:fileURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        if (error) {
//            imageView.image = [UIImage imageNamedForDevice:@"ic-profile-feed-unavailable"];
//        }
    }];
}

@end
