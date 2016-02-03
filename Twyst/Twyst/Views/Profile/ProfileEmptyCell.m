//
//  ProfileEmptyCell.m
//  Twyst
//
//  Created by Niklas Ahola on 2/19/15.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileEmptyCell.h"

@interface ProfileEmptyCell()  {
    
}

@end

@implementation ProfileEmptyCell

+ (CGFloat)heightForCell:(CGFloat)tableHeaderViewHeight {
    return [ProfileEmptyCell calculateCellHeight:tableHeaderViewHeight];
}

+ (NSString *)reuseIdentifier {
    return @"ProfileEmptyCell";
}

+ (NSString *)nibName {
    return [FlipframeUtils nibNameForDevice:@"ProfileEmptyCell"];
}

+ (CGFloat)calculateCellHeight:(CGFloat)tableHeaderViewHeight {
    return SCREEN_HEIGHT - tableHeaderViewHeight - UI_TAB_BAR_HEIGHT;
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
            self.backgroundColor = [UIColor clearColor];
            self.activityIndicator.indicatorStyle = WDActivityIndicatorStyleGradientPurple;
        }
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

- (void)hideAllViews {
    [self.activityIndicator stopAnimating];
    
    _viewProfileNoPosts.hidden = YES;
    _viewFriendNoPosts.hidden = YES;
    _viewFriendPrivate.hidden = YES;
    _viewLoadingPosts.hidden = YES;
}

- (void)resizeContentView:(CGFloat)tableHeaderViewHeight {
    CGRect frame = self.contentView.frame;
    frame.size.height = [[self class] calculateCellHeight:tableHeaderViewHeight];
    self.contentView.frame = frame;
}

- (void)showProfileNoPosts:(CGFloat)tableHeaderViewHeight {
    [self hideAllViews];
    
    [self resizeContentView:tableHeaderViewHeight];
    _viewProfileNoPosts.hidden = NO;
}

- (void)showFriendNoPosts:(CGFloat)tableHeaderViewHeight {
    [self hideAllViews];
    
    [self resizeContentView:tableHeaderViewHeight];
    _viewFriendNoPosts.hidden = NO;
}

- (void)showFriendPrivate:(CGFloat)tableHeaderViewHeight {
    [self hideAllViews];
    
    [self resizeContentView:tableHeaderViewHeight];
    _viewFriendPrivate.hidden = NO;
}

- (void)showProfileLoading:(CGFloat)tableHeaderViewHeight {
    [self hideAllViews];
    
    [self.activityIndicator startAnimating];
    _viewLoadingPosts.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
