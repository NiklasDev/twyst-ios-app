//
//  TwystFileService.m
//  Twyst
//
//  Created by Niklas Ahola on 3/25/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipframeFileService.h"

@interface FlipframeFileService()   {
    NSString *_pathTmp;
    NSString *_pathDoc;

    //tmp paths
    NSString *_pathCapturing;
    NSString *_pathTwyst;
    NSString *_pathVideo;
}
@end

@implementation FlipframeFileService
static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}
- (id) init {
    self = [super init];
    if (self)   {
        
    }
    return self;
}

// create directories
- (void) createDirectories {
    _pathTmp = NSTemporaryDirectory();
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _pathDoc = [paths objectAtIndex:0];
    
    [self emptyTmp];
    
    NSString *nameCapturing = @"Capturing";
    NSString *nameTwyst = @"Twyst";
    NSString *nameVideo = @"Video";
    
    _pathCapturing = [_pathTmp stringByAppendingPathComponent:nameCapturing];
    _pathTwyst = [_pathTmp stringByAppendingPathComponent:nameTwyst];
    _pathVideo = [_pathTmp stringByAppendingPathComponent:nameVideo];
    
    [FlipframeUtils checkAndCreateDirectory:_pathCapturing];
    [FlipframeUtils checkAndCreateDirectory:_pathTwyst];
    [FlipframeUtils checkAndCreateDirectory:_pathVideo];
    
    NSString *pathSavedTwyst = [_pathDoc stringByAppendingPathComponent:DEF_IO_SAVED_TWYST];
    NSString *pathRegular = [_pathDoc stringByAppendingPathComponent:DEF_IO_FLIPFRAME_REGULAR];
    [FlipframeUtils checkAndCreateDirectory:pathSavedTwyst];
    [FlipframeUtils checkAndCreateDirectory:pathRegular];
}

#pragma mark - generate full document path
- (NSString*) generateFullDocPath:(NSString*)filePath {
    return [NSString stringWithFormat:@"%@/%@", _pathDoc, filePath];
}

#pragma mark - empty temps
- (void) emptyCapturing {
    [FlipframeUtils deleteFileOrFolder:_pathCapturing];
}

- (void) emptyTmp   {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"emptyTmpFolder");
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString *pathFolder = _pathTmp;
        for (NSString *file in [fm contentsOfDirectoryAtPath:pathFolder error:&error]) {
            NSString *fildePath = [pathFolder stringByAppendingPathComponent:file];
            NSLog(@"__child: %@", fildePath);
            [FlipframeUtils deleteFileOrFolder:fildePath];
        }
    });
}

#pragma mark - capturing related methods
- (NSString*) generateCapturingFileThumbPath:(NSInteger) index {
    NSString *fileName = [NSString stringWithFormat:@"thumb_%ld.jpg", (long)index];
    NSString *tmpImagePath = [_pathCapturing stringByAppendingPathComponent:fileName];
    return tmpImagePath;
}

- (NSString*) generateCapturingFilePath:(NSInteger) index {
    NSString *fileName = [NSString stringWithFormat:@"%ld.jpg", (long)index];
    NSString *tmpImagePath = [_pathCapturing stringByAppendingPathComponent:fileName];
    return tmpImagePath;
}

- (NSString*) generateCapturingBackUpFilePath:(NSString*)srcPath {
    NSString *fileName = [NSString stringWithFormat:@"backup_%@.jpg", [[srcPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *tmpImagePath = [_pathCapturing stringByAppendingPathComponent:fileName];
    return tmpImagePath;
}

- (NSString*) generateDrawingFilePath:(NSString*)srcPath {
    NSString *fileName = [NSString stringWithFormat:@"drawing_%@.jpg", [[srcPath lastPathComponent] stringByDeletingPathExtension]];
    NSString *tmpImagePath = [_pathCapturing stringByAppendingPathComponent:fileName];
    return tmpImagePath;
}

- (NSString*) generateFinalFilePath:(NSInteger) index {
    NSString *fileName = [NSString stringWithFormat:@"final_%ld.jpg", (long)index];
    NSString *tmpImagePath = [_pathCapturing stringByAppendingPathComponent:fileName];
    return tmpImagePath;
}

- (NSString*) generateCapturingVideoPath {
    NSString *videoPath = [_pathCapturing stringByAppendingPathComponent:@"capturingVideo.mov"];
    return videoPath;
}

- (NSString*) generateFinalVideoPath {
    NSString *videoPath = [_pathCapturing stringByAppendingPathComponent:@"FinalVideo.mp4"];
    return videoPath;
}

#pragma mark - save photo and twyst path related methods
- (NSString*) generateRegularFolderPath {
    NSString *folderName = [FlipframeUtils generateTimeStamp];
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@", DEF_IO_FLIPFRAME_REGULAR, folderName];
    NSString *fullPath = [self generateFullDocPath:folderPath];
    [FlipframeUtils checkAndCreateDirectory:fullPath];
    return folderPath;
}

#pragma mark - profile related methods
- (NSString*) generateProfilePhotoName:(long)userId {
    NSString *fileName = [FlipframeUtils generateFileNameWithUserId:userId];
    fileName = [fileName stringByAppendingPathExtension:@"jpg"];
    return fileName;
}

- (NSString*) generateLargeProfilePhotoName:(NSString*)photoName {
    return [NSString stringWithFormat:@"full_%@", photoName];;
}

- (NSString*) generateCoverPhotoName:(long)userId {
    NSString *fileName = [NSString stringWithFormat:@"cover_%ld.jpg", userId];
    return fileName;
}

#pragma mark - twyst zip file related methods
- (NSString*) generateTwystZipFilePath:(long)twystId {
    NSString *fileName = [NSString stringWithFormat:@"%ld.zip", twystId];
    NSString *pathFile = [_pathTwyst stringByAppendingPathComponent:fileName];
    return pathFile;
}

#pragma mark - finalized video file path
- (NSString*) generateVideoFilePath {
    NSString *fileName = DEF_VIDEO_OUTPUT_NAME;
    NSString *pathFile = [_pathVideo stringByAppendingPathComponent:fileName];
    return pathFile;
}

#pragma mark - saved twyst file related methods
- (NSString*) generateSavedTwystFolderPath:(long)twystId {
    NSString *folderName = [NSString stringWithFormat:@"%ld", twystId];
    NSString *pathFolder = [NSString stringWithFormat:@"%@/%@", DEF_IO_SAVED_TWYST, folderName];
    NSString *fullPath = [self generateFullDocPath:pathFolder];
    [FlipframeUtils checkAndCreateDirectory:fullPath];
    return pathFolder;
}

#pragma mark - save image to path
- (void) saveImageToPath:(UIImage *)image path:(NSString *)path {
    NSData *imageData = UIImageJPEGRepresentation(image, DEF_FRAME_COMPRESSION_RATE);
    [imageData writeToFile:path atomically:YES];
    [self addSkipBackupAttributeToItemAtPath:path];
}

- (void) saveDataToPath:(NSData*)data path:(NSString*)path {
    [data writeToFile:path atomically:YES];
    [self addSkipBackupAttributeToItemAtPath:path];
}

- (BOOL) copyFileToPath:(NSString*)srcPath toPath:(NSString*)toPath {
    BOOL copyResult = NO;
    long tried = 0;
    NSError *error = nil;
    while (copyResult == NO && tried < 3) {
        copyResult = [[NSFileManager defaultManager] copyItemAtPath:srcPath
                                                             toPath:toPath
                                                              error:&error];
        tried ++;
    }
    if (copyResult) {
        [self addSkipBackupAttributeToItemAtPath:toPath];
    }
    return copyResult;
}

#pragma mark - set skip iCloud backup
- (BOOL) addSkipBackupAttributeToItemAtPath:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *URL = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    return YES;
}

@end
