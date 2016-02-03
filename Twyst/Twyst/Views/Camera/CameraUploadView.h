//
//  CameraUploadView.h
//  Twyst
//
//  Created by Default on 7/28/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraUploadViewDelegate <NSObject>

- (void) uploadPhotoDidTouch;
- (void) uploadVideoDidTouch;

@end

@interface CameraUploadView : UIView

@property (nonatomic, assign) id <CameraUploadViewDelegate> delegate;

- (void) showInView:(UIView *)parentView;

@end
