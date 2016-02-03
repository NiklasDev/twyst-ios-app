//
//  PhotoHelper.h
//  Twyst
//
//  Created by Niklas Ahola on 4/6/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PhotoHelper : NSObject

+ (void) cropAndSave:(CMSampleBufferRef)sampleBuffer withPathFull:(NSString*)pathFull withPathThumb:(NSString*) pathThumb inQueue:(dispatch_queue_t) queuePhotos completion:(void (^)(UIImage *)) completion;
+ (void) cropAndSave_iPhone4:(CMSampleBufferRef)sampleBuffer withPathFull:(NSString*)pathFull withPathThumb:(NSString*) pathThumb inQueue:(dispatch_queue_t) queuePhotos completion:(void (^)(UIImage *)) completion;

+ (UIImage*) actionMakeFullImage:(UIImage*)image;
+ (UIImage*) actionMakeThumbImage:(UIImage*)image;

+ (UIImage*) thumbImageFromVideoPath:(NSString*)videoPath;
+ (UIImage*) thumbImageFromImagePath:(NSString*)imagePath;
+ (UIImage*) resizeImage:(UIImage*)srcImage size:(CGSize)size;
+ (UIImage*) cropSquareImage:(UIImage*)srcImage size:(CGFloat)size;
+ (UIImage*) cropCoverImage:(UIImage*)srcImage;
+ (UIImage*) cropCircleImage:(UIImage*)srcImage size:(CGSize)size;
+ (UIImage*) cropImage:(UIImage*)srcImage size:(CGSize)size;

+ (CGSize) getSizeFull;
+ (CGSize) getSizeThumb;

@end
