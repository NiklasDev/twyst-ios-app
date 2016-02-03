//
//  FlipagramTransition.m
//  Twyst
//
//  Created by Niklas Ahola on 9/3/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipagramTransition.h"

@implementation FlipagramTransition

- (void) startVideoWithSize:(CGSize) size {
    self.videoSize = size;
}

- (void) loadImage:(UIImage*)image   {
    self.image = image;
}

- (CVPixelBufferRef) pixelBuffer    {
    NSLog(@"--ss--pixelBuffer: %d", self.fpsIndex);
    
    CGRect rectBg = CGRectMake(0, 0, self.videoSize.width, self.videoSize.height);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, self.videoSize.width,
                                          self.videoSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)(options),
                                          &pxbuffer);
    status=status;//Added to make the stupid compiler not show a stupid warning.
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGBitmapInfo bitmapInfo = (CGBitmapInfo) kCGImageAlphaNoneSkipFirst;
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,  self.videoSize.width,  self.videoSize.height, 8, 4* self.videoSize.width, rgbColorSpace, bitmapInfo);
    //NSParameterAssert(context);
    
    //fill background 131313
    float colorRGB = DEF_VIDEO_ENCODER_STRIP;
    UIColor *colorBg = [UIColor colorWithRed:colorRGB/255.0 green:colorRGB/255.0 blue:colorRGB/255.0 alpha:1];
    CGContextSetFillColorWithColor(context, [colorBg CGColor]);
    CGContextFillRect(context, rectBg);
    
    //CGRect rect = CGRectMake(0, 0, self.videoSize.width, self.videoSize.height);
    
    //NSLog(@"___s___start drawing");
    CGContextDrawImage(context, rectBg, self.image.CGImage);
    //NSLog(@"___e___end drawing");
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    //CGImageRelease(image);
    //NSLog(@"-e-CVPixelBufferRef");
    //NSLog(@"--ee--pixelBuffer: %d", self.fpsIndex);
    
    return pxbuffer;
}

@end
