//
//  TwystQueueDownload.m
//  Twyst
//
//  Created by Lucas Pelizza on 7/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <zipzap/zipzap.h>

#import "Twyst.h"
#import "TTwystOwnerManager.h"
#import "TStillframeRegular.h"
#import "TSavedTwystManager.h"

#import "UserWebService.h"
#import "FlipframeFileService.h"
#import "TwystDownloadQueue.h"

@interface TwystDownloadQueue() {
    FlipframeFileService *_fileService;
    UserWebService *_webService;
    BOOL _isDownloading;
    NSMutableArray *_downloadItemsQueue;
    
    BOOL _isPriority;

    NSString * _twystDidDownloadNotification;
    NSString * _twystDownloadDidFailNotification;
}

@end

@implementation TwystDownloadQueue

- (id) initWithSuccessNotification:(NSString*)successNotification andFailNotification:(NSString*)failNotification isPriorityQueue:(BOOL)isPriorityQueue{
    self = [super init];
    if (self) {
        // Custom Initialization
        _webService = [UserWebService sharedInstance];
        _fileService = [FlipframeFileService sharedInstance];
        
        _downloadItemsQueue = [NSMutableArray new];
        _isDownloading = NO;
        _twystDidDownloadNotification =  successNotification;
        _twystDownloadDidFailNotification = failNotification;
        _isPriority = isPriorityQueue;
    }
    return self;
}

- (BOOL) isDownloading{
    return _isDownloading;
}

- (void) downloadTwyst:(Twyst*)twyst isUrgent:(BOOL)isUrgent{
    @synchronized(self) {
        for (Twyst *queueTwyst in _downloadItemsQueue) {
            if (queueTwyst.Id == twyst.Id) {
                if (isUrgent) {
                    [_downloadItemsQueue removeObject:queueTwyst];
                    [_downloadItemsQueue insertObject:queueTwyst atIndex:0];
                }
                return;
            }
        }
        
        if (isUrgent) {
            [_downloadItemsQueue insertObject:twyst atIndex:0];
        }
        else {
            [_downloadItemsQueue addObject:twyst];
        }
    }
}

- (void) checkReplyAndDownload {
    if (_downloadItemsQueue.count && !_isDownloading) {
        _isDownloading = YES;
        
        
        Twyst *twyst = [_downloadItemsQueue firstObject];
        [_downloadItemsQueue removeObject:twyst];
        
        [_webService getTwystReplies:twyst.Id completion:^(NSArray *replies) {
            if (!replies) {
                [self handleTwystDownloadDidFail:twyst];
                _isDownloading = NO;
            }
            else {
                // check if all replies are downloaded
                long replyCount = [replies count];
                TSavedTwyst *savedTwyst = [[TSavedTwystManager sharedInstance] savedTwystWithTwystId:twyst.Id];
                NSMutableArray *arrZipNames = [[NSMutableArray alloc] init];
                
                if (savedTwyst) {
                    NSSet *setStillframes = savedTwyst.listStillframeRegular;
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
                    NSArray *frames = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                    for (TStillframeRegular *stillFrame in frames) {
                        NSString *zipName = [[stillFrame.path stringByDeletingLastPathComponent] lastPathComponent];
                        if (![arrZipNames containsObject:zipName]) {
                            [arrZipNames addObject:zipName];
                        }
                    }
                    
                    NSInteger savedZipCount = [arrZipNames count];
                    if (replyCount <= savedZipCount) {
                        _isDownloading = NO;
                        
                        [self handleTwystDidDownload:twyst];
                        return;
                    }
                }
                
                // download replies to local
                NSLog(@"====> reply frame download start twyst Id = %ld <=====", twyst.Id);
                int priorityNumber = DISPATCH_QUEUE_PRIORITY_DEFAULT;
                if (_isPriority) {
                    priorityNumber = DISPATCH_QUEUE_PRIORITY_HIGH;
                }
                dispatch_async(dispatch_get_global_queue( priorityNumber, 0), ^{
                    NSString *folderPath = [_fileService generateSavedTwystFolderPath:twyst.Id];
                    NSMutableArray *arrFrames = [[NSMutableArray alloc] init];
                    for (long i = 0; i < replyCount; i++) {
                        
                        //save replier information
                        NSDictionary *reply = [replies objectAtIndex:i];
                        NSDictionary *replier = [reply objectForKey:@"OCUser_userid"];
                        [[TTwystOwnerManager sharedInstance] confirmTwystOwnerWithUserDict:replier];
                        
                        //download reply
                        NSString *zipName = [[reply objectForKey:@"ImageName"] stringByDeletingPathExtension];
                        if ([arrZipNames containsObject:zipName]) {
                            NSSet *setStillframes = savedTwyst.listStillframeRegular;
                            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
                            NSArray *frames = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                            for (TStillframeRegular *stillFrame in frames) {
                                NSRange range = [stillFrame.path rangeOfString:zipName];
                                if (range.length > 0) {
                                    NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:stillFrame.path, @"path",
                                                           stillFrame.userId, @"userId",
                                                           stillFrame.isMovie, @"isMovie",
                                                           [NSNumber numberWithLong:i], @"replyIndex",
                                                           stillFrame.frameTime, @"frameTime",
                                                           nil];
                                    [arrFrames addObject:frame];
                                }
                            }
                        }
                        else {
                            NSString *replyPath = [folderPath stringByAppendingPathComponent:zipName];
                            NSString *fullReplyPath = [_fileService generateFullDocPath:replyPath];
                            [FlipframeUtils deleteFolder:fullReplyPath];
                            [FlipframeUtils checkAndCreateDirectory:fullReplyPath];
                            
                            BOOL isMovie = [[reply objectForKey:@"isMovie"] boolValue];
                            NSInteger frameTime = [[reply objectForKey:@"ViewLength"] integerValue];
                            
                            if (isMovie) { // is video
                                @autoreleasepool {
                                    NSURL *movieUrl = TwystReplyMovieURL(zipName);
                                    NSData *movieData = [NSData dataWithContentsOfURL:movieUrl];
                                    NSLog(@"====> reply movie size = %ld, url = %@ <====", (long)movieData.length, movieUrl.absoluteString);
                                    if (movieData) {
                                        NSString *fileName = @"movie.mp4";
                                        NSString *newImagePath = [replyPath stringByAppendingPathComponent:fileName];
                                        NSString *fullPath = [_fileService generateFullDocPath:newImagePath];
                                        [_fileService saveDataToPath:movieData path:fullPath];
                                        
                                        
                                        
                                        NSNumber *replierId = [replier objectForKey:@"Id"];
                                        NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:newImagePath, @"path",
                                                               replierId, @"userId",
                                                               [NSNumber numberWithBool:YES], @"isMovie",
                                                               [NSNumber numberWithLong:i], @"replyIndex",
                                                               [NSNumber numberWithInteger:frameTime], @"frameTime",
                                                               nil];
                                        [arrFrames addObject:frame];
                                    }
                                    else {
                                        [arrFrames removeAllObjects];
                                        break;
                                    }
                                }
                            }
                            else { // is photo
                                @autoreleasepool {
                                    NSURL *zipURL = TwystReplyZipURL(zipName);
                                    NSData *zipData = [NSData dataWithContentsOfURL:zipURL];
                                    NSLog(@"====> reply zip size = %ld, url = %@ <====", (long)zipData.length, zipURL.absoluteString);
                                    if (zipData) {
                                        ZZArchive* oldArchive = [ZZArchive archiveWithData:zipData error:nil];
                                        for (ZZArchiveEntry* firstArchiveEntry1 in oldArchive.entries)  {
                                            NSLog(@"The size is %lu bytes.", (unsigned long)firstArchiveEntry1.uncompressedSize);
                                            NSString *fileName = firstArchiveEntry1.fileName;
                                            NSString *newImagePath = [replyPath stringByAppendingPathComponent:fileName];
                                            NSString *fullPath = [_fileService generateFullDocPath:newImagePath];
                                            NSError *error;
                                            @autoreleasepool {
                                                NSData *zipData = [firstArchiveEntry1 newDataWithError:&error];
                                                if (!error)  {
                                                    [_fileService saveDataToPath:zipData path:fullPath];
                                                }
                                            }
                                            
                                            NSNumber *replierId = [replier objectForKey:@"Id"];
                                            NSDictionary *frame = [NSDictionary dictionaryWithObjectsAndKeys:newImagePath, @"path",
                                                                   replierId, @"userId",
                                                                   [NSNumber numberWithBool:NO], @"isMovie",
                                                                   [NSNumber numberWithLong:i], @"replyIndex",
                                                                   [NSNumber numberWithInteger:frameTime], @"frameTime",
                                                                   nil];
                                            [arrFrames addObject:frame];
                                        }
                                    }
                                    else {
                                        [arrFrames removeAllObjects];
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    
                    if (arrFrames.count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[TSavedTwystManager sharedInstance] confirmDownloadedTwyst:twyst arrFrames:arrFrames];
                        });
                        
                        NSLog(@"====> reply frame download finished twyst Id = %ld <=====", twyst.Id);
                        [self handleTwystDidDownload:twyst];
                    }
                    else {
                        NSLog(@"====> reply frame download failed twyst Id = %ld <=====", twyst.Id);
                        [self handleTwystDownloadDidFail:twyst];
                    }
                    
                    _isDownloading = NO;
                });
            }
        }];
    }
}

- (void) handleTwystDidDownload:(Twyst*)twyst {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{@"Twyst":twyst};
        [[NSNotificationCenter defaultCenter] postNotificationName:_twystDidDownloadNotification object:nil userInfo:userInfo];
    });
}

- (void) handleTwystDownloadDidFail:(Twyst*)twyst {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{@"Twyst":twyst};
        [[NSNotificationCenter defaultCenter] postNotificationName:_twystDownloadDidFailNotification object:nil userInfo:userInfo];
    });
}
@end
