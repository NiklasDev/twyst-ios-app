//
//  EditThemeView.h
//  Twyst
//
//  Created by Niklas Ahola on 4/17/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditThemeViewDelegate <NSObject>

@optional
- (void)editThemeViewDidDisapper:(id)sender isConfirm:(BOOL)isConfirm;
- (void)editThemeViewWillDisapper:(id)sender isConfirm:(BOOL)isConfirm;

@end

@interface EditThemeView : UIView

@property (nonatomic, assign) id <EditThemeViewDelegate> delegate;

- (id)initWithParent:(UIView*)parent;
- (void)show;

@end
