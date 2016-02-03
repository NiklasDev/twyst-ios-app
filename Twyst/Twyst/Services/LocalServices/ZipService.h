//
//  ZipService.h
//  Twyst
//
//  Created by Niklas Ahola on 5/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSavedTwyst.h"
#import "FlipframePhotoModel.h"
#import "FFlipframeSavedLibrary.h"

@interface ZipService : NSObject

+ (id) sharedInstance;
- (BOOL) zipFiles:(NSArray*)filePaths withOutput:(NSString*) outputPath;
- (BOOL) zipFilesWithFlipframeModel:(FlipframePhotoModel*)flipframeModel withOutput:(NSString*)outputPath;
- (BOOL) zipFilesWithFlipframeLibrary:(FFlipframeSavedLibrary*)flipframeLibrary withOutput:(NSString*)outputPath;

- (BOOL) unzipFile:(NSString*) filePath withOutputFolder:(NSString*) outputPath;
- (BOOL) unzipFile:(NSString*) filePath withSingleOutputFile:(NSString*) outputPath;
- (NSArray*) unzipFileWithData:(NSData*)data withOutputFolder:(NSString*)outputPath;

@end
