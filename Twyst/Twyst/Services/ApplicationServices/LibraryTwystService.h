//
//  LibraryTwystService.h
//  Twyst
//
//  Created by Niklas Ahola on 9/8/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TLibraryTwyst.h"

@interface LibraryTwystService : NSObject

@property (nonatomic, retain) NSMutableArray *arrSavedItems;

+ (id) sharedInstance;

- (TLibraryTwyst*) confirmLibraryTwystWithPhotoModel: (FlipframePhotoModel*) flipframeModel;
- (TLibraryTwyst*) confirmLibraryTwystWithVideoModel: (FlipframeVideoModel*) flipframeModel;

@end
