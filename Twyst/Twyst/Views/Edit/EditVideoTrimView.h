//
//  EditVideoTrimView.h
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditVideoView.h"

@protocol EditVideoTrimViewDelegate <NSObject>

- (void)trimViewDidChange:(id)sender;

@end

@interface EditVideoTrimView : UIView

@property (nonatomic, retain) EditVideoView *videoView;
@property (nonatomic, assign) id <EditVideoTrimViewDelegate> delegate;

- (void)startTimer;
- (void)invalidateTimer;

@end
