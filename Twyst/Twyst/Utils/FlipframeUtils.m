//
//  TwystUtils.m
//  Twyst
//
//  Created by Niklas Ahola on 5/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "UIImage+Device.h"
#import "Global.h"
#import "AppDelegate.h"
#import "FlipframeUtils.h"

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start(ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix:@"\n"]) {
        format = [format stringByAppendingString:@"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end(ap);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "(%s:%d) : (%s) %s", [fileName UTF8String], lineNumber, functionName, [body UTF8String]);
}

@implementation FlipframeUtils

+ (NSString*) nibNameForDevice:(NSString*)nibName {
    if ([Global deviceType] == DeviceTypePhone6) {
        nibName = [NSString stringWithFormat:@"%@-4.7inch", nibName];
    }
    else if ([Global deviceType] == DeviceTypePhone6Plus) {
        nibName = [NSString stringWithFormat:@"%@-5.5inch", nibName];
    }
    return nibName;
}

+ (NSString*) generateFileNameWithTwystId:(long)twystId {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormat setDateFormat:@"MM_dd_yyyy_HH_mm_ss_SSS"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *result = [NSString stringWithFormat:@"%ld_%@", twystId, dateString];
    return result;
}

+ (NSString*) generateFileNameWithUserId:(long)userId  {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormat setDateFormat:@"MM_dd_yyyy_HH_mm_ss_SSS"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *result = [NSString stringWithFormat:@"%ld_%@", userId, dateString];
    return result;
}

+ (NSString*) generateTimeStamp {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    return [[NSString stringWithFormat:@"%ff", timeStamp] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

+ (NSString*) getFolerLibPath    {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *libPath = [documentPath stringByAppendingPathComponent:@"/MyFlipframes"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:libPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:libPath withIntermediateDirectories:NO attributes:nil error:&error];
    return libPath;
}

#pragma mark - file management methods
+ (void) checkAndCreateDirectory:(NSString*)folderPath {
    BOOL isDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:folderPath isDirectory:&isDir];
    NSError *error;
    if (!exists) {
        if (![fm createDirectoryAtPath:folderPath
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
}

+ (void) moveFile:(NSString*) pathSrc toDesc:(NSString*) pathDesc    {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm moveItemAtPath:pathSrc toPath:pathDesc error:&error];
    if (error)  {
        [self logError:error];
    }
}

+ (void) deleteFolder:(NSString*)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error1;
    if ([fm fileExistsAtPath:path]) {
        [fm removeItemAtPath:path error:&error1];
        if (error1) {
            [self logError:error1];
        }
    }
}

+ (void) deleteFileOrFolder:(NSString*) path    {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fm fileExistsAtPath:path isDirectory:&isDir])   {
        if (isDir){
            NSError *error;
            for (NSString *file2 in [fm contentsOfDirectoryAtPath:path error:&error]) {
                NSString *fildePath2 = [path stringByAppendingPathComponent:file2];
                NSError *error2;
                [fm removeItemAtPath:fildePath2 error:&error2];
                if (error2) {
                    [self logError:error2];
                }
            }
        }   else    {
            NSError *error2;
            [fm removeItemAtPath:path error:&error2];
            if (error2) {
                [self logError:error2];
            }
        }
    }
}

+ (BOOL) containsFileInFolder:(NSString*)folderPath {
//    NSFileManager *fm = [NSFileManager defaultManager];
//    BOOL retVal = [fm fileExistsAtPath:folderPath isDirectory:YES];
//    return retVal;
    return YES;
}

#pragma mark -
+ (UIImage*) getImageFromView:(UIView*)view {
    @autoreleasepool {
        CGRect frame = view.frame;
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
        
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color{
    @autoreleasepool {
        // begin a new image context, to draw our colored image onto with the right scale
        UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
        
        // get a reference to that context we created
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // set the fill color
        [color setFill];
        
        // translate/flip the graphics context (for transforming from CG* coords to UI* coords
        CGContextTranslateCTM(context, 0, source.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetBlendMode(context, kCGBlendModeColorBurn);
        CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
        CGContextDrawImage(context, rect, source.CGImage);
        
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        CGContextAddRect(context, rect);
        CGContextDrawPath(context,kCGPathFill);
        
        // generate a new UIImage from the graphics context we drew onto
        UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return the color-burned image
        return coloredImg;
    }
}

+ (UIImage*) applyDrawingOverlay:(UIImage*)fullImage overlay:(UIImage*)overlay {
    @autoreleasepool {
        CGSize size = fullImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        
        CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
        [fullImage drawInRect:drawRect];
        [overlay drawInRect:drawRect];
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }
}

+ (UIImage*) generateSelectionOverlayWithIndex:(UIImage*) image withIndex:(NSInteger)index {
    @autoreleasepool {
        NSArray *colors = @[Color(75, 64, 113),
                            Color(0, 208, 193),
                            Color(245, 161, 28),
                            Color(245, 91, 84)];
        UIColor *color = [colors objectAtIndex:(index % 4)];
        UIImage *coloredImage = [[self class] filledImageFrom:image withColor:color];
        
        CGFloat fontSize = 0;
        CGFloat heightRatio = 0;
        switch ([Global deviceType]) {
            case DeviceTypePhone6:
                fontSize = 20;
                heightRatio = 0.94;
                break;
            case DeviceTypePhone6Plus:
                fontSize = 23;
                heightRatio = 0.97;
                break;
            default:
                fontSize = 20;
                heightRatio = 0.96;
                break;
        }
        
        CGSize size = coloredImage.size;
        CGFloat scale = [[UIScreen mainScreen] scale] > 1.5 ? 2 : 1;
        UIGraphicsBeginImageContextWithOptions(size, NO, scale);
        
        [coloredImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        //draw index
        CGRect labelRect = CGRectMake(0, 0, size.width, size.height * heightRatio);
        UILabel * label = [[UILabel alloc] initWithFrame:labelRect];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat:@"%ld", (long)(index + 1)];
        [label drawTextInRect:labelRect];
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = nil;
        return resultImage;
    }
}

+ (UIImage*) addReplyComment:(UIImage*)image comment:(NSString*)comment frame:(CGRect)frame {
    @autoreleasepool {
        CGSize size = image.size;
        CGFloat ratio = size.width / SCREEN_WIDTH;
        
        UIGraphicsBeginImageContext(size);

        //draw image
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        //draw comment
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        background.backgroundColor = [UIColor clearColor];
        
        frame = CGRectMake(frame.origin.x * ratio, frame.origin.y * ratio, frame.size.width * ratio, frame.size.height * ratio);
        UILabel *labelComment = [[UILabel alloc] initWithFrame:frame];
        labelComment.text = comment;
        labelComment.backgroundColor = ColorRGBA(0, 0, 0, 0.8);
        labelComment.textColor = [UIColor whiteColor];
        labelComment.textAlignment = NSTextAlignmentCenter;
        labelComment.font = [UIFont fontWithName:@"HelveticaNeue" size:[FlipframeUtils editCommentFontSize] * ratio];
        labelComment.numberOfLines = 0;
        [background addSubview:labelComment];

        CGContextRef context = UIGraphicsGetCurrentContext();
        [background.layer renderInContext:context];
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = nil;
        labelComment = nil;
        return resultImage;
    }
}

+ (UIImage*) generateVideoOverlay:(CGSize)size drawing:(UIImage*)drawing  comment:(NSString*)comment frame:(CGRect)frame {
    @autoreleasepool {
        CGFloat ratio = size.width / SCREEN_WIDTH;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        
        //draw image
        if (drawing) {
            [drawing drawInRect:CGRectMake(0, 0, size.width, size.height)];
        }
        
        //draw comment
        if (comment) {
            UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            background.backgroundColor = [UIColor clearColor];
            
            frame = CGRectMake(frame.origin.x * ratio, frame.origin.y * ratio, frame.size.width * ratio, frame.size.height * ratio);
            UILabel *labelComment = [[UILabel alloc] initWithFrame:frame];
            labelComment.text = comment;
            labelComment.backgroundColor = ColorRGBA(0, 0, 0, 0.8);
            labelComment.textColor = [UIColor whiteColor];
            labelComment.textAlignment = NSTextAlignmentCenter;
            labelComment.font = [UIFont fontWithName:@"HelveticaNeue" size:[FlipframeUtils editCommentFontSize] * ratio];
            labelComment.numberOfLines = 0;
            [background addSubview:labelComment];
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            [background.layer renderInContext:context];
        }
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        drawing = nil;
        return resultImage;
    }
}

+ (void) logError:(NSError *)error  {
    if (error)  {
        NSLog(@"error: %@", error);
    }
}

+ (NSString*) getNumbersFromString:(NSString*)string {
    NSMutableString *newStr = [[NSMutableString alloc] init];
    NSInteger len = [string length];
    for (NSInteger i = len - 1; i >= 0; i--) {
        unichar character = [string characterAtIndex:i];
        if (character >= 48 && character <= 59) {
            [newStr insertString:[NSString stringWithFormat:@"%c", character] atIndex:0];
            if (newStr.length == 10) {
                break;
            }
        }
    }
    return newStr;
}

+ (NSString*) getStyledPhoneNumber:(NSString*)phoneNumber {
    if (!IsNSStringValid(phoneNumber)) {
        return nil;
    }
    else {
        if (phoneNumber.length == 10) {
            NSMutableString *newStr = [NSMutableString stringWithString:phoneNumber];
            [newStr insertString:@"-" atIndex:6];
            [newStr insertString:@"-" atIndex:3];
            return newStr;
        }
        else {
            return nil;
        }
    }
}

+ (NSString*)countString:(NSInteger)count {
    if (count < 1000) {
        return [NSString stringWithFormat:@"%ld", (long)count];
    }
    else {
        return [NSString stringWithFormat:@"%.0fk", (CGFloat)count / 1000.0f];
    }
}

+ (NSString*) strunggString:(NSNumber*)strungg {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber:strungg];
    return formatted;
}

+ (BOOL) isSubstring:(NSString*)substring of:(NSString*)string {
    NSRange range = [string rangeOfString:substring];
    if (range.length > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (UIImage*)generateThumbImageFromVideo: (NSURL*)videoUrl coverFrame:(CGFloat)coverFrame {
    AVAsset *asset = [AVAsset assetWithURL: videoUrl];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset: asset];
    CMTime time = CMTimeMakeWithSeconds(coverFrame, 600);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime: time actualTime: nil error: nil];
    
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack* videoTrack    = [videoTracks firstObject];
    CGAffineTransform txf       = [videoTrack preferredTransform];
    
    UIImageOrientation thumbOrientation = UIImageOrientationRight;
    if (txf.a == 0 && txf.b == 1.0 && txf.c == -1.0 && txf.d == 0) {
        thumbOrientation = UIImageOrientationRight;
    }
    if (txf.a == 0 && txf.b == -1.0 && txf.c == 1.0 && txf.d == 0) {
        thumbOrientation =  UIImageOrientationLeft;
    }
    if (txf.a == 1.0 && txf.b == 0 && txf.c == 0 && txf.d == 1.0) {
        thumbOrientation =  UIImageOrientationUp;
    }
    if (txf.a == -1.0 && txf.b == 0 && txf.c == 0 && txf.d == -1.0) {
        thumbOrientation = UIImageOrientationDown;
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:thumbOrientation];
    CGImageRelease(imageRef);
    
    NSLog(@">> ThumbImage Size = \n%@", NSStringFromCGSize(thumbnail.size));
    
    return thumbnail;
}

+ (CGFloat)editCommentHeight {
    return DEF_EDIT_COMMENT_HEIGHT * SCREEN_WIDTH / 375.0f;
}

+ (CGFloat)editCommentFontSize {
    return DEF_EDIT_COMMENT_FONT_SIZE * SCREEN_WIDTH / 375.0f;
}

@end
