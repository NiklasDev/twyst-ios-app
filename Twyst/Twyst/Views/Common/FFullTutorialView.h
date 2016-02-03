//
//  FFullTutorialView.h
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFullTutorialView;

@protocol FFullTutorialViewDelegate <NSObject>

- (void)FullTutorialViewWillDisappear:(FFullTutorialView*)sender;

@end

@interface FFullTutorialView : UIControl

@property (nonatomic, assign) FullTutorialType type;
@property (nonatomic, assign) id <FFullTutorialViewDelegate> delegate;

- (id)initWithType:(FullTutorialType)type withTarget:(id)target withSelector:(SEL)selector;


@end
