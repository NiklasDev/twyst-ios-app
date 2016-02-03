//
//  TwystVideoEncoderService.h
//  Twyst
//
//  Created by Niklas Ahola on 3/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlipframeRecoredEncoderDelegate.h"

@protocol FlipframeVideoEncoderServiceProcessDelegate <NSObject>

- (void) flipframeVideoEncoderCompleteSingleFPS:(NSInteger)currectFps withTotal:(NSInteger) totalFps;
- (void) flipframeVideoEncoderCcompletAllImages;

@end

@interface FlipframeVideoEncoderService : NSObject

@property (nonatomic, assign) id <FlipframeVideoEncoderServiceProcessDelegate> processDelegate;
@property (nonatomic, retain) FlipframeRecoredEncoderDelegate *inputDelegate;
@property (nonatomic, assign) int currentFps;

- (void) createFlipframeInputDelegate:(FlipframeRecoredEncoderDelegate*) inInputDelegate withComplete:(void (^)(NSString *videoPath)) completion;
- (void) cancelEncode;

+ (id) sharedInstance;

@end
