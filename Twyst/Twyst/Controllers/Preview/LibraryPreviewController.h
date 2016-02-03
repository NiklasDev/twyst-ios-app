//
//  LibraryPreviewController.h
//  Twyst
//
//  Created by Niklas Ahola on 8/27/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "FFlipframeSavedLibrary.h"
#import "PreviewBaseViewController.h"

@interface LibraryPreviewController : PreviewBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@property (nonatomic, retain) FFlipframeSavedLibrary *flipframeLibrary;

@end
