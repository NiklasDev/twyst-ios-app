//
//  TwystVideoEncoderService.m
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipframeVideoEncoderService.h"
#import <AVFoundation/AVFoundation.h>
#import "FlipagramTransition.h"
#import "FlipframePhotoModel.h"

@interface FlipframeVideoEncoderService()  {
    AVAssetWriter *_videoWriter ;
    AVAssetWriterInput* _writerInput;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    
    FlipagramTransition *_transition;
    CMTime _currentFrameTime;
    
    //new queue
    dispatch_queue_t _queueMovieWriting;
    BOOL _videoEncodingIsFinished;
    BOOL _isCanceling;
    CGSize _videoSize;
    
    //process delegate
    NSInteger _totalFps;
}

@end

@implementation FlipframeVideoEncoderService

static id _instance;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_instance)  {
            _instance = [[FlipframeVideoEncoderService alloc] init];
        }
        return _instance;
    }
}

- (id) init {
    self = [super init];
    if (self)   {
        _queueMovieWriting = dispatch_queue_create("com.flipframe.FlipframeVideoEncoderService-queue", NULL);
    }
    return self;
}

- (void) createFlipframeInputDelegate:(FlipframeRecoredEncoderDelegate*) inInputDelegate withComplete:(void (^)(NSString *videoPath)) completion  {
    self.inputDelegate = inInputDelegate;
    _videoSize = [self.inputDelegate videoSize];
    _transition = [[FlipagramTransition alloc] init];
    [_transition startVideoWithSize:_videoSize];
    
    _videoEncodingIsFinished = NO;
    _isCanceling = NO;
    //step one
    NSError *error2;
    [self write:&error2 complete:completion];
}

#pragma Internal Methods
-(void)setUpVideoWriterWithFrameSize : (CGSize) frameSize error : (NSError**) error;
{
    NSString *savePath = [self videoEncoderGetVideoPath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:savePath])    {
        [fileMgr removeItemAtPath: savePath error:error];
    }
    NSLog(@"start new video: %@", savePath);
    error = nil;
    _videoWriter = [[AVAssetWriter alloc] initWithURL:
                    [NSURL fileURLWithPath:savePath] fileType:AVFileTypeMPEG4
                                                error:error];
    
    if(error) {
        return;
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    
    
    _writerInput = [AVAssetWriterInput
                    assetWriterInputWithMediaType:AVMediaTypeVideo
                    outputSettings:videoSettings];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    _adaptor = [AVAssetWriterInputPixelBufferAdaptor
                assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_writerInput
                sourcePixelBufferAttributes:attributes];
    
    [_videoWriter addInput:_writerInput];
    
    // fixes all errors
    _writerInput.expectsMediaDataInRealTime = YES;
    
    //Start a session:
    [_videoWriter startWriting];
    
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
    
}

- (void) cancelEncode   {
    _isCanceling = YES;
    _videoEncodingIsFinished = YES;
    if (_videoWriter.status == AVAssetWriterStatusCompleted)
    {
        return;
    }
    dispatch_sync(_queueMovieWriting, ^{
        if( _videoWriter.status == AVAssetWriterStatusWriting && _videoEncodingIsFinished)
        {
            [_writerInput markAsFinished];
        }
        [_videoWriter cancelWriting];
    });
}

-(void)write:(NSError **)error  complete:(void (^)())complete   {

    //start write
    NSInteger totalFrames = [self videoEncoderGetTotalFrames];
    CGSize frameSize = _videoSize;
    
    //for process
    self.currentFps = 0;
    _totalFps = totalFrames * 10;
    
    
    if( ((int)frameSize.width % 16) != 0)
    {
        int w = ((int)frameSize.width / 16 - 1)*16;
        int h = frameSize.height * w / frameSize.width;
        frameSize.width = w;
        frameSize.height = h;
    }
    
    int heightInt = (int) frameSize.height;
    if (heightInt % 2 != 0) {
        heightInt --;
    }
    frameSize.height = heightInt;
    
    NSLog(@"encoder framesize: %@", NSStringFromCGSize(frameSize));
    
    [self setUpVideoWriterWithFrameSize:frameSize error:error];     // create mp4 file to local
    
    _currentFrameTime = kCMTimeZero;
    _currentFrameTime.timescale = 20;
    
    int skipFrame = 1;//default one by one, because skip 5 frames when decode
    
    dispatch_async(_queueMovieWriting, ^{
        CVPixelBufferRef buffer = nil;
        int index = 0;
        while (index < totalFrames) {
            //check if last frame
            NSLog(@"index: %d", index);
            @autoreleasepool {
                //append opacity image
                UIImage *image = [self actionVideoEncoderGetEffectImage:index];
                [_transition loadImage:image];
                buffer = [_transition pixelBuffer];
                
                while (_currentFps < (index + 1) * 10) {
                    [self appendImageBufferToAdaptor:buffer];
                    _currentFps++;
                }
                
                if(buffer) {
                    CVBufferRelease(buffer);
                    buffer = nil;
                }
                index += skipFrame;
            }
        }
        _transition = nil;
    });
    
    dispatch_async(_queueMovieWriting, ^{
        if (!_isCanceling)   {
            _videoEncodingIsFinished = YES;
            [_writerInput markAsFinished];
            [_videoWriter endSessionAtSourceTime:_currentFrameTime];
            [_videoWriter finishWritingWithCompletionHandler:^{
                //save to camera roll
                complete([self videoEncoderGetVideoPath]);
                if (self.processDelegate)   {
                    [self.processDelegate flipframeVideoEncoderCcompletAllImages];
                }
            }];
        }
    });
}

- (void) appendImageBufferToAdaptor:(CVPixelBufferRef) buffer   {
    //NSLog(@"-s-append");
    while (!_adaptor.assetWriterInput.readyForMoreMediaData) {
        [NSThread sleepForTimeInterval:0.01];
    }
    if (!_isCanceling)   {
        BOOL result = [_adaptor appendPixelBuffer:buffer withPresentationTime:_currentFrameTime];
        //CMTimeShow(_currentFrameTime);
        if (result == NO) //failes on 3GS, but works on iphone 4
            NSLog(@"failed to append buffer");
        _currentFrameTime.value ++;
        
        //update
        self.currentFps ++;
        if (self.processDelegate)   {
            [self.processDelegate flipframeVideoEncoderCompleteSingleFPS:self.currentFps withTotal:_totalFps];
        }
    }
}
#pragma mark --


#pragma DataSource
- (NSString*) videoEncoderGetVideoPath  {
    return [self.inputDelegate pathVideoOutput];
}

- (NSInteger) videoEncoderGetTotalFrames
{
    return [self.inputDelegate totalImages];
}

- (UIImage*) actionVideoEncoderGetEffectImage:(int)index {
    UIImage *image  = [self.inputDelegate videoEncoderGetEffectImage:index];
    return image;
}

@end
