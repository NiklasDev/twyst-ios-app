//
//  EditVideoView.h
//  Twyst
//
//  Created by Niklas Ahola on 4/23/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditCommentView;

@interface EditVideoView : UIView

@property (nonatomic, assign) CGFloat topBarHeight;
@property (nonatomic, assign) CGFloat bottomBarHeight;

@property (nonatomic, strong) UIImageView *imageDrawing;
@property (nonatomic, strong) EditCommentView *commentView;

- (void)playVideo;
- (void)playReverseVideoWithDuration:(CGFloat)duration completion:(void(^)(void))completion;
- (void)playReverseVideoWithDuration:(CGFloat)duration completion:(void(^)(void))completion progress:(void(^)(CGFloat totalTime, CGFloat currentTime))progress;
- (void)pauseVideo;
- (void)updateVideoCoverFrame;
- (void)updateVideoPlayRange;
- (void)setDrawingImage:(UIImage*)drawing;
- (CGFloat)currentPlaybackTime;

@end
