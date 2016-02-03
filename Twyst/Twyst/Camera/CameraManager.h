//
//  CameraManager.h
//  Twyst
//
//  Created by Niklas Ahola on 8/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CameraManagerCaptureDelegate <NSObject>

- (void) cameraManagerStillCaptureNewSampleBuffer:(CMSampleBufferRef)sampleBuffer withIndex:(NSInteger)index withError:(NSError*) error;
- (void) cameraCompleteAllSegments:(int) total;

@end

@protocol CameraManagerManageDelegate <NSObject>

- (void) reverseCamera:(AVCaptureDevicePosition)position;
- (void) adjustFocusDidFinish;

- (void) captureVideoDidFinish:(NSURL*)videoURL duration:(NSTimeInterval)duration;
- (void) captureVideoDuration:(NSTimeInterval)duration;

@end

@interface CameraManager : NSObject <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;
@property (nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,assign) id deviceConnectedObserver;
@property (nonatomic,assign) id deviceDisconnectedObserver;
@property (nonatomic, assign) id <CameraManagerCaptureDelegate> captureDelegate;
@property (nonatomic, assign) id <CameraManagerManageDelegate> manageDelegate;

- (BOOL) setupSession:(BOOL) isBack;
- (BOOL) toggleCamera;

- (NSUInteger) cameraCount;

- (void) start;
- (void) stop;

- (BOOL) supportFlashOn;
- (void) flashOn;
- (void) flashOff;
- (BOOL) isFlashOn;

- (BOOL) checkIfCameraBack;

//add burst mode capture
- (void) prepareConnectionForCapturing;
- (void) captureNewPhoto:(NSInteger) index;
- (void) captureVideoStart;
- (void) captureVideoEnd;
- (void) focus:(CGPoint) point;
- (UIImage*)getVideoThumbnail:(NSURL*)videoUrl;

@end
