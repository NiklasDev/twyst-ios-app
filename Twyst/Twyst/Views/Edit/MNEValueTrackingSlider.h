//
//  CustomSlider.h
//  Measures
//
//  Created by Michael Neuwert on 4/26/11.
//  Copyright 2011 Neuwert Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MNESliderValuePopupView;
@class MNEValueTrackingSlider;

@protocol MNEValueTrackingSliderDelegate <NSObject>

@optional
- (void)sliderView:(MNEValueTrackingSlider*)slider valueDidChange:(CGFloat)value;

@end

@interface MNEValueTrackingSlider : UISlider {
    MNESliderValuePopupView *valuePopupView;
    CGFloat _popWidth;
    CGFloat _popHeight;
    CGFloat _popY;
    CGFloat _popMarginX;
}

@property (nonatomic, readonly) CGRect thumbRect;
@property (nonatomic, assign) id <MNEValueTrackingSliderDelegate> delegate;

@end