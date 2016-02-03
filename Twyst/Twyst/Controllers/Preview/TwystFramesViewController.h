//
//  TwystFramesViewController.h
//  Twyst
//
//  Created by Niklas Ahola on 3/3/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TSavedTwyst.h"
#import "BaseViewController.h"

@protocol TwystFramesDelegate <NSObject>

- (void)twystFrameDidSelect:(NSInteger)index;

@end

@interface TwystFramesViewController : BaseViewController

@property (nonatomic, assign) id <TwystFramesDelegate> delegate;

- (id)initWithSavedStringg:(TSavedTwyst*)savedTwyst;

@end
