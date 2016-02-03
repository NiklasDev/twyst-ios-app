//
//  ProfileDownloadProgressView.h
//  Twyst
//
//  Created by Niklas Ahola on 4/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"
#import "FullProfileImageView.h"

@interface ProfileDownloadProgressView : UIView  {
}

@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) KAProgressLabel *circleProgressView;

+ (void)startWithParent:(FullProfileImageView*)parent Completion:(void (^)(void))completion;

@end
