//
//  PhotoCompileCircleProgress.h
//  Twyst
//
//  Created by Niklas Ahola on 4/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressView.h"
#import "FlipframePhotoModel.h"

@interface PhotoCompileCircleProgress : CircleProgressView <PhotoCompileProcessDelegate>

+ (void) startAutoWithParent:(UIView*)parent withComplete:(void (^)(void)) completion;
+(void) startWithParent:(UIView*) parent withPhotoModel:(FlipframePhotoModel*) photoModel Completion:(void (^)(void)) completion;

@end
