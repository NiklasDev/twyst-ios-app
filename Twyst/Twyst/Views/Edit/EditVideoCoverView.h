//
//  EditVideoCoverView.h
//  Twyst
//
//  Created by Niklas Ahola on 5/7/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditVideoCoverViewDelegate <NSObject>

- (void)coverFrameDidChange;

@end

@interface EditVideoCoverView : UIView

@property (nonatomic, assign) id <EditVideoCoverViewDelegate> delegate;

- (void)startNewSession;

@end
