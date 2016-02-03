//
//  CaptureViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 6/20/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureViewController : UIViewController

@property (nonatomic, assign) CameraCaptureType captureType;

- (void) startNewSession;
- (void) startNewSessionToReply:(long)twystId;

- (void)setShouldNotLoadCameraPreview;

@end
