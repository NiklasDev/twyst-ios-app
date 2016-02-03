//
//  HomeEmptyCell.m
//  Twyst
//
//  Created by Niklas Ahola on 2/19/15.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HomeEmptyCell.h"

@interface HomeEmptyCell()  {
    
}

@end

@implementation HomeEmptyCell

+ (CGFloat)heightForCell {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            return 400;
            break;
        case DeviceTypePhone6Plus:
            return 460;
            break;
        default:
            return 300;
            break;
    }
}

+ (NSString *)reuseIdentifier {
    return @"EmptyDataCell";
}

+ (NSString *)nibName {
    return ([Global deviceType] == DeviceTypePhone4) ? @"HomeEmptyCell-3.5inch" : [FlipframeUtils nibNameForDevice:@"HomeEmptyCell"];
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
    _viewEmptyHome.hidden = YES;
    _viewEmptyDirect.hidden = YES;
    _viewEmptySaved.hidden = YES;
}

- (void)showEmptyHome:(id)target selector:(SEL)selector {
    [self hideAllViews];
    _viewEmptyHome.hidden = NO;
    [_btnHomeCreate addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)showEmptyDirect:(id)target selector:(SEL)selector {
    [self hideAllViews];
    _viewEmptyDirect.hidden = NO;
    [_btnDirectInvite addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)showEmptySaved:(id)target selector:(SEL)selector {
    [self hideAllViews];
    _viewEmptySaved.hidden = NO;
    [_btnSavedCreate addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
