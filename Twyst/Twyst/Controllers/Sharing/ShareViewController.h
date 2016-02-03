//
//  ShareViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 8/14/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "FlipframePhotoModel.h"
#import "FlipframeVideoModel.h"
#import "FFlipframeSavedLibrary.h"

@interface ShareViewController : BaseViewController

- (id)initWithFlipframePhotoModel:(FlipframePhotoModel*)flipframePhotoModel;
- (id)initWithFlipframeVideoModel:(FlipframeVideoModel*)flipframeVideoModel;
- (id)initWithFlipframeLibrary:(FFlipframeSavedLibrary*)flipframeLibrary;

@end
