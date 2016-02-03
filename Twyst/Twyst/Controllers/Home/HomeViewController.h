//
//  HomeViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 5/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"

#import "FadeHeaderControllerAnimatedTransitioning.h"

@interface HomeViewController : BaseViewController <HeaderProtocol>

- (void) scrollToTop;

@end