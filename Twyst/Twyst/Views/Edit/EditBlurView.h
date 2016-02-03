//
//  EditBlurView.h
//  Twyst
//
//  Created by Niklas Ahola on 8/20/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditBlurViewDelegate <NSObject>

- (void)editBlurViewDidCancelTouch;
- (void)editBlurViewDidApplyTouch;

@end

@interface EditBlurView : UIView

@property (nonatomic, assign) id <EditBlurViewDelegate> delegate;
@property (weak, nonatomic) UIView *controlView;

- (id)initWithTarget:(id)target imageIndex:(NSInteger)index;
- (void)showInView:(UIView*)view;
- (void)hide;

@end
