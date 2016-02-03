//
//  EditVideoViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"

#import "NMTransitionManager+Headers.h"

@interface EditVideoViewController : BaseViewController

@property (nonatomic, assign) long twystId;

- (id)initWithParent:(UIViewController*) inParent;
- (void)startNewSession;

- (NMTransitionAnimation *)generateIntroAnimation;

@end
