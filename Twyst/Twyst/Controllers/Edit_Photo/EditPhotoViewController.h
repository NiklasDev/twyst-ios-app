//
//  EditPhotoViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 8/12/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "NMTransitionManager+Headers.h"

@interface EditPhotoViewController : BaseViewController

@property (nonatomic, assign) long twystId;
@property (nonatomic, strong) UIImage *introPreviewImage;

- (id)initWithParent:(UIViewController*) inParent;
- (void) startNewSession;
- (void) actionFrameDeleted;

- (NMTransitionAnimation *)generateIntroAnimation;

@end
