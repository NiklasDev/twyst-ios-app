//
//  CameraCaptureButton.h
//  Twyst
//
//  Created by Niklas Ahola on 4/22/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CameraButtonStateNormal = 0,
    CameraButtonStatePhoto,
    CameraButtonStateVideo,
} CameraButtonState;

@protocol CameraCaptureButtonDelegate <NSObject>

- (void)CameraCapturePhoto;
- (void)CameraCaptureVideoStart;
- (void)CameraCaptureVideoEnd;

@end

@interface CameraCaptureButton : UIView

@property (nonatomic, assign) id <CameraCaptureButtonDelegate> delegate;

- (void)enableVideoCapturing:(BOOL)enable;
- (void)changeButtonState:(CameraButtonState)state;

@end
