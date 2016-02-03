//
//  EmptyDataCell.m
//  Twyst
//
//  Created by Niklas Ahola on 2/19/15.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EmptyDataCell.h"

@interface EmptyDataCell()  {
    
}

@end

@implementation EmptyDataCell

+ (CGFloat)heightForCell {
    switch ([Global deviceType]) {
        case DeviceTypePhone4:
            return 209;
            break;
        case DeviceTypePhone5:
            return 250;
            break;
        case DeviceTypePhone6:
            return 297;
            break;
        case DeviceTypePhone6Plus:
            return 297;
            break;
        default:
            return 0;
            break;
    }
}

+ (NSString *)reuseIdentifier {
    return @"EmptyDataCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"EmptyDataCell"];
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
        }
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

- (void)hideAllViews {
    _viewFriendPending.hidden = YES;
    _viewFriendNoStringg.hidden = YES;
    _viewFriendPrivate.hidden = YES;
    _viewFriendAccept.hidden = YES;
    
    _viewHomeFollowing.hidden = YES;
    _viewHomePrivate.hidden = YES;
    _viewHomeSaved.hidden = YES;
}

- (void)showFriendPending {
    [self hideAllViews];
    _viewFriendPending.hidden = NO;
}

- (void)showFriendNoPosts {
    [self hideAllViews];
    _viewFriendNoStringg.hidden = NO;
}

- (void)showFriendPrivate {
    [self hideAllViews];
    _viewFriendPrivate.hidden = NO;
}

- (void)showFriendAccept {
    [self hideAllViews];
    _viewFriendAccept.hidden = NO;
}

- (void)showHomeFollowing {
    [self hideAllViews];
    _viewHomeFollowing.hidden = NO;
}

- (void)showHomePrivate {
    [self hideAllViews];
    _viewHomePrivate.hidden = NO;
}

- (void)showHomeSaved {
    [self hideAllViews];
    _viewHomeSaved.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
