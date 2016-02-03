//
//  FFlipframeSaved.m
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FFlipframeSaved.h"

@implementation FFlipframeSaved

- (id) initWithLibraryTwyst:(TLibraryTwyst*)libraryTwyst {
    self = [super init];
    if (self) {
        self.libraryTwyst = libraryTwyst;
    }
    return self;
}

@end
