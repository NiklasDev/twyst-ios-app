//
//  TwystDownloadQueue.h
//  Twyst
//
//  Created by Lucas Pelizza on 7/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwystDownloadQueue : NSObject

- (id) initWithSuccessNotification:(NSString*)successNotification andFailNotification:(NSString*)failNotification isPriorityQueue:(BOOL)isPriorityQueue;
- (void) checkReplyAndDownload;

- (void)downloadTwyst:(Twyst*)twyst isUrgent:(BOOL)isUrgent;
- (BOOL) isDownloading;

@end