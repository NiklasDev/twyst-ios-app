//
//  FFlipframeSaved.h
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLibraryTwyst.h"

@interface FFlipframeSaved : NSObject

@property (nonatomic, retain) TLibraryTwyst *libraryTwyst;

- (id) initWithLibraryTwyst:(TLibraryTwyst*)libraryTwyst;

@end
