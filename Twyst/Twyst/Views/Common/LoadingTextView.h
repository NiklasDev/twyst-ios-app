//
//  LoadingTextView.h
//  Twyst
//
//  Created by Niklas Ahola on 4/18/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingTextView : UILabel
+ (void) showInView:(UIView*) parent;
+ (void) hide;
@end
