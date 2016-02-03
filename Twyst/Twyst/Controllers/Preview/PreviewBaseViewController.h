//
//  PreviewBaseViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 9/16/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "Twyst.h"
#import "TSavedTwyst.h"

#import "BaseViewController.h"

@interface PreviewBaseViewController : BaseViewController

@property (nonatomic, retain) Twyst *twyst;
@property (nonatomic, retain) TSavedTwyst *savedTwyst;

- (BOOL)isMyTwyst;

@end
