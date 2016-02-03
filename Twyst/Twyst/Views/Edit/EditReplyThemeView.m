//
//  EditReplyThemeView.m
//  Twyst
//
//  Created by Wang Fang on 3/26/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extension.h"

#import "TTwystOwnerManager.h"
#import "TSavedTwystManager.h"

#import "EditReplyThemeView.h"

@interface EditReplyThemeView() {
    CGRect _frameAvatar;
    CGFloat _themeOffsetY;
    CGFloat _themeOffsetX;
    CGFloat _themeFontSize;
    CGFloat _creatorFontSize;
}

@end

@implementation EditReplyThemeView

- (id)initWithStringgId:(long)stringgId {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:bounds];
    if (self) {
        [self initMembers];
        [self initView:stringgId];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone4:
        case DeviceTypePhone5:
            _frameAvatar = CGRectMake(119, 125, 82, 82);
            _themeOffsetY = 228;
            _themeOffsetX = 30;
            _themeFontSize = 20;
            _creatorFontSize = 12;
            break;
        case DeviceTypePhone6:
            _frameAvatar = CGRectMake(139.5, 150, 96, 96);
            _themeOffsetY = 280;
            _themeOffsetX = 40;
            _themeFontSize = 22;
            _creatorFontSize = 14;
            break;
        case DeviceTypePhone6Plus:
            _frameAvatar = CGRectMake(159, 160, 96, 96);
            _themeOffsetY = 290;
            _themeOffsetX = 40;
            _themeFontSize = 22;
            _creatorFontSize = 14;
            break;
        default:
            break;
    }
}

- (void)initView:(long)twystId {
    TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:twystId];
    long ownerId = [savedTwyst.ownerId longValue];
    TTwystOwner *tOwner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:ownerId];
    NSString *profilePicName = tOwner.profilePicName;
    NSString *theme = savedTwyst.caption;
    NSString *username = tOwner.userName;
    
    self.backgroundColor = [UIColor clearColor];
    
    CGRect bounds = self.bounds;
    
    UIView *viewMask = [[UIView alloc] initWithFrame:bounds];
    viewMask.backgroundColor = ColorRGBA(11, 11, 11, 0.85);
    [self addSubview:viewMask];
    
    // add back button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = bounds;
    [button addTarget:self action:@selector(handleTapView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    // add avatar
    UIImageView *imageAvatar = [[UIImageView alloc] initWithFrame:_frameAvatar];
    imageAvatar.layer.cornerRadius = _frameAvatar.size.width / 2;
    imageAvatar.layer.masksToBounds = YES;
    imageAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    imageAvatar.layer.borderWidth = 3;
    
    UIImage *placeholder = [UIImage imageNamedContentFile:@"ic-cell-avatar"];
    [imageAvatar setImageWithURL:ProfileURL(profilePicName) placeholderImage:placeholder];
    [self addSubview:imageAvatar];
    
    // add caption
    CGFloat labelWidth = bounds.size.width - 2 * _themeOffsetX;
    theme = [NSString stringWithFormat:@"\"%@\"", theme];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:_themeFontSize];
    CGSize size = [theme stringSizeWithFont:font constrainedToWidth:labelWidth];
    CGRect frame = CGRectMake(_themeOffsetX, _themeOffsetY, labelWidth, size.height);
    UILabel *labelCaption = [[UILabel alloc] initWithFrame:frame];
    labelCaption.backgroundColor = [UIColor clearColor];
    labelCaption.textColor = [UIColor whiteColor];
    labelCaption.text = theme;
    labelCaption.font = font;
    labelCaption.textAlignment = NSTextAlignmentCenter;
    labelCaption.numberOfLines = 0;
    [self addSubview:labelCaption];
    
    // add username
    username = [NSString stringWithFormat:@"created by %@", username];
    frame = CGRectMake(_themeOffsetX, _themeOffsetY + size.height + 20, labelWidth, 16);
    UILabel *labelUsername = [[UILabel alloc] initWithFrame:frame];
    labelUsername.backgroundColor = [UIColor clearColor];
    labelUsername.textColor = [UIColor whiteColor];
    labelUsername.text = username;
    labelUsername.font = [UIFont fontWithName:@"HelveticaNeue" size:_creatorFontSize];
    labelUsername.textAlignment = NSTextAlignmentCenter;
    [self addSubview:labelUsername];
}

- (void)handleTapView:(id)sender {
    [self hide];
}

- (void)showInView:(UIView*)parent {
    self.alpha = 0.0f;
    [parent addSubview:self];
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.alpha = 1.0f;
                     }];
}

- (void)hide {
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void) dealloc {
    NSLog(@"--- %@ dealloc ---", NSStringFromClass([self class]));
}

@end
