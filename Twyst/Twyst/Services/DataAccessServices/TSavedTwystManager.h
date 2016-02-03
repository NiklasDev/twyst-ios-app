//
//  TSavedTwystManager.h
//  Twyst
//
//  Created by Niklas Ahola on 9/1/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataManager.h"

#import "Twyst.h"
#import "TSavedTwyst.h"

@interface TSavedTwystManager : DataManager

- (TSavedTwyst*)savedTwystWithTwystId:(long)twystId;
- (BOOL)isSavedTwystWithTwystId:(long)twystId;

- (TSavedTwyst*) confirmSavedTwyst:(Twyst*)twyst arrFrames:(NSArray*)arrFrames;
- (TSavedTwyst*) confirmDownloadedTwyst:(Twyst*)twyst arrFrames:(NSArray*)arrFrames;

- (Twyst*)getTwystFromTSavedTwyst:(TSavedTwyst*)savedTwyst;
- (void) deleteSavedTwyst:(TSavedTwyst*)savedTwyst;

- (TSavedTwyst*)addReplyToSavedTwyst:(long)twystId arrPaths:(NSArray*)arrPaths isMovie:(BOOL)isMovie frameTime:(NSInteger)frameTime;

- (NSInteger)getTwystReplyCount:(TSavedTwyst*)savedTwyst;
- (void)checkReplyAndDownload:(TSavedTwyst*)savedTwyst completion:(void(^)(BOOL isDownloaded, NSArray *replies))completion;
- (NSMutableArray*)filterReportedReplies:(NSArray*)replies;

@end
