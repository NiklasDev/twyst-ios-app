//
//  FlipframePhotoModel.h
//  Twyst
//
//  Created by Niklas Ahola on 5/2/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipframeModel.h"
#import "FlipframeInputService.h"
#import "EditPhotoService.h"



@protocol PhotoCompileProcessDelegate <NSObject>

- (void) photoCompileCompleteSingleFPS:(NSInteger)currectFps withTotal:(NSInteger) totalFps;
- (void) photoCompileCompleteAllImages;

@end

@interface FlipframePhotoModel : FlipframeModel

@property (nonatomic, retain) FlipframeInputService *inputService;

//edit properties
@property (nonatomic, assign) BOOL isSun;
@property (nonatomic, assign) NSInteger filterIndex;//filter effect index: from 0 - 17, default = 0

@property (nonatomic, assign) CGSize videoSize;

@property (nonatomic, retain) NSMutableDictionary *dictImageSaved;
@property (nonatomic, retain) NSMutableArray *arrayDrawApplied;
@property (nonatomic, retain) NSMutableArray *arrayBlurApplied;
@property (nonatomic, retain) NSMutableDictionary *dictComment;

@property (nonatomic, assign) BOOL isCompletedEncode;

@property (nonatomic, assign) id <PhotoCompileProcessDelegate> processDelegate;


- (id) initWithType:(FlipframeInputType) inputType withService:(FlipframeInputService*) inputService;

//functions
- (NSInteger) totalFrames;
- (EditPhotoService *) getEditPhotoService;

- (UIImage*) serviceGetFullImageForBlur:(NSInteger)index;
- (UIImage*) serviceGetFullImageAtIndex:(NSInteger)index;
- (UIImage*) serviceGetThumbImageAtIndex:(NSInteger) index;
- (UIImage*) serviceGetFullOriginalImageAtIndex:(NSInteger)index;
- (UIImage*) serviceGetThumbOriginalImageAtIndex:(NSInteger)index;
- (UIImage*) serviceGetBackupOriginalImageAtIndex:(NSInteger)index;
- (UIImage*) serviceGetReplyImageAtIndex:(NSInteger)index;
- (UIImage*) serviceGetFinalImageAtIndex:(NSInteger)index;

- (void) serviceReplaceFullOriginalImageAtIndex:(NSInteger)index newImage:(UIImage*)newImage;
- (void) backUpOriginalFullImageAtIndex:(NSInteger)index;
- (void) serviceRestoreBackUpImageAtIndex:(NSInteger)index;

- (void) notifySavedImage:(NSInteger) imageIndex;
- (BOOL) canSaveFrameAtIndex:(NSInteger) index;
- (void) saveSingleFrameAtIndex: (NSInteger) index;
- (void) saveFrames:(NSArray *)saveIndexArray;

- (void) removeCurrentImage: (NSInteger) index;
- (void) deleteFrames:(NSArray *)deleteIndexArray;

- (BOOL)isDrawAppliedAtIndex:(NSInteger)index;
- (void)applyDrawingAtIndex:(NSInteger)index drawOverlay:(UIImage*)drawOverlay;
- (void)applyDrawingToAll:(UIImage*)drawOverlay competion:(void(^)())completion;
- (void)removeDrawingAtIndex:(NSInteger)index;
- (void)removeAllDrawing:(void(^)())completion;

- (void)setBlurAppliedAtIndex:(NSInteger)index isApplied:(BOOL)isApplied;
- (BOOL)isBlurAppliedAtIndex:(NSInteger)index;

- (void)setCommentAtIndex:(NSInteger)index comment:(NSString*)comment frame:(CGRect)frame;
- (NSString*)commentTextAtIndex:(NSInteger)index;
- (CGRect)commentFrameAtIndex:(NSInteger)index;

//photo compile
- (void) serviceCompileFlipframe:(void(^)())completion;

//video procesing
- (void) serviceEncodeFlipframe;
- (void) serviceCancelFlipframe;

@end
