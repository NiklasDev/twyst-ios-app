//
//  TwystInputService.m
//  Twyst
//
//  Created by Niklas Ahola on 3/25/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "PhotoHelper.h"
#import "FlipframeFileService.h"
#import "FlipframeInputService.h"

@implementation FlipframeInputService
- (id) init {
    self = [super init];
    if (self)   {
        self.arrFullImagePaths = [[NSMutableArray alloc] init];
        self.arrThumbPaths = [[NSMutableArray alloc] init];
        self.arrFinalImagePaths = [[NSMutableArray alloc] init];
        self.isNotify = NO;
    }
    return self;
}

- (void) startNotify    {
    self.isNotify = YES;
}

- (void) resetAll   {
    self.totalImages = 0;
    self.isNotify = NO;
    [self.arrFullImagePaths removeAllObjects];
    [self.arrThumbPaths removeAllObjects];
}

- (UIImage *)getSinglePhotoAtIndex:(NSInteger)index {
    NSString *fullPath = [_arrFullImagePaths objectAtIndex:index];
    UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
    return image;
}

- (UIImage *)getFinalPhotoAtIndex:(NSInteger)index {
    NSString *finalPath = [_arrFinalImagePaths objectAtIndex:index];
    UIImage *image = [UIImage imageWithContentsOfFile:finalPath];
    return image;
}

- (void) replaceImageAtIndex:(NSInteger)index newImage:(UIImage*)newImage {
    @autoreleasepool {
        NSString *pathFull = [self.arrFullImagePaths objectAtIndex:index];
        NSString *pathThumb = [self.arrThumbPaths objectAtIndex:index];
        
        [FlipframeUtils deleteFileOrFolder:pathFull];
        [FlipframeUtils deleteFileOrFolder:pathThumb];
        
        NSData *rawDataImageFull = UIImageJPEGRepresentation(newImage, DEF_FRAME_COMPRESSION_RATE);
        [rawDataImageFull writeToFile:pathFull atomically:YES];
        
        UIImage *rawImageThumb = [PhotoHelper actionMakeThumbImage:newImage];
        NSData *rawDataImageThumb = UIImageJPEGRepresentation(rawImageThumb, DEF_FRAME_COMPRESSION_RATE);
        [rawDataImageThumb writeToFile:pathThumb atomically:YES];
    }
}

- (void) finalizeImageWithIndex:(NSInteger)index image:(UIImage*)image {
    @autoreleasepool {
        NSString *pathFinal = [[FlipframeFileService sharedInstance] generateFinalFilePath:index];

        NSData *rawDataImageFull = UIImageJPEGRepresentation(image, 1.0f);

        if (index < self.arrFinalImagePaths.count) {
            [FlipframeUtils deleteFileOrFolder:pathFinal];
            [rawDataImageFull writeToFile:pathFinal atomically:YES];
            [self.arrFinalImagePaths replaceObjectAtIndex:index withObject:pathFinal];
        }
        else {
            [rawDataImageFull writeToFile:pathFinal atomically:YES];
            [self.arrFinalImagePaths addObject:pathFinal];
        }
    }
}

@end
