//
//  NMEntranceTransitionAnimation.h
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransitionAnimation.h"
#import "NMEntranceElement.h"

@interface NMEntranceTransitionAnimation : NMTransitionAnimation

/**
 * Entrance elements management
 */
- (void)addEntranceElement:(NMEntranceElement *)entranceElement;
- (void)addEntranceElements:(NSArray *)array;

@end
