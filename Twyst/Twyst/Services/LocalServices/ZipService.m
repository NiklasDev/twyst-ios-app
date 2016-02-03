//
//  ZipService.m
//  Twyst
//
//  Created by Niklas Ahola on 5/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//
#import <zipzap/zipzap.h>

#import "ZipService.h"
#import "TStillframeRegular.h"

#import "FlipframeFileService.h"

@implementation ZipService
static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

- (BOOL) zipFiles:(NSArray*) filePaths withOutput:(NSString*) outputPath    {
    NSMutableArray *arrEntries = [[NSMutableArray alloc] init];
    NSInteger i = 0;
    for (NSString *filePath in filePaths ) {
        @autoreleasepool {
            NSString *fileName = [NSString stringWithFormat:@"%ld.jpg", (long)i];
            ZZArchiveEntry *entry = [ZZArchiveEntry archiveEntryWithFileName:fileName compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
                UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                NSData *data = UIImageJPEGRepresentation(image, DEF_FRAME_COMPRESSION_RATE);
                return data;
            }];
            [arrEntries addObject:entry];
            i++;
        }
    }
    
    ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:outputPath] options:@{ZZOpenOptionsCreateIfMissingKey:@YES} error:nil];
    
    NSError *error;
    [newArchive updateEntries:arrEntries error:&error];
    if (error)  {
        return NO;
    }
    return YES;
}

- (BOOL) zipFilesWithFlipframeModel:(FlipframePhotoModel*)flipframeModel withOutput:(NSString*)outputPath {
    NSMutableArray *arrEntries = [[NSMutableArray alloc] init];
    NSInteger totalFrames = [flipframeModel totalFrames];
    for (NSInteger i = 0; i < totalFrames; i++) {
        @autoreleasepool {
            NSString *fileName = [NSString stringWithFormat:@"%ld.jpg", (long)i];
            ZZArchiveEntry *entry = [ZZArchiveEntry archiveEntryWithFileName:fileName compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
                UIImage *image = [flipframeModel serviceGetFinalImageAtIndex:i];
                NSData *data = UIImageJPEGRepresentation(image, DEF_FRAME_COMPRESSION_RATE);
                return data;
            }];
            [arrEntries addObject:entry];
        }
    }
    
    ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:outputPath] options:@{ZZOpenOptionsCreateIfMissingKey:@YES} error:nil];
    
    NSError *error;
    [newArchive updateEntries:arrEntries error:&error];
    if (error)  {
        return NO;
    }
    return YES;
}

- (BOOL) zipFilesWithFlipframeLibrary:(FFlipframeSavedLibrary*)flipframeLibrary withOutput:(NSString*)outputPath {
    FFlipframeSaved *flipframeSaved = flipframeLibrary.flipframeSaved;
    NSSet *setStillframes = flipframeSaved.libraryTwyst.listStillframeRegular;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *arrStillframes = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSMutableArray *arrFrames = [[NSMutableArray alloc] init];
    for (TStillframeRegular *stillframeRegular in arrStillframes) {
        [arrFrames addObject:stillframeRegular.path];
    }
    
    NSMutableArray *arrEntries = [[NSMutableArray alloc] init];
    NSInteger totalFrames = [arrFrames count];
    for (NSInteger i = 0; i < totalFrames; i++) {
        @autoreleasepool {
            NSString *fileName = [NSString stringWithFormat:@"%ld.jpg", (long)i];
            ZZArchiveEntry *entry = [ZZArchiveEntry archiveEntryWithFileName:fileName compress:YES dataBlock:^NSData *(NSError *__autoreleasing *error) {
                NSString *path = [arrFrames objectAtIndex:i];
                NSString *fullPath = [[FlipframeFileService sharedInstance] generateFullDocPath:path];
                UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
                NSData *data = UIImageJPEGRepresentation(image, DEF_FRAME_COMPRESSION_RATE);
                return data;
            }];
            [arrEntries addObject:entry];
        }
    }
    
    ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:outputPath] options:@{ZZOpenOptionsCreateIfMissingKey:@YES} error:nil];
    
    NSError *error;
    [newArchive updateEntries:arrEntries error:&error];
    if (error)  {
        return NO;
    }
    return YES;
}

- (BOOL) unzipFile:(NSString*) filePath withOutputFolder:(NSString*) outputPath   {
    return NO;
}

- (BOOL) unzipFile:(NSString*) filePath withSingleOutputFile:(NSString*) outputPath   {
    ZZArchive* oldArchive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:filePath] error:nil];
    ZZArchiveEntry* firstArchiveEntry = oldArchive.entries[0];
    NSError *error;
    NSData *data = [firstArchiveEntry newDataWithError:&error];
    if (error)  {
        return NO;
    }
    [data writeToFile:outputPath atomically:YES];
    return YES;
}

- (NSArray*) unzipFileWithData:(NSData *)dataZip withOutputFolder:(NSString *)outputPath {
    ZZArchive* oldArchive = [ZZArchive archiveWithData:dataZip error:nil];
    NSMutableArray *arrFiles = [[NSMutableArray alloc] init];
    for (ZZArchiveEntry* firstArchiveEntry1 in oldArchive.entries)  {
        NSLog(@"The size is %lu bytes.", (unsigned long)firstArchiveEntry1.uncompressedSize);
        NSString *fileName = firstArchiveEntry1.fileName;
        NSString *newImagePath = [outputPath stringByAppendingPathComponent:fileName];
        NSError *error;
        @autoreleasepool {
            NSData *zipData = [firstArchiveEntry1 newDataWithError:&error];
            if (!error)  {
                [zipData writeToFile:newImagePath atomically:YES];
            }
        }
        [arrFiles addObject:newImagePath];
    }
    
    return arrFiles;
}

@end
