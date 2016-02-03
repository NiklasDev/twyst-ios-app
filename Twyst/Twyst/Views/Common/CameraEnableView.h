//
//  CameraEnableView.h
//  Twyst
//
//  Created by Niklas Ahola on 10/7/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraEnableViewDelegate <NSObject>

@optional
- (void)CameraEnableViewClicked:(UIView*)sender selectedIndex:(NSInteger)selectedIndex;
- (void)CameraEnableViewDidDismiss:(UIView*)sender;

@end

@interface CameraEnableView : UIView

@property (nonatomic, assign) id <CameraEnableViewDelegate> delegate;

+ (void)showInView:(UIView*)view target:(id)target;
- (void)reloadButtons;
- (void)hide;

@end
