//
//  TwystInfoView.h
//  Twyst
//
//  Created by Niklas Ahola on 9/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSavedTwyst.h"

@protocol TwystInfoViewDelegate <NSObject>

- (void)twystInfoViewDidHide;
- (void)twystInfoViewMoreDidClick;
- (void)twystInfoViewReplyDidClick;
- (void)twystInfoViewPassDidClick;
- (void)twystInfoViewCreatorDidTap;

@end

@interface TwystInfoView : UIView

@property (nonatomic, retain) TSavedTwyst *twyst;
@property (nonatomic, assign) id <TwystInfoViewDelegate> delegate;

- (id)initWithTwyst:(TSavedTwyst*)twyst;

- (void)show;
- (void)hide:(void(^)(void))completion;

- (BOOL)isVisible;
- (NSInteger)getTwysterCount;

- (void)releaseInfoView;

@end
