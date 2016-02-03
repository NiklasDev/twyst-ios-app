//
//  TwystRecoredEncoderDelegate.m
//  Twyst
//
//  Created by Niklas Ahola on 5/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipframeRecoredEncoderDelegate.h"

@interface FlipframeRecoredEncoderDelegate()    {
    FlipframePhotoModel *_flipframeModel;
    dispatch_queue_t _queue;
}
@end

@implementation FlipframeRecoredEncoderDelegate
- (id) initWithPhotoModel:(FlipframePhotoModel*) flipframeModel   {
    self = [super init];
    if (self)   {
        _flipframeModel = flipframeModel;
        _queue = dispatch_queue_create("com.flipframe.FlipframeRecoredEncoderDelegate-queue", NULL);
    }
    return self;
}

#pragma delegate
- (NSInteger) totalImages {
    return _flipframeModel.totalFrames;
}

- (CGSize) videoSize    {
    return _flipframeModel.videoSize;
}

- (NSString*) pathVideoOutput   {
    return _flipframeModel.pathVideoOutput;
}

- (UIImage*) videoEncoderGetEffectImage:(NSInteger) index {
    UIImage *image = [_flipframeModel serviceGetFinalImageAtIndex:index];
    return image;
}

- (NSString*) actionGetFilePath:(NSInteger) index {
    NSString *fileName = [NSString stringWithFormat:@"%ld.jpg",(long)index];
    return [_flipframeModel.savedInfo.folderPath stringByAppendingPathComponent:fileName];
}

@end
