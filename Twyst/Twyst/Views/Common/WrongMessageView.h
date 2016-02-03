//
//  WrongMessageView.h
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WrongMessageView : UIImageView

+ (void) showMessage:(WrongMessageType)type inView:(UIView*)view;
+ (void) showMessage:(WrongMessageType)type inView:(UIView*)view arrayOffsetY:(NSArray*)arrayOffsetY;
+ (void) showAlert:(WrongMessageType)type target:(id)target;

+ (void) forceHide;
+ (void) hide;
+ (BOOL) checkIfShowed;
@end
