//
//  FFlipframeSavedLibrary.h
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TLibraryTwyst.h"
#import "FFlipframeSaved.h"

@interface FFlipframeSavedLibrary : NSObject
@property (nonatomic, retain) UIImage* imageThumb;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, assign) BOOL isMovie;
@property (nonatomic, assign) NSInteger frameTime;
@property (nonatomic, retain) NSString *videoPath;
@property (nonatomic, retain) FFlipframeSaved *flipframeSaved;

- (id) initWithLibraryTwyst:(TLibraryTwyst*)libraryTwyst;
- (void) retrieveMoreInfo;

@end
