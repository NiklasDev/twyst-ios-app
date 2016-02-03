//
//  TwystNoticeCell.h
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSavedTwyst.h"

@class TwystNoticeCell;

@protocol TwystNoticeCellDelegate <NSObject>

- (void)twystNoticeCellDidDisappear:(TwystNoticeCell*)sender;

@end

@interface TwystNoticeCell : UIView

@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, assign) id <TwystNoticeCellDelegate> delegate;

+ (CGFloat)heightForCell;
- (id)initWithUsername:(NSString*)username action:(NSString*)action color:(UIColor*)color;
- (void)releaseNoticeCell;
- (void)setNoticeColor:(UIColor*)color;

@end
