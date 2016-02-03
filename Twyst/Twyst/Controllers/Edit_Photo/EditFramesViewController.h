//
//  EditDeleteFramesViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 8/19/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FlipframePhotoModel.h"
#import "EditPhotoViewController.h"

@interface EditFramesViewController : BaseViewController

- (id) initWithInputService:(FlipframePhotoModel *)flipframeModel parent:(EditPhotoViewController *)parent;

@end
