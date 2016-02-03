//
//  BezierInterpView.h
//  Twyst
//
//  Created by Niklas Ahola on 09/07/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BezierInterpViewDelegate <NSObject>

- (void)bezierInterpViewDrawDidBegin:(id)sender;
- (void)bezierInterpViewDrawDidEnd:(id)sender;

@end

@interface BezierInterpView : UIView

@property (nonatomic, assign) id <BezierInterpViewDelegate> delegate;

@property (nonatomic,retain)  UIImage *incrementalImage;

@property (nonatomic,retain)  UIBezierPath *path;
@property (nonatomic, retain) UIBezierPath *rectpath;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, retain) UIColor * lineColor;

@property (nonatomic, assign) BOOL isChanged;
 
- (void)drawBitmap;
- (UIImage *)getFinalImage;

- (void)clear;
- (void) undo;
- (void) redo;
- (void) onErase:(BOOL)flag;
- (void) onMultipleTouch:(BOOL)isMultiple;

- (BOOL)isUndoable;

@end
