//
//  TwystNoticeCell.m
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NSString+Extension.h"

#import "TwystNoticeCell.h"

@interface TwystNoticeCell() {
    CGFloat _offsetX;
    CGFloat _fontSize;
    CGFloat _labelHeight;
    CGFloat _marginTextX;
}

@property (nonatomic, retain) UILabel *labelText;

@end

@implementation TwystNoticeCell

+ (CGFloat)heightForCell {
    DeviceType type = [Global deviceType];
    switch (type) {
        case DeviceTypePhone6:
            return 44.0f;
            break;
        case DeviceTypePhone6Plus:
            return 50.0f;
            break;
        default:
            return 44.0f;
            break;
    }
}

- (id)initWithUsername:(NSString*)username action:(NSString*)action color:(UIColor*)color {
    CGRect bound = CGRectMake(0, 0, SCREEN_WIDTH, [TwystNoticeCell heightForCell]);
    self = [super initWithFrame:bound];
    if (self) {
        //
        [self initMembers];
        [self initView:username action:action color:color];
        [self performSelector:@selector(hide) withObject:nil afterDelay:3.0f];
    }
    return self;
}

- (void)initMembers {
    switch ([Global deviceType]) {
        case DeviceTypePhone6:
            _offsetX = 15;
            _fontSize = 14.4;
            _labelHeight = 37.0f;
            _marginTextX = 8;
            break;
        case DeviceTypePhone6Plus:
            _offsetX = 16;
            _fontSize = 15.7;
            _labelHeight = 41.0f;
            _marginTextX = 12;
            break;
        default:
            _offsetX = 14;
            _fontSize = 14.4;
            _labelHeight = 37.0f;
            _marginTextX = 11;
            break;
    }
}

- (void)initView:(NSString*)username action:(NSString*)action color:(UIColor*)color {
    
    self.backgroundColor = [UIColor clearColor];
    
    NSAttributedString *attrText = [NSString formattedString:@[username, [self actionString:action]]
                                                         fonts:@[[UIFont fontWithName:@"OpenSans-Semibold" size:_fontSize],
                                                                 [UIFont fontWithName:@"OpenSans-Light" size:_fontSize]]
                                                        colors:nil
                                                     lineSpace:2
                                                     alignment:NSTextAlignmentCenter];
    
    CGRect rect = [attrText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    CGRect frame = CGRectMake(_offsetX,
                              (self.bounds.size.height - _labelHeight) / 2,
                              rect.size.width + _marginTextX * 2,
                              _labelHeight);
    
    _labelText = [[UILabel alloc] initWithFrame:frame];
    _labelText.backgroundColor = color;
    _labelText.layer.cornerRadius = 3.0f;
    _labelText.layer.masksToBounds = YES;
    _labelText.textColor = [UIColor whiteColor];
    _labelText.attributedText = attrText;
    [self addSubview:_labelText];
}

- (NSString*)actionString:(NSString*)action {
    if ([action isEqualToString:@"Like"]) {
        return @" liked it!";
    }
    if ([action isEqualToString:@"Reply"]) {
        return @" replied";
    }
    if ([action isEqualToString:@"Pass"]) {
        return @" passed it on...";
    }
    if ([action isEqualToString:@"start"]) {
        return @" started it";
    }
    return @" ";
}

- (void)hide {
    [UIView animateWithDuration:2.0f
                     animations:^{
                         self.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.delegate twystNoticeCellDidDisappear:self];
                     }];
}

- (void)releaseNoticeCell {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(hide)
                                               object:nil];
    [self removeFromSuperview];
}

- (void)setNoticeColor:(UIColor*)color {
    _labelText.backgroundColor = color;
}

@end
