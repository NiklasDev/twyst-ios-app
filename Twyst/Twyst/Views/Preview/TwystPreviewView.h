//
//  TwystPreviewView.h
//  Twyst
//
//  Created by Niklas Ahola on 8/27/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSavedTwyst.h"
#import "FFlipframeSavedLibrary.h"

@protocol TwystPreviewDelegate <NSObject>

@optional

- (void)twystPreviewDidView:(id)sender;
- (void)twystPreviewDidSwipe:(UISwipeGestureRecognizerDirection)direction;
- (void)twystPreviewDidChange:(NSString*)profilePicName frameTime:(NSTimeInterval)frameTime;
- (void)twystPreviewDidPause;
- (void)twystPreviewDidResume;

@end

@interface TwystPreviewView : UIView

- (void)enableSwipeGestures;
- (void)setDataSourceWithFlipframeLibrary:(FFlipframeSavedLibrary*)flipframeLibrary;
- (void)setDataSourceWithSavedTwyst:(TSavedTwyst*)savedTwyst;

- (void)setSelectedImageIndex:(long)indexl;
- (void)reloadSelectedImage;
- (UIImage*)getActiveFrame;
- (UIImage*)getPreviewSnapShot;

- (void)pause;
- (void)play;
- (void)resume;

@property (nonatomic, assign) long imageIndex;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) id <TwystPreviewDelegate> delegate;

@end
