//
//  NMColorBurstTransition.h
//  Twyst
//
//  Created by Nahuel Morales on 8/28/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//
//  This transition extends SimpleTransition and set as from animation
//  a ColorBurstAnimation
//

#import "NMSimpleTransition.h"

@interface NMColorBurstTransition : NMSimpleTransition

- (instancetype)initWithContainerFrom:(UIView *)containerFrom
                            burstView:(UIView *)burstView
                          containerTo:(UIView *)containerTo;

- (instancetype)initWithContainerFrom:(UIView *)containerFrom
                            burstView:(UIView *)burstView
                          containerTo:(UIView *)containerTo
                           burstColor:(UIColor *)burstColor;
@end
