//
//  CameraFocusLayout.h
//  Twyst
//
//  Created by Niklas Ahola on 4/1/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraFocusLayoutDelegate <NSObject>

- (void) cameraPreviewDidTouch:(CGPoint) point; //range (0->1, 0->1)

@end

@interface CameraFocusLayout : UIView

@property (nonatomic, assign) id <CameraFocusLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL isFocusing;

- (void) adjustFocusDidFinish;
- (void) reverseCamera;

@end
