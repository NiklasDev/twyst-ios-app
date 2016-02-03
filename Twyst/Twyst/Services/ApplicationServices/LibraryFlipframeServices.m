//
//  ApplicationServices.m
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FlipframeFileService.h"
#import "FFlipframeSavedLibrary.h"
#import "LibraryFlipframeServices.h"

#import "TBCoreDataStore.h"
#import "TStillframeRegular.h"
#import "TLibraryTwystManager.h"

@interface LibraryFlipframeServices()  {
    TLibraryTwystManager *_libraryTwystManager;
}

@end

@implementation LibraryFlipframeServices

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


// Call when go to Library Screen
- (NSMutableArray*) loadAllSavedFlipframeForProfile {
    @autoreleasepool {
        [self.arrSavedItems removeAllObjects];
        
        NSArray *lstLibrayTwyst = [_libraryTwystManager loadAll];
        for (TLibraryTwyst *libraryTwyst in lstLibrayTwyst) {
            FFlipframeSavedLibrary *flipframeSavedLibrary = [[FFlipframeSavedLibrary alloc] initWithLibraryTwyst:libraryTwyst];
            if (flipframeSavedLibrary.imageThumb) {
                [self.arrSavedItems addObject:flipframeSavedLibrary];
            }
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO];
        [self.arrSavedItems sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        return self.arrSavedItems;
    }
}

//delete all images and remove from database
- (void) deleteFlipframeSaved:(FFlipframeSaved*) flipframeSaved {
    FlipframeFileService *fileService = [FlipframeFileService sharedInstance];
    
    //remove childs of folder
    TStillframeRegular *stillframeRegular = [flipframeSaved.libraryTwyst.listStillframeRegular anyObject];
    NSString *filePath = stillframeRegular.path;
    NSString *fullPath = [fileService generateFullDocPath:filePath];
    NSString *folderPath = [fullPath stringByDeletingLastPathComponent];
    
    //remove from database
    [[self managedObjectContext] deleteObject:flipframeSaved.libraryTwyst];
    NSError *error;
    [[self managedObjectContext] save:&error];
    if (error)  {
        [FlipframeUtils logError:error];
    }
    else {
        [FlipframeUtils deleteFolder:folderPath];
    }
    [Global postLibraryItemDidDeleteNotification];
}

- (long) countallSavedItems {
    return [_libraryTwystManager countAll];
}

@end
