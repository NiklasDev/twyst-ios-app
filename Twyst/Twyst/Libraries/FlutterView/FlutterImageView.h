//
//  FlutterImageView.h
//  Twyst
//
//  Created by Niklas Ahola on 9/25/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlutterImageView : UIImageView

- (void)flutterAnimation:(CGFloat)velocity sway:(CGFloat)sway duration:(NSTimeInterval)duration;

@end
