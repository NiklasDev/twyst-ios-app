//
//  NMCustomTransitionAnimation.h
//  Twyst
//
//  Created by Nahuel Morales on 9/11/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NMTransitionAnimation.h"

@interface NMCustomTransitionAnimation : NMTransitionAnimation

@property (nonatomic, strong) void (^animationBlock)(void(^)(void));

@end
