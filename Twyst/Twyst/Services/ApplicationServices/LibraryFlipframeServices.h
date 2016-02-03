//
//  ApplicationServices.h
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FFlipframeSavedLibrary.h"

@interface LibraryFlipframeServices : NSObject

@property (nonatomic, retain) NSMutableArray *arrSavedItems;

+ (id) sharedInstance;

// Call when go to Library Screen
// return list of <FFlipframeSavedLibrary>
- (NSMutableArray*) loadAllSavedFlipframeForProfile;

- (void) deleteFlipframeSaved:(FFlipframeSaved*) flipframeSaved;

- (long) countallSavedItems;

@end
