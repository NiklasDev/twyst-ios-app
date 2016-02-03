//
//  TwystFileService.h
//  Twyst
//
//  Created by Niklas Ahola on 3/25/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlipframeFileService : NSObject

+ (id) sharedInstance;

- (NSString*) generateFullDocPath:(NSString*)filePath;

// empty all temp files
- (void) emptyCapturing;
- (void) emptyTmp;

// create directories
- (void) createDirectories;

// related capturing path
- (NSString*) generateCapturingFileThumbPath:(NSInteger)index;
- (NSString*) generateCapturingFilePath:(NSInteger)index;
- (NSString*) generateCapturingBackUpFilePath:(NSString*)srcPath;
- (NSString*) generateDrawingFilePath:(NSString*)srcPath;
- (NSString*) generateFinalFilePath:(NSInteger)index;

- (NSString*) generateCapturingVideoPath;
- (NSString*) generateFinalVideoPath;

// related save photo and twyst for later path
- (NSString*) generateRegularFolderPath;

// related profile path
- (NSString*) generateProfilePhotoName:(long)userId;
- (NSString*) generateLargeProfilePhotoName:(NSString*)photoName;
- (NSString*) generateCoverPhotoName:(long)userId;

// related twyst zip path
- (NSString*) generateTwystZipFilePath:(long)twystId;

// related saved twyst path
- (NSString*) generateSavedTwystFolderPath:(long)twystId;

// related video temp path
- (NSString*) generateVideoFilePath;

// save image to path
- (void) saveImageToPath:(UIImage*)image path:(NSString*)path;
- (void) saveDataToPath:(NSData*)data path:(NSString*)path;
- (BOOL) copyFileToPath:(NSString*)srcPath toPath:(NSString*)toPath;

// set skip back up iCloud
- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePath;

@end