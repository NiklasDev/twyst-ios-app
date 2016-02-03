//
//  PhotoRegularService.m
//  Twyst
//
//  Created by Niklas Ahola on 3/22/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "PhotoRegularService.h"
#import "FlipframeFileService.h"
#import "LibraryFlipframeServices.h"

#import "PhotoHelper.h"
#import "TStillframeRegular.h"

@interface PhotoRegularService()  {
    CameraManager* _cameraManager;
    
    NSInteger _curIndex;
    dispatch_queue_t _myBackgroundQ;
    dispatch_queue_t _queueBurstPhotos;
    dispatch_queue_t _queueImportPhotos;
}
@end

@implementation PhotoRegularService

#pragma Public Methods
- (id) initWithCameraManager:(CameraManager*) cameraManager {
    self = [super init];
    if (self)   {
        _cameraManager = cameraManager;
        _cameraManager.captureDelegate = self;
        
        //init queue
        _queueBurstPhotos = dispatch_queue_create("com.flipframe._queueBurstPhotos", 0);
        _queueImportPhotos = dispatch_queue_create("com.flipframe._queueImportPhotos", 0);
    }
    return self;
}

- (void) prepareNewRegularCapture {
    _cameraManager.captureDelegate = self;
    NSLog(@"prepareNewBurstSection");
    _curIndex = -1;
    
    [self resetAll];
    //new path output
    [[FlipframeFileService sharedInstance] emptyCapturing];
}

#pragma Public Methods
- (void) captureRegularPhoto {
    NSInteger index = [self nextIndex];
    self.totalImages = index + 1;
    
    [_cameraManager prepareConnectionForCapturing];
    [_cameraManager captureNewPhoto:index];
    //send delegate for updating counter
    if (self.photoBurstDelegate)    {
        [self.photoBurstDelegate photoRegularServiceCaptureNew];
        [self.photoBurstDelegate photoRegularServiceUpdateCounter:index + 1];
    }
}

- (void) fetchPhotosFromCameraRoll:(NSArray *)assets {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger total = [assets count];
        
        for(NSInteger i = 0; i < total; i++) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.processDelegate photoImportCompleteSingleFPS:i + 1 withTotal:total];
            });
            
            ALAsset *asset = [assets objectAtIndex:i];
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            
            @autoreleasepool {
                NSInteger index = [self nextIndex];
                NSString *pathFull = [[FlipframeFileService sharedInstance] generateCapturingFilePath:index];
                NSString *pathThumb = [[FlipframeFileService sharedInstance] generateCapturingFileThumbPath:index];
                
                if(assetRep != nil) {
                    CGImageRef imgRef = [assetRep fullResolutionImage];
                    UIImageOrientation orientation = (UIImageOrientation)[assetRep orientation];
                    UIImage *img = [UIImage imageWithCGImage:imgRef
                                                       scale:1.0f
                                                 orientation:orientation];
                    UIImage *square = [PhotoHelper actionMakeFullImage:img];
                    
                    NSData *rawDataImageFull = UIImageJPEGRepresentation(square, 1.0f);
                    [rawDataImageFull writeToFile:pathFull atomically:YES];
                    NSLog(@"full image size = %ld", (long)rawDataImageFull.length);
                    
                    UIImage *rawImageThumb = [PhotoHelper actionMakeThumbImage:square];
                    NSData *rawDataImageThumb = UIImageJPEGRepresentation(rawImageThumb, DEF_FRAME_COMPRESSION_RATE);
                    [rawDataImageThumb writeToFile:pathThumb atomically:YES];
                }
                
                [self.arrFullImagePaths addObject:pathFull];
                [self.arrThumbPaths addObject:pathThumb];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.totalImages = _curIndex + 1;
            [self.photoBurstDelegate photoRegularServiceUpdateCounter:_curIndex + 1];
            [self.photoBurstDelegate photoRegularServicePhotoDidImport];
            [self.processDelegate photoImportCompleteAllImages];
        });
    });
}

- (void) fetchPhotosFromCameraRoll_iPhone4:(NSArray *)assets {
    NSInteger total = [assets count];
    for(NSInteger i = 0; i < total; i++) {
        [self.processDelegate photoImportCompleteSingleFPS:i + 1 withTotal:total];
        
        NSDictionary *assetDict = [assets objectAtIndex:i];
        
        // check if square photo already exists
        if ([[assetDict allKeys] containsObject:@"FullImageProperty"]) {
            NSString *pathFull = [assetDict objectForKey:@"FullImageProperty"];
            NSString *pathThumb = [assetDict objectForKey:@"ThumbnailProperty"];
            [self.arrFullImagePaths addObject:pathFull];
            [self.arrThumbPaths addObject:pathThumb];
        }
        else {
            ALAsset *asset = [assetDict objectForKey:@"AssetProperty"];
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            
            @autoreleasepool {
                NSInteger index = [self nextIndex];
                NSString *pathFull = [[FlipframeFileService sharedInstance] generateCapturingFilePath:index];
                NSString *pathThumb = [[FlipframeFileService sharedInstance] generateCapturingFileThumbPath:index];
                
                if(assetRep != nil) {
                    CGImageRef imgRef = [assetRep fullResolutionImage];
                    UIImageOrientation orientation = (UIImageOrientation)[assetRep orientation];
                    UIImage *img = [UIImage imageWithCGImage:imgRef
                                                       scale:1.0f
                                                 orientation:orientation];
                    UIImage *square = [PhotoHelper actionMakeFullImage:img];
                    
                    NSData *rawDataImageFull = UIImageJPEGRepresentation(square, 1.0f);
                    [rawDataImageFull writeToFile:pathFull atomically:YES];
                    NSLog(@"full image size = %ld", (long)rawDataImageFull.length);
                    
                    UIImage *rawImageThumb = [PhotoHelper actionMakeFullImage:square];
                    NSData *rawDataImageThumb = UIImageJPEGRepresentation(rawImageThumb, DEF_FRAME_COMPRESSION_RATE);
                    [rawDataImageThumb writeToFile:pathThumb atomically:YES];
                }
                
                [self.arrFullImagePaths addObject:pathFull];
                [self.arrThumbPaths addObject:pathThumb];
            }
        }
    }
    
    self.totalImages = _curIndex + 1;
    [self.photoBurstDelegate photoRegularServiceUpdateCounter:_curIndex + 1];
    [self.photoBurstDelegate photoRegularServicePhotoDidImport];
    [self.processDelegate photoImportCompleteAllImages];
}

- (NSInteger) nextIndex   {
    _curIndex ++;
    return _curIndex;
}

#pragma mark--
- (void) deleteAllFrames {
    [Global getInstance].isCancelCameraProcessing = YES;
    
    _curIndex = -1;
    if (self.photoBurstDelegate) {
        [self.photoBurstDelegate photoRegularServiceUpdateCounter:0];
        [self.photoBurstDelegate photoRegularServiceNotifyAllSegmentDeleted];
    }
}

- (void) deleteFrames:(NSArray *)deleteIndexArray {
    [Global getInstance].isCancelCameraProcessing = YES;
    
    NSInteger totalImages = [self totalImages];
    for (NSInteger i = totalImages - 1; i >= 0; i--) {
        NSNumber * selectedStatus = [deleteIndexArray objectAtIndex:i];
        if ([selectedStatus boolValue] == YES) {
            [self.arrFullImagePaths removeObjectAtIndex:i];
            [self.arrThumbPaths removeObjectAtIndex:i];
        }
    }
    
    NSInteger restImagesCount = [self.arrThumbPaths count];
    _curIndex = restImagesCount - 1;
    self.totalImages = _curIndex + 1;
    [self.photoBurstDelegate photoRegularServiceUpdateCounter:restImagesCount];
    if (restImagesCount == 0) {
        [self.photoBurstDelegate photoRegularServiceNotifyAllSegmentDeleted];
    }
}

#pragma Delegate
- (void) cameraCompleteAllSegments:(int)total   {
    
}

- (void) cameraManagerStillCaptureNewSampleBuffer:(CMSampleBufferRef)sampleBuffer withIndex:(NSInteger)index withError:(NSError *)error   {
    if (sampleBuffer)   {
        if ([self.photoBurstDelegate respondsToSelector:@selector(photoRegularServiceCaptureWithRawImage:)]) {
            NSData *rawImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage * rawImage = [UIImage imageWithData:rawImageData];
            [self.photoBurstDelegate photoRegularServiceCaptureWithRawImage:rawImage];
        }
        
        NSString *pathFull = [[FlipframeFileService sharedInstance] generateCapturingFilePath:index];
        NSString *pathThumb = [[FlipframeFileService sharedInstance] generateCapturingFileThumbPath:index];
        
        void (^block)(UIImage*) = ^void(UIImage *image) {
            if (self.isNotify)  {
                if (self.delegate)  {
                    [self.delegate flipframeInputServiceDidCompleteImage:pathThumb atIndex:index];
                }
            }
            
            if ([self.photoBurstDelegate respondsToSelector:@selector(photoRegularServiceCaptureResult:)]) {
                [self.photoBurstDelegate photoRegularServiceCaptureResult:image];
            }
            [self.arrFullImagePaths addObject:pathFull];
            [self.arrThumbPaths addObject:pathThumb];
            NSLog(@"____ complete crop and saving: %ld", (long)index);
        };
        
        //call crop and writing
        if ([Global deviceType] == DeviceTypePhone4) {
            [PhotoHelper cropAndSave_iPhone4:sampleBuffer withPathFull:pathFull withPathThumb:pathThumb inQueue:_queueBurstPhotos completion:^(UIImage * image) {
                block(image);
            }];
        }
        else {
            [PhotoHelper cropAndSave:sampleBuffer withPathFull:pathFull withPathThumb:pathThumb inQueue:_queueBurstPhotos completion:^(UIImage * image) {
                block(image);
            }];
        }
    }   else    {
        _curIndex --;
        self.totalImages--;
        if (self.photoBurstDelegate)    {
            [self.photoBurstDelegate photoRegularServiceUpdateCounter:_curIndex + 1];
        }
    }
}

#pragma mark--


@end
