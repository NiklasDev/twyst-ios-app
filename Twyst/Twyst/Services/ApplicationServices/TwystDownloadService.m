//
//  TwystDownloadService.m
//  Twyst
//
//  Created by Niklas Ahola on 9/1/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <zipzap/zipzap.h>

#import "TSavedTwystManager.h"


#import "FlipframeFileService.h"
#import "TwystDownloadService.h"
#import "TwystDownloadQueue.h"

@interface TwystDownloadService() {
    FlipframeFileService *_fileService;
    
    TwystDownloadQueue * twystQueue;
    TwystDownloadQueue * principalTwystQueue;
    
    TwystDownloadQueue * friendTwystQueue;
    TwystDownloadQueue * principalFriendTwystQueue;
    
    NSTimer * _timer;
}

@end

@implementation TwystDownloadService

#pragma static singleton
static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

- (id) init {
    self = [super init];
    if (self) {
        // Custom Initialization
        _fileService = [FlipframeFileService sharedInstance];
        
        twystQueue = [[TwystDownloadQueue alloc] initWithSuccessNotification:kTwystDidDownloadNotification
                                                         andFailNotification:kTwystDownloadFailNotification
                                                             isPriorityQueue:NO];
        
        friendTwystQueue = [[TwystDownloadQueue alloc] initWithSuccessNotification:kFriendTwystDidDownloadNotification
                                                               andFailNotification:kFriendTwystDownloadFailNotification
                                                                   isPriorityQueue:NO];

        principalTwystQueue = [[TwystDownloadQueue alloc] initWithSuccessNotification:kTwystDidDownloadNotification
                                                         andFailNotification:kTwystDownloadFailNotification
                                                             isPriorityQueue:YES];
        principalFriendTwystQueue = [[TwystDownloadQueue alloc] initWithSuccessNotification:kFriendTwystDidDownloadNotification
                                                               andFailNotification:kFriendTwystDownloadFailNotification
                                                                   isPriorityQueue:YES];
    }
    return self;
}

#pragma mark - public methods
- (void)startDownloadService {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(handleDownloadTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)stopDownloadService {
    [_timer invalidate];
    _timer = nil;
}


- (void) downloadTwyst:(Twyst*)twyst isUrgent:(BOOL)isUrgent {
    @synchronized(self) {
        if (isUrgent) {
            [principalTwystQueue downloadTwyst:twyst isUrgent:true];
        }else{
            [twystQueue downloadTwyst:twyst isUrgent:false];
        }
    }
}

- (void)downloadFriendTwyst:(Twyst*)twyst isUrgent:(BOOL)isUrgent {
    @synchronized(self) {
        if (isUrgent) {
            [principalFriendTwystQueue downloadTwyst:twyst isUrgent:true];
        }else{
            [friendTwystQueue downloadTwyst:twyst isUrgent:false];
        }
    }
}

- (void)addReplySuccess:(long)twystId flipFrameModel:(FlipframePhotoModel*)flipFrameModel fileName:(NSString*)fileName twyst:(Twyst*)twyst {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:twystId];
        if (savedTwyst) {
            NSString *folderPath = [_fileService generateSavedTwystFolderPath:twystId];
            folderPath = [folderPath stringByAppendingPathComponent:fileName];
            [FlipframeUtils checkAndCreateDirectory:[_fileService generateFullDocPath:folderPath]];
            NSInteger totalFrames = [flipFrameModel totalFrames];
            NSMutableArray *arrPaths = [[NSMutableArray alloc] initWithCapacity:totalFrames];
            for (NSInteger i = 0; i < totalFrames; i++) {
                NSString *sourcePath = [[[flipFrameModel inputService] arrFinalImagePaths] objectAtIndex:i];
                NSString *destPath = [folderPath stringByAppendingFormat:@"/%ld.jpg", (long)i];
                NSString *fullPath = [_fileService generateFullDocPath:destPath];
                [FlipframeUtils moveFile:sourcePath toDesc:fullPath];
                [arrPaths addObject:destPath];
            }
            if ([[TSavedTwystManager sharedInstance] addReplyToSavedTwyst:twystId arrPaths:arrPaths isMovie:NO frameTime:flipFrameModel.frameTime]) {
                [Global postTwystDidReplyNotification:twyst];
            }
        }
    });
}

- (void)addReplyVideoSuccess:(long)twystId flipFrameModel:(FlipframeVideoModel*)flipFrameModel fileName:(NSString*)fileName twyst:(Twyst*)twyst {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:twystId];
        if (savedTwyst) {
            NSString *folderPath = [_fileService generateSavedTwystFolderPath:twystId];
            folderPath = [folderPath stringByAppendingPathComponent:fileName];
            [FlipframeUtils checkAndCreateDirectory:[_fileService generateFullDocPath:folderPath]];
            NSMutableArray *arrPaths = [[NSMutableArray alloc] initWithCapacity:1];
            NSString *sourcePath = flipFrameModel.finalPath;
            NSString *destPath = [folderPath stringByAppendingPathComponent:@"movie.mp4"];
            NSString *fullPath = [_fileService generateFullDocPath:destPath];
            [FlipframeUtils moveFile:sourcePath toDesc:fullPath];
            [arrPaths addObject:destPath];
            if ([[TSavedTwystManager sharedInstance] addReplyToSavedTwyst:twystId arrPaths:arrPaths isMovie:YES frameTime:flipFrameModel.frameTime]) {
                [Global postTwystDidReplyNotification:twyst];
            }
        }
    });
}

#pragma mark - internal methods

- (void) handleDownloadTimer:(NSTimer*)timer {
    if ( ![principalTwystQueue isDownloading]) {
        [principalTwystQueue checkReplyAndDownload];
    }
    if ( ![twystQueue isDownloading] && ![principalTwystQueue isDownloading]) {
        [twystQueue checkReplyAndDownload];
    }
    if ( ![principalFriendTwystQueue isDownloading]) {
        [principalFriendTwystQueue checkReplyAndDownload];
    }
    if ( ![friendTwystQueue isDownloading] && ![principalFriendTwystQueue isDownloading]) {
        [friendTwystQueue checkReplyAndDownload];
    }
}

@end
