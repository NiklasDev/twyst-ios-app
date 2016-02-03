//
//  PhotoImportCircleProgress.h
//  Twyst
//
//  Created by Niklas Ahola on 8/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoRegularService.h"
#import "CircleProgressView.h"

@interface PhotoImportCircleProgress : CircleProgressView<PhotoImportServiceProcessDelegate>
+ (void) startAutoWithParent:(UIView*)parent withComplete:(void (^)(void)) completion;
+ (void) startVideoAutoWithParent:(UIView*)parent duration:(NSTimeInterval)duration withComplete:(void (^)(void)) completion;
+ (void) startWithParent:(UIView*) parent withImportService:(PhotoRegularService*) regularService Completion:(void (^)(void)) completion;
+ (void) removeInstance;

@end
