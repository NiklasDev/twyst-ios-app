//
//  EditFilterView.h
//  Twyst
//
//  Created by Niklas Ahola on 7/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditFilterViewDelegate <NSObject>

- (void) editFilderView:(id) sender didSelect:(NSInteger) index;

@end

@interface EditFilterView : UIView

@property (nonatomic, assign) id <EditFilterViewDelegate> delegate;

- (void) enableGraphics:(BOOL) isEnable;
- (void) reloadAll;
- (void) startNewSession;

@end
