//
//  ShareEmptyViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 2/27/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "FlipframePhotoModel.h"
#import "FlipframeVideoModel.h"

@interface ShareEmptyViewController : BaseViewController

- (id)initWithFlipframePhotoModel:(FlipframePhotoModel*)flipframePhotoModel;
- (id)initWithFlipframeVideoModel:(FlipframeVideoModel*)flipframeVideoModel;

@end
