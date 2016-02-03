//
//  FadeHeaderControllerAnimatedTransitioning.h
//  Twyst
//
//  Created by Nahuel Morales on 9/7/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HeaderProtocol <NSObject>

@required
- (UIView *)headerView;

@end

@interface FadeHeaderControllerAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isDismissTransition;

@end
