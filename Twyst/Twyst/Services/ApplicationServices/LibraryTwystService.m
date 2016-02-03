//
//  LibraryTwystService.m
//  Twyst
//
//  Created by Niklas Ahola on 9/8/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TStillframeRegular.h"
#import "TLibraryTwystManager.h"

#import "FlipframeFileService.h"
#import "LibraryTwystService.h"

@interface LibraryTwystService() {
    TLibraryTwystManager *_libraryTwystManager;
}

@end

@implementation LibraryTwystService

#pragma static singleton
static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

#pragma class definition
- (id) init {
    self = [super init];
    if (self)   {
        _arrSavedItems = [[NSMutableArray alloc] init];
        _libraryTwystManager = [TLibraryTwystManager sharedInstance];
    }
    return self;
}

#pragma Helper
- (NSManagedObjectContext*) managedObjectContext   {
    return [TBCoreDataStore defaultQueueContext];
}

- (NSEntityDescription*) entityFromName:(NSString*)name {
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    return entity;
}

// Only submit to database
- (TLibraryTwyst*) confirmLibraryTwystWithPhotoModel: (FlipframePhotoModel*) flipframeModel {
    NSEntityDescription *entity = [self entityFromName:DEF_DB_ENTITY_NAME_TLibraryTwyst];
    
    TLibraryTwyst *libraryTwyst = [[TLibraryTwyst alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    libraryTwyst.totalFrames =  [NSNumber numberWithLong:flipframeModel.inputService.arrFullImagePaths.count];
    libraryTwyst.createdDate = [NSDate date];
    libraryTwyst.caption = flipframeModel.twystTheme;
    libraryTwyst.isMovie = [NSNumber numberWithBool:NO];
    libraryTwyst.frameTime = [NSNumber numberWithInteger:flipframeModel.frameTime];
    
    @autoreleasepool {
        UIImage *thumbnail = [flipframeModel serviceGetFinalImageAtIndex:0];
        NSData *imageData = UIImageJPEGRepresentation(thumbnail, DEF_FRAME_COMPRESSION_RATE);
        libraryTwyst.thumbnail = imageData;
    }
    
    NSMutableSet *setFramePaths = [[NSMutableSet alloc] init];
    //set list child images
    NSString *entityNameMStillframeRegular = DEF_DB_ENTITY_NAME_TStillframeRegular;
    NSEntityDescription *entityMStillframeRegular = [self entityFromName:entityNameMStillframeRegular];
    for (long i = 0; i < flipframeModel.inputService.arrFullImagePaths.count; i++) {
        UIImage *image = [flipframeModel serviceGetFinalImageAtIndex:i];
        if (image) {
            @autoreleasepool {
                FlipframeFileService *fileService = [FlipframeFileService sharedInstance];
                NSString *fileName = [NSString stringWithFormat:@"%ld.jpg", i];
                NSString *newChildPath = [flipframeModel.savedInfo.folderPath stringByAppendingPathComponent:fileName];
                NSString *fullPath = [fileService generateFullDocPath:newChildPath];
                [fileService saveImageToPath:image path:fullPath];
                
                TStillframeRegular *stillframeRegular = [[TStillframeRegular alloc] initWithEntity:entityMStillframeRegular insertIntoManagedObjectContext:self.managedObjectContext];
                stillframeRegular.path = newChildPath;
                stillframeRegular.order = [NSNumber numberWithLong:i];
                stillframeRegular.isMovie = [NSNumber numberWithBool:NO];
                stillframeRegular.frameTime = [NSNumber numberWithInteger:flipframeModel.frameTime];
                [setFramePaths addObject:stillframeRegular];
            }
        }
        else {
            libraryTwyst.totalFrames = [NSNumber numberWithLong:([libraryTwyst.totalFrames longValue] - 1)];
        }
    }
    
    [libraryTwyst addListStillframeRegular:setFramePaths];
    
    //add to database
    NSError *error;
    [libraryTwyst.managedObjectContext save:&error];
    if (error)  {
        [FlipframeUtils logError:error];
    }
    
    return libraryTwyst;
}

- (TLibraryTwyst*) confirmLibraryTwystWithVideoModel: (FlipframeVideoModel*) flipframeModel {
    NSEntityDescription *entity = [self entityFromName:DEF_DB_ENTITY_NAME_TLibraryTwyst];
    
    TLibraryTwyst *libraryTwyst = [[TLibraryTwyst alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    libraryTwyst.totalFrames =  [NSNumber numberWithLong:1];
    libraryTwyst.createdDate = [NSDate date];
    libraryTwyst.caption = flipframeModel.twystTheme;
    libraryTwyst.isMovie = [NSNumber numberWithBool:YES];
    libraryTwyst.frameTime = [NSNumber numberWithInteger:flipframeModel.frameTime];
    
    @autoreleasepool {
        NSURL *videoUrl = [NSURL fileURLWithPath:flipframeModel.finalPath];
        UIImage *thumbnail = [FlipframeUtils generateThumbImageFromVideo:videoUrl coverFrame:flipframeModel.coverFrame];
        NSData *imageData = UIImageJPEGRepresentation(thumbnail, DEF_FRAME_COMPRESSION_RATE);
        libraryTwyst.thumbnail = imageData;
    }
    
    NSMutableSet *setFramePaths = [[NSMutableSet alloc] init];
    //set list child images
    NSString *entityNameMStillframeRegular = DEF_DB_ENTITY_NAME_TStillframeRegular;
    NSEntityDescription *entityMStillframeRegular = [self entityFromName:entityNameMStillframeRegular];
    
    FlipframeFileService *fileService = [FlipframeFileService sharedInstance];
    NSString *fileName = @"movie.mp4";
    NSString *newChildPath = [flipframeModel.savedInfo.folderPath stringByAppendingPathComponent:fileName];
    NSString *fullPath = [fileService generateFullDocPath:newChildPath];
    if (![fileService copyFileToPath:flipframeModel.finalPath toPath:fullPath]) {
        return nil;
    }
    
    TStillframeRegular *stillframeRegular = [[TStillframeRegular alloc] initWithEntity:entityMStillframeRegular insertIntoManagedObjectContext:self.managedObjectContext];
    stillframeRegular.path = newChildPath;
    stillframeRegular.order = [NSNumber numberWithLong:0];
    stillframeRegular.isMovie = [NSNumber numberWithBool:YES];
    stillframeRegular.frameTime = [NSNumber numberWithInteger:flipframeModel.frameTime];
    [setFramePaths addObject:stillframeRegular];

    [libraryTwyst addListStillframeRegular:setFramePaths];

    //add to database
    NSError *error;
    [libraryTwyst.managedObjectContext save:&error];
    if (error)  {
        [FlipframeUtils logError:error];
    }
    
    return libraryTwyst;
}

@end
