//
//  PhotoAutoService.m
//  Twyst
//
//  Created by Niklas Ahola on 4/6/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "PhotoHelper.h"
#import "PhotoAutoService.h"
#import "FlipframeFileService.h"

@interface PhotoAutoService() {
    CameraManager* _cameraManager;
    
    int _curIndex;
    int _curCountDown;
    float _intervalTime; //in second
    BOOL _isCapturing;
    dispatch_queue_t _queueSelfiePhotos;
    
    //sizes
    CGSize _sizeFull;
    CGSize _sizeThumb;
    NSTimer *_timer;
    
    int _maxPhotos;
    int _maxCountDown;
}
@end

@implementation PhotoAutoService
- (id) initWithCameraManager:(CameraManager*) cameraManager {
    self = [super init];
    if (self)   {
        _cameraManager = cameraManager;
        _cameraManager.captureDelegate = self;
        _intervalTime = DEF_CAMERA_BURST_INTERVAL_TIME;
        
        //init queue
        _queueSelfiePhotos = dispatch_queue_create("com.flipframe._queueSelfiePhotos", 0);
        
        //init sizes
        _sizeFull = CGSizeMake(DEF_TWYST_IMAGE_WIDTH, DEF_TWYST_IMAGE_HEIGHT);
        _sizeThumb = CGSizeMake(DEF_TWYST_THUMB_SIZE, DEF_TWYST_THUMB_SIZE);
    }
    return self;
}
#pragma Public Methods
- (void) prepareNewSection  {
    _cameraManager.captureDelegate = self;
    [self resetAll];
    _curIndex = 0;
    _isCapturing = NO;
    _timer = nil;
    _maxCountDown = (int)[Global getConfig].selfieIntervalTime;
    _maxPhotos = (int) [Global getConfig].selfieStripSize;
    _curCountDown = _maxCountDown;
    [self actionStartTimer];
    [[FlipframeFileService sharedInstance] emptyCapturing];
}
- (void) startCapturing {
    _isCapturing = YES;
    NSLog(@"startCapturing");
    
}

- (void) pauseCapturing {
    _isCapturing = NO;
}
- (void) endSelfieSection   {
    self.totalImages = _curIndex;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
#pragma mark--

#pragma Internal actions
- (void) actionStartTimer   {
    //start timer
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onCaptureTimerTick:) userInfo:nil repeats:YES];
}

-(void)onCaptureTimerTick:(NSTimer *)timer {
    NSLog(@"onCaptureTimerTick");
    if (_isCapturing)   {
        [self actionCountDownAndCapture];
    }
}

- (void) actionCountDownAndCapture  {
    NSLog(@"actionCountDownAndCapture: %d - %d - %d", _curIndex, _curCountDown, _maxCountDown);
    if (_curIndex == _maxPhotos)    {
        _isCapturing = NO;
        [_timer invalidate];
        _timer = nil;
        if (self.photoSelfieDelegate)   {
            [self.photoSelfieDelegate photoAutoServiceTimeOver];
        }
        return;
    }
    if (_curCountDown == 0) {
        [_cameraManager prepareConnectionForCapturing];
        if (self.photoSelfieDelegate)   {
            [self.photoSelfieDelegate photoAutoServiceCaptureNew];
        }
        [_cameraManager captureNewPhoto:_curIndex];
    }
    if (self.photoSelfieDelegate)   {
        [self.photoSelfieDelegate photoAutoServiceTimeCounter:_curIndex withCounDownTime:_curCountDown withMaxPhotos:_maxPhotos];
    }
    if (_curCountDown == 0) {
        _curCountDown = _maxCountDown;
        _curIndex ++;
        if (_curIndex < _maxPhotos)    {
            if (self.photoSelfieDelegate)   {
                [self.photoSelfieDelegate photoAutoServiceTimeCounter:_curIndex withCounDownTime:_curCountDown withMaxPhotos:_maxPhotos];
            }
        }
    }
    _curCountDown --;
}

#pragma delegate CameraManager
- (void) cameraManagerStillCaptureNewSampleBuffer:(CMSampleBufferRef)sampleBuffer withIndex:(NSInteger)index withError:(NSError *)error   {
    if (sampleBuffer)   {
        NSLog(@"++++ sampleBuffer - OK: %ld", (long)index);
        
        if ([self.photoSelfieDelegate respondsToSelector:@selector(photoAutoServiceCaptureWithRawImage:)]) {
            NSData *rawImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage * rawImage = [UIImage imageWithData:rawImageData];
            [self.photoSelfieDelegate photoAutoServiceCaptureWithRawImage:rawImage];
        }
        
        NSString *pathFull = [[FlipframeFileService sharedInstance] generateCapturingFilePath:index];
        NSString *pathThumb = [[FlipframeFileService sharedInstance] generateCapturingFileThumbPath:index];
        NSLog(@"~~~~~ start crop and saving");
        NSLog(@"pathFull: %@", pathFull);
        NSLog(@"pathThumb: %@", pathThumb);
        
        void(^block)(UIImage*) = ^void(UIImage *image) {
            if (self.isNotify)  {
                if (self.delegate)  {
                    [self.delegate flipframeInputServiceDidCompleteImage:pathThumb atIndex:index];
                }
            }
            
            if ([self.photoSelfieDelegate respondsToSelector:@selector(photoAutoServiceCaptureResult:)]) {
                [self.photoSelfieDelegate photoAutoServiceCaptureResult:image];
            }
            [self.arrFullImagePaths addObject:pathFull];
            [self.arrThumbPaths addObject:pathThumb];
            NSLog(@"____ complete crop and saving: %ld", (long)index);
        };
        
        //call crop and writing
        if ([Global deviceType] == DeviceTypePhone4) {
            [PhotoHelper cropAndSave_iPhone4:sampleBuffer withPathFull:pathFull withPathThumb:pathThumb inQueue:_queueSelfiePhotos completion:^(UIImage * image) {
                block(image);
            }];
        }
        else {
            [PhotoHelper cropAndSave:sampleBuffer withPathFull:pathFull withPathThumb:pathThumb inQueue:_queueSelfiePhotos completion:^(UIImage * image) {
                block(image);
            }];
        }
    }
}

- (void) cameraCompleteAllSegments:(int)total   {
    
}

#pragma mark--
@end
