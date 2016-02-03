//
//  PhotoHelper.m
//  Twyst
//
//  Created by Niklas Ahola on 4/6/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "PhotoHelper.h"

@implementation PhotoHelper

+ (void) cropAndSave:(CMSampleBufferRef)sampleBuffer withPathFull:(NSString*)pathFull withPathThumb:(NSString*) pathThumb inQueue:(dispatch_queue_t) queuePhotos completion:(void (^)(UIImage *)) completion {
    
    NSLog(@"1- start rawImageData");
    @autoreleasepool {
        NSData *rawImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        CFRetain(sampleBuffer);
        CFRelease(sampleBuffer);
        sampleBuffer = nil;
        
        [rawImageData writeToFile:pathFull atomically:YES];
        dispatch_async(queuePhotos, ^{
            @autoreleasepool {
                if ([Global getInstance].isCancelCameraProcessing)  {
                    NSLog(@"------- CANCEL CAMERA PROCESSING");
                    return;
                }
                
                NSLog(@"2 - end rawImageData");
                UIImage *rawImage = [UIImage imageWithContentsOfFile:pathFull];
                CGSize rawImageSize = rawImage.size;
                NSLog(@"3 - end rawImageSize: %@", NSStringFromCGSize(rawImageSize));
                UIImage *rawImageFull = [PhotoHelper actionMakeFullImage:rawImage];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    @autoreleasepool {
                        NSLog(@"4 - rawImageFull");
                        NSData *rawDataImageFull = UIImageJPEGRepresentation(rawImageFull, DEF_FRAME_COMPRESSION_RATE);
                        NSLog(@"5 - rawDataImageFull");
                        [rawDataImageFull writeToFile:pathFull atomically:YES];
                    }
                });
                
                NSLog(@"6 - rawDataImageFull writeToFile");
                UIImage *rawImageThumb = [PhotoHelper actionMakeThumbImage:rawImageFull];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    @autoreleasepool {
                        NSLog(@"7 - rawImageThumb.size %@", NSStringFromCGSize(rawImageThumb.size));
                        NSData *rawDataImageThumb = UIImageJPEGRepresentation(rawImageThumb, DEF_FRAME_COMPRESSION_RATE);
                        NSLog(@"8 - rawDataImageThumb");
                        [rawDataImageThumb writeToFile:pathThumb atomically:YES];
                    }
                });
                NSLog(@"9 - rawDataImageThumb writeToFile");
                if (completion) {
                    completion(rawImageFull);
                }
            };
        });
    };
}

+ (void) cropAndSave_iPhone4:(CMSampleBufferRef)sampleBuffer withPathFull:(NSString*)pathFull withPathThumb:(NSString*) pathThumb inQueue:(dispatch_queue_t) queuePhotos completion:(void (^)(UIImage *)) completion {
    
    NSLog(@"1- start rawImageData");
    @autoreleasepool {
        NSData *rawImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        CFRetain(sampleBuffer);
        CFRelease(sampleBuffer);
        sampleBuffer = nil;
        
        [rawImageData writeToFile:pathFull atomically:YES];
        @autoreleasepool {
            if ([Global getInstance].isCancelCameraProcessing)  {
                NSLog(@"------- CANCEL CAMERA PROCESSING");
                return;
            }
            
            NSLog(@"2 - end rawImageData");
            UIImage *rawImage = [UIImage imageWithContentsOfFile:pathFull];
            CGSize rawImageSize = rawImage.size;
            NSLog(@"3 - end rawImageSize: %@", NSStringFromCGSize(rawImageSize));
            UIImage *rawImageFull = [PhotoHelper actionMakeFullImage:rawImage];
            
            @autoreleasepool {
                NSLog(@"4 - rawImageFull");
                NSData *rawDataImageFull = UIImageJPEGRepresentation(rawImageFull, DEF_FRAME_COMPRESSION_RATE);
                NSLog(@"5 - rawDataImageFull");
                [rawDataImageFull writeToFile:pathFull atomically:YES];
            }
            
            NSLog(@"6 - rawDataImageFull writeToFile");
            UIImage *rawImageThumb = [PhotoHelper actionMakeThumbImage:rawImageFull];
            @autoreleasepool {
                NSLog(@"7 - rawImageThumb.size %@", NSStringFromCGSize(rawImageThumb.size));
                NSData *rawDataImageThumb = UIImageJPEGRepresentation(rawImageThumb, DEF_FRAME_COMPRESSION_RATE);
                NSLog(@"8 - rawDataImageThumb");
                [rawDataImageThumb writeToFile:pathThumb atomically:YES];
            }
            NSLog(@"9 - rawDataImageThumb writeToFile");
            if (completion) {
                completion(rawImageFull);
            }
        };
    };
}

#pragma mark -
+ (UIImage*) actionMakeFullImage:(UIImage*)image {
    return [[self class] cropImage:image size:[self getSizeFull]];
}

+ (UIImage*) actionMakeThumbImage:(UIImage*)image {
    return [[self class] cropImage:image size:[self getSizeThumb]];
}

#pragma mark -
+ (UIImage*) thumbImageFromVideoPath:(NSString*) videoPath {
    @autoreleasepool {
        float s = 200;
        
        NSURL *videoUrl = [[NSURL alloc] initFileURLWithPath:videoPath];
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnail = [[UIImage alloc] initWithCGImage:oneRef];
        
        //redraw image in small size
        UIGraphicsBeginImageContext(CGSizeMake(s, s));
        CGRect rect = CGRectMake(0, 0, s, s);
        [thumbnail drawInRect:rect];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(oneRef);
        
        return resultImage;
    }
}

+ (UIImage*) thumbImageFromImagePath:(NSString*)imagePath  {
    UIImage *srcImage = [UIImage imageWithContentsOfFile:imagePath];
    return [self resizeImage:srcImage size:CGSizeMake(DEF_TWYST_THUMB_SIZE, DEF_TWYST_THUMB_SIZE)];
}

#pragma mark -
+ (UIImage*) resizeImage:(UIImage*)srcImage size:(CGSize)size {
    @autoreleasepool {
        //redraw image in small size
        UIGraphicsBeginImageContext(size);
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        [srcImage drawInRect:rect];
        UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return thumbImage;
    }
}

+ (UIImage*) cropSquareImage:(UIImage*)srcImage size:(CGFloat)size {
    @autoreleasepool {
        CGRect newRect;
        if (srcImage.size.width > srcImage.size.height) {
            CGFloat ratio = size / srcImage.size.height;
            newRect.size.width = srcImage.size.width * ratio;
            newRect.origin.x = (newRect.size.width - size) / 2;
            newRect.origin.y = 0;
            newRect.size.height = size;
        }
        else {
            CGFloat ratio = size / srcImage.size.width;
            newRect.size.height = srcImage.size.height * ratio;
            newRect.origin.y = (newRect.size.height - size) / 2;
            newRect.origin.x = 0;
            newRect.size.width = size;
        }
        
        //redraw image in small size
        UIGraphicsBeginImageContext(CGSizeMake(size, size));
        [srcImage drawInRect:newRect];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }
}

+ (UIImage*) cropCoverImage:(UIImage*)srcImage {
    @autoreleasepool {
        CGSize coverSize = CGSizeMake(640, 266);
        float ratio = coverSize.width / srcImage.size.width;
        CGFloat originY = (coverSize.height - srcImage.size.height * ratio) / 2;
        CGRect newRect = CGRectMake(0, originY, coverSize.width, srcImage.size.height * ratio);
        
        //redraw image in small size
        UIGraphicsBeginImageContext(coverSize);
        [srcImage drawInRect:newRect];
        UIImage *profileIamge = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return profileIamge;
    }
}

+ (UIImage*)cropCircleImage:(UIImage*)srcImage size:(CGSize)size {
    @autoreleasepool {

        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        //For customized drawing we need the current grahics context
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //Pushing a copy of the current graphics state onto the stack of graphics states.
        CGContextSaveGState(context);
        
        //Making a rect in which we have to draw the user profile image.
        //Cosidering appropriate imageoffset in mind.
        CGRect clipRect = CGRectMake(0, 0, size.width, size.height);
        
        //Adding an ellipse that fits inside the specified rectangle.
        CGContextAddEllipseInRect(context, clipRect);
        
        //Modifies the current cipping path
        CGContextClip(context);
        
        //It will paints a transparent rectangle. If we don't do that we cant see the user profile image.
        //User profile image will be drawing over it.
        CGContextClearRect(context, clipRect);
        
        //Drawing the image in particular clipped rect which is will provide a circular shape.
        [srcImage drawInRect:CGRectMake(clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height)];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

+ (UIImage*) cropImage:(UIImage*)srcImage size:(CGSize)size {
    @autoreleasepool {
        CGRect drawRect = CGRectZero;
        if ((size.width / size.height) > (srcImage.size.width / srcImage.size.height)) {
            float ratio = size.width / srcImage.size.width;
            float y = (size.height - srcImage.size.height * ratio) / 2;
            drawRect = CGRectMake(0, y, size.width, srcImage.size.height * ratio);
        }
        else {
            float ratio = size.height / srcImage.size.height;
            float x = (size.width - srcImage.size.width * ratio) / 2;
            drawRect = CGRectMake(x, 0, srcImage.size.width * ratio, size.height);
        }
        
        UIGraphicsBeginImageContext(size);
        [srcImage drawInRect:drawRect];
        UIImage* resImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resImage;
    }
}

#pragma mark -
+ (CGSize) getSizeFull  {
    return CGSizeMake(DEF_TWYST_IMAGE_WIDTH, DEF_TWYST_IMAGE_HEIGHT);
}
+ (CGSize) getSizeThumb  {
    return CGSizeMake(DEF_TWYST_THUMB_SIZE, DEF_TWYST_THUMB_SIZE);
}

#pragma mark -
+ (UIImage*) fixOrientation:(UIImage*) srcImage
{
    @autoreleasepool {
        // No-op if the orientation is already correct
        if (srcImage.imageOrientation == UIImageOrientationUp) return srcImage;
        
        
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        CGAffineTransform transform = CGAffineTransformIdentity;
        float width = srcImage.size.width;
        float height = srcImage.size.height;
        
        switch (srcImage.imageOrientation)
        {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, width, height);
                transform = CGAffineTransformRotate(transform, M_PI);
                break;
                
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                transform = CGAffineTransformTranslate(transform, width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
                break;
                
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
                break;
                
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
        
        switch (srcImage.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
                
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
                
            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
                break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        CGContextRef ctx = CGBitmapContextCreate(NULL, width, height,
                                                 CGImageGetBitsPerComponent(srcImage.CGImage), 0,
                                                 CGImageGetColorSpace(srcImage.CGImage),
                                                 CGImageGetBitmapInfo(srcImage.CGImage));
        CGContextConcatCTM(ctx, transform);
        switch (srcImage.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(ctx, CGRectMake(0,0,height,width), srcImage.CGImage);
                break;
                
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0,width,height), srcImage.CGImage);
                break;
        }
        
        // And now we just create a new UIImage from the drawing context
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
    }
}
@end
