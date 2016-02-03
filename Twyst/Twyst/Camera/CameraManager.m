//
//  CameraManager.m
//  Twyst
//
//  Created by Niklas Ahola on 8/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "CameraManager.h"
#import "FlipframeFileService.h"

@interface CameraManager()  {
    AVCaptureConnection *_curCaptureConnection;
    BOOL    _isFlashEnabled;
    BOOL    _isMovieRecording;
    
    NSTimer *_videoTimer;
    NSTimeInterval _videoStart;
}

@end

@implementation CameraManager

@synthesize session;
@synthesize videoInput;
@synthesize deviceConnectedObserver;
@synthesize deviceDisconnectedObserver;
@synthesize orientation;

- (id) init
{
    self = [super init];
    if (self != nil) {
		__block id weakSelf = self;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
			BOOL sessionHasDeviceWithMatchingMediaType = NO;
			NSString *deviceMediaType = nil;
			if ([device hasMediaType:AVMediaTypeAudio])
                deviceMediaType = AVMediaTypeAudio;
			else if ([device hasMediaType:AVMediaTypeVideo])
                deviceMediaType = AVMediaTypeVideo;
			
			if (deviceMediaType != nil) {
				for (AVCaptureDeviceInput *input in [session inputs])
				{
					if ([[input device] hasMediaType:deviceMediaType]) {
						sessionHasDeviceWithMatchingMediaType = YES;
						break;
					}
				}
				
				if (!sessionHasDeviceWithMatchingMediaType) {
					NSError	*error;
					AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
					if ([session canAddInput:input])
						[session addInput:input];
				}
			}
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
            if ([device hasMediaType:AVMediaTypeVideo]) {
				[session removeInput:[weakSelf videoInput]];
				[weakSelf setVideoInput:nil];
			}
        };
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
		orientation = AVCaptureVideoOrientationPortrait;
        
        _isFlashEnabled = NO;
        
        // add KVO
        int flags = NSKeyValueObservingOptionNew;
        AVCaptureDevice *frontCamera = [self frontFacingCamera];
        AVCaptureDevice *backCamera = [self backFacingCamera];
        [frontCamera addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
        [backCamera addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    }
    
    return self;
}

- (void)deviceOrientationDidChange
{
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

#pragma Public methods
- (BOOL) setupSession:(BOOL) isBack {
    AVCaptureDevice *initDevice = nil;
    if (isBack) {
        initDevice = [self backFacingCamera];
    }   else    {
        initDevice = [self frontFacingCamera];
    }
    
    //default set back camera
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:initDevice error:nil];
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    [self setCustomSessionPreset:newCaptureSession];
    
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    
    // Add audio input
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (audioDevice) {
        AVCaptureDeviceInput * newAudioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
        if ([newCaptureSession canAddInput:newAudioInput]) {
            [newCaptureSession addInput:newAudioInput];
        }
    }
    
    [self setVideoInput:newVideoInput];
    
    [self setSession:newCaptureSession];
    
    [self actionAddStillImageOutput];
    
    [self actionAddMovieFileOutput];
    
    return YES;
}

- (BOOL) toggleCamera {
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        AVCaptureDevice *newDevice = nil;
        AVCaptureDevicePosition position = [[videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack) {
            newDevice = [self frontFacingCamera];
        } else if (position == AVCaptureDevicePositionFront) {
            newDevice = [self backFacingCamera];
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput *newVideoInput = newDevice ? [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:&error] : nil;
        
        if (newVideoInput && !error) {
            [[self session] beginConfiguration];
            [self setDefaultSessionPreset:[self session]];
            [[self session] removeInput:[self videoInput]];
            
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                NSLog(@"Camera Manager - Could not add new camera input");
                [[self session] addInput:[self videoInput]];
            }
            
            [self setCustomSessionPreset:[self session]];
            
            [[self session] commitConfiguration];
            success = YES;
        } else {
            NSLog(@"Camera Manager - Could not create new camera input: %@", error);
        }
    }
    
    if (success == YES && [self.manageDelegate respondsToSelector:@selector(reverseCamera:)]) {
        AVCaptureDevicePosition position = [[videoInput device] position];
        [self.manageDelegate reverseCamera:position];
    }
    return success;
}

- (NSUInteger) cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (void) start  {
    NSLog(@"----------- Camera Start -----------");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self session] startRunning];
    });
}

- (void) stop   {
    NSLog(@"----------- Camera Stop -----------");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self session] stopRunning];
    });
}

- (BOOL) supportFlashOn {
    if ([self checkIfCameraBack])    {
        if ([[self backFacingCamera] hasTorch])   {
            if ([[self backFacingCamera] lockForConfiguration:nil]) {
                if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [[self backFacingCamera] unlockForConfiguration];
                    return YES;
                }
                [[self backFacingCamera] unlockForConfiguration];
            }
        }
    }   else    {
        if ([[self frontFacingCamera] hasTorch])   {
            if ([[self frontFacingCamera] lockForConfiguration:nil]) {
                if ([[self frontFacingCamera] isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [[self frontFacingCamera] unlockForConfiguration];
                    return YES;
                }
                [[self frontFacingCamera] unlockForConfiguration];
            }
        }
    }
    return NO;
}

- (void) flashOn    {
    _isFlashEnabled = YES;
    [self actionSwitchFlash:_isFlashEnabled];
}

- (void) flashOff    {
    _isFlashEnabled = NO;
    [self actionSwitchFlash:_isFlashEnabled];
}

- (BOOL) checkIfCameraBack  {
    return [self actionCheckIfCameraBack];
}

//add burst mode capture
- (void) prepareConnectionForCapturing  {
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				_curCaptureConnection = connection;
				break;
			}
		}
		if (_curCaptureConnection) {
            break;
        }
	}
    
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
	[_curCaptureConnection setVideoOrientation:avcaptureOrientation];
    if (_curCaptureConnection.isVideoMirroringSupported)    {
        _curCaptureConnection.videoMirrored = ![self checkIfCameraBack];
    }
}

#pragma mark - capture new photo
- (void) captureNewPhoto:(NSInteger)index {
    
    NSInteger index2 = index;
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:_curCaptureConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             if (error) {
                                                                 NSLog(@"captureNewPhoto - ERROR: %@", error);
                                                             }
                                                             if (self.captureDelegate) {
                                                                 [self.captureDelegate cameraManagerStillCaptureNewSampleBuffer:imageSampleBuffer withIndex:index2 withError:error];
                                                             }
                                                         }];
}

- (void) captureVideoStart {
    if (!_isMovieRecording) {
        _isMovieRecording = YES;
        
        //Create temporary URL to record to
        NSString *outputPath = [[FlipframeFileService sharedInstance] generateCapturingVideoPath];
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:outputPath])
        {
            NSError *error;
            if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
            {
                //Error - handle if requried
            }
        }
        
        //Start recording
        [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        
        //Start Video Timer
        [self startTimer];
    }
}

- (void) captureVideoEnd {
    if (_isMovieRecording) {
        [self stopTimer];
        [self.movieFileOutput stopRecording];
    }
}

//********** DID FINISH RECORDING TO OUTPUT FILE AT URL **********
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    _isMovieRecording = NO;
    
    // Stop Video Timer
    [self stopTimer];
    
    BOOL isSuccess = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            isSuccess = [value boolValue];
        }
    }
    
    CGFloat duration = CMTimeGetSeconds(captureOutput.recordedDuration);
    if ([self.manageDelegate respondsToSelector:@selector(captureVideoDidFinish:duration:)]) {
        [self.manageDelegate captureVideoDidFinish:outputFileURL duration:duration];
    }
}

- (UIImage*)getVideoThumbnail:(NSURL*)videoUrl {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *imgReturn = [[UIImage alloc] initWithCGImage:imgRef];
    if (![self actionCheckIfCameraBack]) {
        imgReturn = [self flipImage:imgReturn];
    }
    return imgReturn;
}

- (UIImage*)flipImage:(UIImage*)image {
    
    UIImageOrientation imageOrientation;
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
            imageOrientation = UIImageOrientationDownMirrored;
            break;
            
        case UIImageOrientationDownMirrored:
            imageOrientation = UIImageOrientationDown;
            break;
            
        case UIImageOrientationLeft:
            imageOrientation = UIImageOrientationLeftMirrored;
            break;
            
        case UIImageOrientationLeftMirrored:
            imageOrientation = UIImageOrientationLeft;
            
            break;
            
        case UIImageOrientationRight:
            imageOrientation = UIImageOrientationRightMirrored;
            
            break;
            
        case UIImageOrientationRightMirrored:
            imageOrientation = UIImageOrientationRight;
            
            break;
            
        case UIImageOrientationUp:
            imageOrientation = UIImageOrientationUpMirrored;
            break;
            
        case UIImageOrientationUpMirrored:
            imageOrientation = UIImageOrientationUp;
            break;
        default:
            break;
    }
    
    return [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:imageOrientation];
}

#pragma mark - image orientation fix
- (UIImage*)fixrotation:(UIImage*)image {
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/*- (void)cropSquareVideo:(NSURL*)videoUrl completion:(void(^)(NSString*))completion {
    // output file
    NSString *outputPath = [[FlipframeFileService sharedInstance] generateCapturingVideoPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    
    // input file
    AVAsset* asset = [AVAsset assetWithURL:videoUrl];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition  addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // input clip
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    UIInterfaceOrientation videoOrientation = [self orientationForTrack:asset];
    BOOL isPortrait = (videoOrientation == UIInterfaceOrientationPortrait || videoOrientation == UIInterfaceOrientationPortraitUpsideDown) ? YES: NO;
    CGSize videoSize = CGSizeMake(DEF_TWYST_IMAGE_WIDTH, DEF_TWYST_IMAGE_HEIGHT);
    
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = videoSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30) );
    
    // rotate and position video
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    CGAffineTransform transform = [self cropVideoTransform:videoTrack.naturalSize isPortrait:isPortrait];
    [transformer setTransform:transform atTime:kCMTimeZero];
    instruction.layerInstructions = [NSArray arrayWithObject: transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    // export
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL=[NSURL fileURLWithPath:outputPath];
    exporter.outputFileType=AVFileTypeQuickTimeMovie;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        completion(outputPath);
    }];
}

- (CGAffineTransform)cropVideoTransform:(CGSize)naturalSize isPortrait:(BOOL)isPortrait {
    CGFloat scale = 0;
    CGFloat tx = 0;
    CGFloat ty = 0;
    if (naturalSize.width > naturalSize.height) {
        scale = DEF_TWYST_VIDEO_SIZE / naturalSize.height;
        tx = naturalSize.height;
        ty = - (naturalSize.width - naturalSize.height) * scale / 2;
    }
    else {
        scale = DEF_TWYST_VIDEO_SIZE / naturalSize.width;
        tx = naturalSize.width;
        ty = - (naturalSize.height - naturalSize.width) * scale / 2;
    }
    
    CGAffineTransform t1 = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform t2 = CGAffineTransformTranslate(t1, tx, ty);
    if (isPortrait) {
        CGAffineTransform t3 = CGAffineTransformRotate(t2, M_PI_2);
        return t3;
    }
    else {
        return t2;
    }
}

- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset {
    UIInterfaceOrientation videoOrientation = UIInterfaceOrientationPortrait;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            videoOrientation = UIInterfaceOrientationPortrait;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            videoOrientation = UIInterfaceOrientationPortraitUpsideDown;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            videoOrientation = UIInterfaceOrientationLandscapeRight;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            videoOrientation = UIInterfaceOrientationLandscapeLeft;
        }
    }
    return videoOrientation;
}*/

#pragma mark - timer methods
- (void)startTimer {
    if (!_videoTimer) {
        _videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                       target:self
                                                     selector:@selector(onVideoTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
    _videoStart = [NSDate timeIntervalSinceReferenceDate];
}

- (void)stopTimer {
    if (_videoTimer) {
        [_videoTimer invalidate];
        _videoTimer = nil;
    }
}

- (void)onVideoTimer:(NSTimer*)timer {
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - _videoStart;
    [self.manageDelegate captureVideoDuration:duration];
}

#pragma mark - Internal action methods

- (void) actionSwitchFlash: (BOOL) enable {
    AVCaptureTorchMode torchMode = AVCaptureTorchModeOff;
    AVCaptureFlashMode flashMode = AVCaptureFlashModeOff;
    if (enable) {
        torchMode = AVCaptureTorchModeOn;
        flashMode = AVCaptureFlashModeOn;
    }
    if ([self checkIfCameraBack])    {
        if ([[self backFacingCamera] hasFlash])   {
            if ([[self backFacingCamera] lockForConfiguration:nil]) {
                if ([[self backFacingCamera] isFlashModeSupported:flashMode]) {
                    [[self backFacingCamera] setFlashMode:flashMode];
                }
                [[self backFacingCamera] unlockForConfiguration];
            }
        }
    }   else    {
        if ([[self frontFacingCamera] hasFlash])   {
            if ([[self frontFacingCamera] lockForConfiguration:nil]) {
                if ([[self frontFacingCamera] isFlashModeSupported:AVCaptureFlashModeOn]) {
                    [[self frontFacingCamera] setFlashMode:AVCaptureFlashModeOn];
                }
                [[self frontFacingCamera] unlockForConfiguration];
            }
        }
    }
}

- (BOOL) isFlashOn {
    return _isFlashEnabled;
}

- (void) focus:(CGPoint) point  {
    
    AVCaptureDevice *device = [[self videoInput] device];
    
    NSError *error;
    
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus] &&
        [device isFocusPointOfInterestSupported])
    {
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
    
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]
        && [device isExposurePointOfInterestSupported])
    {
        if ([device lockForConfiguration:&error]) {
            [device setExposurePointOfInterest:point];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
}

- (BOOL) actionCheckIfCameraBack  {
    AVCaptureDevicePosition position = [[videoInput device] position];
    if (position == AVCaptureDevicePositionBack)    {
        return YES;
    }
    return NO;
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (void)actionAddStillImageOutput
{
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    [self.session addOutput:[self stillImageOutput]];
}

- (void)actionAddMovieFileOutput
{
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    Float64 TotalSeconds = 6;			//Total seconds
    int32_t preferredTimeScale = 30;	//Frames per second
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
    self.movieFileOutput.maxRecordedDuration = maxDuration;
    
    self.movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;						//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
    
    if ([self.session canAddOutput:self.movieFileOutput])
        [self.session addOutput:self.movieFileOutput];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation avcaptureOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
    {
        avcaptureOrientation  = AVCaptureVideoOrientationLandscapeRight;
    }
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
    {
        avcaptureOrientation  = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if(deviceOrientation == UIDeviceOrientationPortrait)
    {
        avcaptureOrientation = AVCaptureVideoOrientationPortrait;
    }
    else if(deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        avcaptureOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }   else {
       
        avcaptureOrientation = AVCaptureVideoOrientationPortrait;
        
    }
    
    return avcaptureOrientation;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        if (adjustingFocus == NO) {
            if ([self.manageDelegate respondsToSelector:@selector(adjustFocusDidFinish)]) {
                [self.manageDelegate adjustFocusDidFinish];
            }
        }
    }
}


#pragma mark - Video Presets

- (void)setDefaultSessionPreset:(AVCaptureSession *)aSession {
    [aSession setSessionPreset:AVCaptureSessionPreset640x480];
    NSLog(@"Video - Default presets configured");
}

- (void)setCustomSessionPreset:(AVCaptureSession *)aSession {
    if ([aSession canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]) {
        [aSession setSessionPreset:AVCaptureSessionPresetiFrame1280x720];
        NSLog(@"Video - High resolution presets configured");

    } else {
        [aSession setSessionPreset:AVCaptureSessionPreset640x480];
        NSLog(@"Video - Low resolution presets configured");
    }
}

#pragma mark--
@end
