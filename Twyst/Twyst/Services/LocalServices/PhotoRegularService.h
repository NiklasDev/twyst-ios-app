//
//  PhotoRegularService.h
//  Twyst
//
//  Created by Niklas Ahola on 3/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraManager.h"
#import "FlipframeInputService.h"

@protocol PhotoRegularServiceDelegate <NSObject>

- (void) photoRegularServiceUpdateCounter:(NSInteger) counter;//from 0->1
- (void) photoRegularServiceCaptureNew;
- (void) photoRegularServiceNotifyAllSegmentDeleted;
- (void) photoRegularServicePhotoDidImport;

@optional
- (void) photoRegularServiceUpdateProgressBar:(float) value;//from 0->1
- (void) photoRegularServiceTimeOver;
- (void) photoRegularServiceCaptureResult:(UIImage *)image;
- (void) photoRegularServiceCaptureWithRawImage:(UIImage *)rawImage;

@end

@protocol PhotoImportServiceProcessDelegate <NSObject>

- (void) photoImportCompleteSingleFPS:(NSInteger)currectFps withTotal:(NSInteger) totalFps;
- (void) photoImportCompleteAllImages;

@end

@interface PhotoRegularService : FlipframeInputService<CameraManagerCaptureDelegate>

@property (nonatomic, assign) id <PhotoRegularServiceDelegate> photoBurstDelegate;
@property (nonatomic, assign) id <PhotoImportServiceProcessDelegate> processDelegate;

- (id) initWithCameraManager:(CameraManager*) cameraManager;
- (void) prepareNewRegularCapture;
- (void) captureRegularPhoto;

- (void) fetchPhotosFromCameraRoll:(NSArray *)assets;
- (void) fetchPhotosFromCameraRoll_iPhone4:(NSArray *)assets;

- (void) deleteAllFrames;
- (void) deleteFrames:(NSArray *)deleteIndexArray;

@end
