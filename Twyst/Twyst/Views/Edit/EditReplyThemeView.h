//
//  EditReplyThemeView.h
//  Twyst
//
//  Created by Wang Fang on 3/26/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditReplyThemeView : UIView

- (id)initWithStringgId:(long)twystId;

- (void)showInView:(UIView*)parent;
- (void)hide;

@end
