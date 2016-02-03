//
//  PhotoAutoService.h
//  Twyst
//
//  Created by Niklas Ahola on 4/6/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipframeInputService.h"
#import "CameraManager.h"

@protocol PhotoAutoServiceDelegate <NSObject>

- (void) photoAutoServiceTimeCounter:(int) photoIndex withCounDownTime:(int) countDownTime withMaxPhotos:(int) maxPhotos;
- (void) photoAutoServiceTimeOver;
- (void) photoAutoServiceCaptureNew;

@optional
- (void) photoAutoServiceCaptureResult:(UIImage *)image;
- (void) photoAutoServiceCaptureWithRawImage:(UIImage *)rawImage;

@end

@interface PhotoAutoService : FlipframeInputService <CameraManagerCaptureDelegate>
@property (nonatomic, assign) id <PhotoAutoServiceDelegate> photoSelfieDelegate;
- (id) initWithCameraManager:(CameraManager*) cameraManager;
- (void) prepareNewSection;
- (void) startCapturing;
- (void) pauseCapturing;
- (void) endSelfieSection;
@end
