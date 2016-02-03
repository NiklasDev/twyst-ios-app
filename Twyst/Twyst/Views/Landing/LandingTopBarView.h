//
//  LandingTopBarView.h
//  Twyst
//
//  Created by Niklas Ahola on 3/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderLabel.h"
#import "BounceButton.h"

@class LandingBaseView;

@interface LandingTopBarView : UIView

@property (nonatomic, strong) HeaderLabel *labelTitle;
@property (nonatomic, strong) BounceButton *btnDone;
@property (nonatomic, strong) BounceButton *btnBack;

+ (LandingTopBarView*)topBarWithLandingView:(LandingBaseView*)landingView;

- (NSArray *)generateEntranceElements;
- (void)animateIntro;

@end
