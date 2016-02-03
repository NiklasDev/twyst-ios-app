//
//  FFlipframeSavedLibrary.m
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "PhotoHelper.h"
#import "FlipframeFileService.h"
#import "FFlipframeSavedLibrary.h"
#import "TStillframeRegular.h"

@implementation FFlipframeSavedLibrary

- (id) initWithLibraryTwyst:(TLibraryTwyst*) libraryTwyst    {
    self = [super init];
    if (self) {
        self.flipframeSaved = [[FFlipframeSaved alloc] initWithLibraryTwyst:libraryTwyst];
        
        //createdDate
        self.createdDate = self.flipframeSaved.libraryTwyst.createdDate;
        
        [self retrieveMoreInfo];
    }
    return self;
}

- (void) retrieveMoreInfo    {
    //imageThumb
    self.caption = self.flipframeSaved.libraryTwyst.caption;
    self.imageThumb = [UIImage imageWithData:self.flipframeSaved.libraryTwyst.thumbnail];
    self.isMovie = [self.flipframeSaved.libraryTwyst.isMovie boolValue];
    self.frameTime = [self.flipframeSaved.libraryTwyst.frameTime integerValue];
    if (self.isMovie) {
        TStillframeRegular *stillFrameRegular = [self.flipframeSaved.libraryTwyst.listStillframeRegular anyObject];
        self.videoPath = stillFrameRegular.path;
    }
}


@end