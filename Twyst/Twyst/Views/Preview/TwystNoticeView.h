//
//  TwystNoticeView.h
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSavedTwyst.h"

@protocol TwystNoticeViewDelegate <NSObject>

- (void)twystNoticeViewDidClose;
- (void)twystNoticeViewMoreDidClick;

@end

@interface TwystNoticeView : UIView

@property (nonatomic, retain) TSavedTwyst *twyst;
@property (nonatomic, assign) id <TwystNoticeViewDelegate> delegate;

- (id)initWithTwyst:(TSavedTwyst*)twyst;

- (void)show;
- (void)hide:(void(^)(void))completion;

- (void)releaseNoticeView;

@end
