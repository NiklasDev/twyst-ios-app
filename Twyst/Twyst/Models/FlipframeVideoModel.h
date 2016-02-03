//
//  FlipframeVideoModel.h
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipframeModel.h"

@interface FlipframeVideoModel : FlipframeModel

- (id)initWithType:(FlipframeInputType)inputType
          videoURL:(NSURL*)videoURL
          duration:(CGFloat)duration
         isCapture:(BOOL)isCapture
        isMirrored:(BOOL)isMirrored;

@property (nonatomic, retain) NSURL *videoURL;
@property (nonatomic, assign) BOOL isCapture;
@property (nonatomic, assign) BOOL isMirrored;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat playStartTime;
@property (nonatomic, assign) CGFloat playEndTime;
@property (nonatomic, assign) CGFloat coverFrame;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, assign) CGRect frameComment;
@property (nonatomic, retain) UIImage *imageDrawing;
@property (nonatomic, retain) NSString *finalPath;

- (BOOL)isDrawingExists;
- (void)serviceCompileFlipframe:(void(^)(NSURL*))completion;

@end
