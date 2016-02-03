//
//  CircleProgressView.h
//  Twyst
//
//  Created by Niklas Ahola on 4/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"

@interface CircleProgressView : UIView  {
}

@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) KAProgressLabel *circleProgressView;
@property (nonatomic, retain) UILabel *lbText;
@property (nonatomic, retain) UILabel *lbProgress;

@end
