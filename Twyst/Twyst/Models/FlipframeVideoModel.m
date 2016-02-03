//
//  FlipframeVideoModel.m
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FlipframeVideoModel.h"
#import "FlipframeFileService.h"

@implementation FlipframeVideoModel

- (id)initWithType:(FlipframeInputType)inputType
          videoURL:(NSURL*)videoURL
          duration:(CGFloat)duration
         isCapture:(BOOL)isCapture
        isMirrored:(BOOL)isMirrored {
    
    self = [super init];
    if (self)   {
        self.inputType = inputType;
        self.videoURL = videoURL;
        self.duration = duration;
        self.playStartTime = 0;
        self.playEndTime = MIN(duration, DEF_VIDEO_MAX_LEN);
        self.coverFrame = self.playStartTime;
        self.comment = nil;
        self.frameComment = CGRectZero;
        self.imageDrawing = nil;
        self.isCapture = isCapture;
        self.isMirrored = isMirrored;
        
        [self actionRefreshSavedInfo];
    }
    return self;
}

- (BOOL)isDrawingExists {
    return self.imageDrawing ? YES : NO;
}

- (void)serviceCompileFlipframe:(void(^)(NSURL*))completion {
    self.duration = _playEndTime - _playStartTime;
    
    AVAsset *videoAsset = [AVAsset assetWithURL:self.videoURL];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSArray *videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks) {
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                            ofTrack:[videoTracks objectAtIndex:0]
                             atTime:kCMTimeZero error:nil];
    }
    
    NSArray *audioTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
    if ([audioTracks count]) {
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                            ofTrack:[audioTracks objectAtIndex:0]
                             atTime:kCMTimeZero error:nil];
    }
    
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    else if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    else if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    else if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    
    CGAffineTransform preferredTransform = videoAssetTrack.preferredTransform;
    if (self.isMirrored) {
        preferredTransform = CGAffineTransformScale(preferredTransform, 1, -1);
        preferredTransform = CGAffineTransformTranslate(preferredTransform, 0, -preferredTransform.tx);
    }
    [videolayerInstruction setTransform:preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    
    // 4 - Get path
    NSString *filePath = [[FlipframeFileService sharedInstance] generateFinalVideoPath];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPreset960x540];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    exporter.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(_playStartTime, 60), CMTimeMakeWithSeconds(_playEndTime - _playStartTime, 60));
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exporter.status;
            if (status == AVAssetExportSessionStatusCompleted) {
                self.duration = _playEndTime - _playStartTime;
                completion(exporter.outputURL);
                [self saveVideoToCameraRoll:exporter];
            }
            else {
                completion(nil);
            }
        });
    }];
}

- (void)saveVideoToCameraRoll:(AVAssetExportSession*)session {
    if ([[Global getConfig] isSaveVideo]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSURL *outputURL = session.outputURL;
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
                [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
                        NSLog(@"save video failed");
                    } else {
                        NSLog(@"save video success");
                    }
                }];
            }
        });
    }
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)videoSize
{
    if (self.imageDrawing == nil && self.comment == nil) {
        return;
    }
    
    CGRect overlayRect = CGRectZero;
    if ((DEF_TWYST_VIDEO_WIDTH / DEF_TWYST_VIDEO_HEIGHT) / (videoSize.width / videoSize.height)) {
        float ratio = videoSize.width / DEF_TWYST_VIDEO_WIDTH;
        float y = (videoSize.height - DEF_TWYST_VIDEO_HEIGHT * ratio) / 2;
        overlayRect = CGRectMake(0, y, videoSize.width, DEF_TWYST_VIDEO_HEIGHT * ratio);
    }
    else {
        float ratio = videoSize.height / DEF_TWYST_VIDEO_HEIGHT;
        float x = (videoSize.width - DEF_TWYST_VIDEO_WIDTH * ratio) / 2;
        overlayRect = CGRectMake(x, 0,  DEF_TWYST_VIDEO_WIDTH * ratio, videoSize.height);
    }
    
    UIImage * overlayImage = [FlipframeUtils generateVideoOverlay:overlayRect.size drawing:self.imageDrawing comment:self.comment frame:self.frameComment];
    // 1 - set up the overlay
    CALayer *overlayLayer = [CALayer layer];
    
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    overlayLayer.frame = overlayRect;
    [overlayLayer setMasksToBounds:YES];
    
    // 2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 3 - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                 inLayer:parentLayer];
}

- (void) actionRefreshSavedInfo {
    self.savedInfo = [[FlipframeSavedInfo alloc] init];
    self.savedInfo.folderPath = [[FlipframeFileService sharedInstance] generateRegularFolderPath];
}

@end
