//
//  TwystDownloadService.h
//  Twyst
//
//  Created by Niklas Ahola on 9/1/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSavedTwyst.h"

@interface TwystDownloadService : NSObject

+ (id) sharedInstance;

- (void)startDownloadService;
- (void)stopDownloadService;

- (void)downloadTwyst:(Twyst*)twyst isUrgent:(BOOL)isUrgent;
- (void)downloadFriendTwyst:(Twyst*)twyst isUrgent:(BOOL)isUrgent;
- (void)addReplySuccess:(long)twystId flipFrameModel:(FlipframePhotoModel*)flipFrameModel fileName:(NSString*)fileName twyst:(Twyst*)twyst;
- (void)addReplyVideoSuccess:(long)twystId flipFrameModel:(FlipframeVideoModel*)flipFrameModel fileName:(NSString*)fileName twyst:(Twyst*)twyst;

@end

