//
//  SubmitButton.h
//  Twyst
//
//  Created by Nahuel Morales on 9/9/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE

@interface SubmitButton : UIButton

- (void)startLoading;
- (void)stopLoading;

@end
