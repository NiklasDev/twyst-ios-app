//
//  EditLargeImageView.h
//  Twyst
//
//  Created by Niklas Ahola on 7/5/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditCommentView;

@protocol EditLargeImageViewDelegate <NSObject>

- (void) editLargeImageViewDidChange:(NSInteger)index isSaved:(BOOL)isSaved;
- (void) editLargeImageViewTimer:(CGFloat)time;

@optional
- (void) editLargeImageViewFrameSaved:(NSInteger)index;
- (void) editLargeImageViewFrameDeleted;
- (void) editLargeImageViewLongTapDidCancel;

@end

@interface EditLargeImageView : UIView

@property (nonatomic, assign) CGFloat topBarHeight;
@property (nonatomic, assign) CGFloat bottomBarHeight;

@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) CGFloat timeOn;
@property (nonatomic, strong) EditCommentView *commentView;
@property (nonatomic, assign) id <EditLargeImageViewDelegate> delegate;

- (void) setSelectedImageIndex:(long)indexl;
- (void) reloadImageEffect;
- (void) saveActiveFrame;
- (BOOL) isCurrentFrameSaved;
- (UIImage *) getActiveFrame;

@end
