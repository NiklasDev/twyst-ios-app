//
//  NMTransitionManager+Headers.h
//  Twyst
//
//  Created by Nahuel Morales on 9/1/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//  Global Include

// Abstract
#import "NMTransitionManager.h"
#import "NMTransition.h"
#import "NMTransitionAnimation.h"

// Transitions Implementations
#import "NMSimpleTransition.h"
#import "NMColorBurstTransition.h"
#import "NMImageBurstTransitionAnimation.h"

// Animations Implementations
#import "NMEmptyTransitionAnimation.h"
#import "NMCustomTransitionAnimation.h"
#import "NMColorFadeInTransitionAnimation.h"
#import "NMEntranceTransitionAnimation.h"
#import "NMEntranceElement.h"

#import "NMEntranceElementTranslate.h"
#import "NMEntranceElementTop.h"
#import "NMEntranceElementBottom.h"
#import "NMEntranceElementLeft.h"
#import "NMEntranceElementRight.h"
#import "NMEntranceElementFadeIn.h"
#import "NMEntranceElementScaleIn.h"

@interface NMTransitionManager (Headers)

@end
