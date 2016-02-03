//
//  FlipframePhotoModel.m
//  Twyst
//
//  Created by Niklas Ahola on 5/2/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FlipframePhotoModel.h"
#import "FlipframeRecoredEncoderDelegate.h"
#import "LibraryFlipframeServices.h"
#import "FlipframeFileService.h"
#import "FlipframeVideoEncoderService.h"

@interface FlipframePhotoModel() {
    EditPhotoService *_editPhotoService;
    FlipframeFileService *_fileService;
    FlipframeRecoredEncoderDelegate *_encoderDelegate;
}

@end

@implementation FlipframePhotoModel
- (id) initWithType:(FlipframeInputType) inputType withService:(FlipframeInputService*) inputService    {
    self = [super init];
    if (self)   {
        _fileService = [FlipframeFileService sharedInstance];
        _editPhotoService = [[EditPhotoService alloc] init];
        
        self.inputType = inputType;
        self.inputService = inputService;
        
        self.isSun = NO;
        self.filterIndex = 0;
        
        self.videoSize = CGSizeMake(DEF_TWYST_IMAGE_WIDTH, DEF_TWYST_IMAGE_HEIGHT);

        self.dictImageSaved = [[NSMutableDictionary alloc] init];
        
        NSInteger totalImages = _inputService.totalImages;
        self.arrayDrawApplied = [[NSMutableArray alloc] initWithCapacity:totalImages];
        self.arrayBlurApplied = [[NSMutableArray alloc] initWithCapacity:totalImages];
        for (NSInteger i = 0; i < totalImages; i++) {
            NSNumber *drawApplied = [NSNumber numberWithBool:NO];
            [self.arrayDrawApplied addObject:drawApplied];
            [self.arrayBlurApplied addObject:drawApplied];
        }
        
        self.dictComment = [[NSMutableDictionary alloc] init];
        
        [self actionRefreshSavedInfo];
        
        _encoderDelegate = [[FlipframeRecoredEncoderDelegate alloc] initWithPhotoModel:self];
    }
    return self;
}

#pragma PUBLIC methods
- (NSString*) pathVideoOutput   {
    //save video to temp directory
    NSString *path = [_fileService generateVideoFilePath];
    return path;
}

- (NSString*) pathImageOutput   {
    NSString *imageName = DEF_IMAGE_OUTPUT_NAME;
    NSString *path = [self.savedInfo.folderPath stringByAppendingPathComponent:imageName];
    return path;
}

- (NSInteger) totalFrames {
    return self.inputService.totalImages;
}

- (EditPhotoService *) getEditPhotoService {
    return _editPhotoService;
}

- (UIImage*) serviceGetFullImageForBlur:(NSInteger)index {
    @autoreleasepool {
        if (index < self.inputService.arrFullImagePaths.count)    {
            NSString *path = [self.inputService.arrFullImagePaths objectAtIndex:index];
            UIImage *srcImage = [UIImage imageWithContentsOfFile:path];
            if (self.isSun)   {
                srcImage = [_editPhotoService brightnessAndContrast:srcImage];
            }
            srcImage = [_editPhotoService filterImage:srcImage withIndex:self.filterIndex];
            srcImage = [self getImageWithDrawing:index srcImage:srcImage];
            return srcImage;
        }   else    {
            return nil;
        }
    }
}

- (UIImage*) serviceGetFullImageAtIndex:(NSInteger)index {
    @autoreleasepool {
        if (index < self.inputService.arrFullImagePaths.count)    {
            NSString *path = [self.inputService.arrFullImagePaths objectAtIndex:index];
            UIImage *srcImage = [UIImage imageWithContentsOfFile:path];
            if (self.isSun)   {
                srcImage = [_editPhotoService brightnessAndContrast:srcImage];
            }
            srcImage = [_editPhotoService filterImage:srcImage withIndex:self.filterIndex];
            srcImage = [self getImageWithDrawing:index srcImage:srcImage];
            return srcImage;
        }   else    {
            return nil;
        }
    }
}

- (UIImage*) serviceGetThumbImageAtIndex:(NSInteger) index    {
    if (index < self.inputService.arrThumbPaths.count)    {
        NSString *path = [self.inputService.arrThumbPaths objectAtIndex:index];
        UIImage *srcImage = [UIImage imageWithContentsOfFile:path];
        @autoreleasepool {
            EditPhotoService *newEditPhotoService = [[EditPhotoService alloc] init];
            if (self.isSun)   {
                srcImage = [newEditPhotoService brightnessAndContrast:srcImage];
            }
            if (self.filterIndex > 0)   {
                srcImage = [newEditPhotoService filterImage:srcImage withIndex:self.filterIndex];
            }
            srcImage = [self getImageWithDrawing:index srcImage:srcImage];
        }
        return srcImage;
    }   else    {
        return nil;
    }
}

- (UIImage*) serviceGetFullOriginalImageAtIndex:(NSInteger)index {
    if (index < self.inputService.arrFullImagePaths.count)    {
        NSString *path = [self.inputService.arrFullImagePaths objectAtIndex:index];
        UIImage *srcImage = [UIImage imageWithContentsOfFile:path];
        return srcImage;
    }   else    {
        return nil;
    }
}

- (UIImage*) serviceGetThumbOriginalImageAtIndex:(NSInteger)index {
    if (index < self.inputService.arrFullImagePaths.count)    {
        NSString *path = [self.inputService.arrThumbPaths objectAtIndex:index];
        UIImage *srcImage = [UIImage imageWithContentsOfFile:path];
        return srcImage;
    }   else    {
        return nil;
    }
}

- (UIImage*) serviceGetBackupOriginalImageAtIndex:(NSInteger)index {
    NSString *srcPath = [self.inputService.arrFullImagePaths objectAtIndex:index];
    NSString *path = [_fileService generateCapturingBackUpFilePath:srcPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIImage *backupImage = [UIImage imageWithContentsOfFile:path];
        return backupImage;
    }
    else {
        return [self serviceGetFullOriginalImageAtIndex:index];
    }
}

- (UIImage*) serviceGetReplyImageAtIndex:(NSInteger)index {
    UIImage *image = [self serviceGetFullImageAtIndex:index];
    if (image) {
        NSString *comment = [self commentTextAtIndex:index];
        if (IsNSStringValid(comment)) {
            CGRect frame = [self commentFrameAtIndex:index];
            image = [FlipframeUtils addReplyComment:image comment:comment frame:frame];
        }
    }
    return image;
}

- (UIImage*) serviceGetFinalImageAtIndex:(NSInteger)index {
    return [_inputService getFinalPhotoAtIndex:index];
}

- (void) serviceReplaceFullOriginalImageAtIndex:(NSInteger)index newImage:(UIImage*)newImage {
    [self.inputService replaceImageAtIndex:index newImage:newImage];
}

- (void) backUpOriginalFullImageAtIndex:(NSInteger)index {
    NSString *srcPath = [self.inputService.arrFullImagePaths objectAtIndex:index];
    NSString *backupFilePath = [_fileService generateCapturingBackUpFilePath:srcPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:backupFilePath]) {
        
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:backupFilePath error:&error];
        if (error) {
            [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:backupFilePath error:&error];
        }
    }
}

- (void) serviceRestoreBackUpImageAtIndex:(NSInteger)index {
    UIImage *backUpImage = [self serviceGetBackupOriginalImageAtIndex:index];
    [self serviceReplaceFullOriginalImageAtIndex:index newImage:backUpImage];
}

#pragma mark - save related methods
- (void) notifySavedImage:(NSInteger) imageIndex  {
    NSMutableDictionary *dictCurrentFilter = [self.dictImageSaved objectForKey:[NSNumber numberWithInteger:self.filterIndex]];
    if (dictCurrentFilter == nil)   {
        dictCurrentFilter = [[NSMutableDictionary alloc] init];
    }
    [dictCurrentFilter setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithLong:imageIndex]];
    [self.dictImageSaved setObject:dictCurrentFilter forKey:[NSNumber numberWithInteger:self.filterIndex]];
}

- (BOOL) canSaveFrameAtIndex:(NSInteger) index    {
    NSNumber *numFilterIndex = [NSNumber numberWithInteger:self.filterIndex];
    NSMutableDictionary *dictSavedFilter = [self.dictImageSaved objectForKey:numFilterIndex];
    
    NSNumber *numImageIndex = [NSNumber numberWithLong:index];
    NSNumber *numObject = [dictSavedFilter objectForKey:numImageIndex];
    if (numObject) {
        BOOL value = [numObject boolValue];
        if (value)
            return NO;
    }
    return YES;
}

- (void) saveSingleFrameAtIndex: (NSInteger) index    {
    //save to disk
    @autoreleasepool {
        UIImage *image = [self serviceGetFullImageAtIndex:index];
        if ([Global getConfig].isSaveVideo) {
            //save to camera roll
            [self saveSingleFrameToAlbum:image];
        }
    }
}

- (void) saveFrames:(NSArray *)saveIndexArray {
    NSInteger totalCount = [self totalFrames];
    for (NSInteger i = 0; i < totalCount; i++) {
        NSNumber *index = [saveIndexArray objectAtIndex:i];
        if ([index boolValue] == YES) {
            if ([self canSaveFrameAtIndex:i]) {
                [self saveSingleFrameAtIndex:i];
                [self notifySavedImage:i];
            }
        }
    }
}

- (void)saveSingleFrameToAlbum:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - delete related mothods
- (void) removeCurrentImage: (NSInteger) index    {
    //remove from dict saved images
    for (NSNumber *numFilterIndex in [self.dictImageSaved allKeys])    {
        NSMutableDictionary *dictSavedFilter = [self.dictImageSaved objectForKey:numFilterIndex];
        
        BOOL isChange = NO;
        for (NSInteger imageIndex = 0; imageIndex < self.totalFrames; imageIndex++) {
            
            NSNumber *numImageIndex = [NSNumber numberWithInteger:imageIndex];
            NSNumber *numObject = [dictSavedFilter objectForKey:numImageIndex];
            if (numObject)  {
                if (imageIndex == index)    {
                    isChange = YES;
                    NSNumber *curObject = [NSNumber numberWithInt:0];
                    [dictSavedFilter setObject:curObject forKey:numImageIndex];
                } else if (imageIndex > index)    {
                    isChange = YES;
                    
                    //move to left
                    NSNumber *newKey = [NSNumber numberWithInteger:(imageIndex - 1)];
                    [dictSavedFilter setObject:numObject forKey:newKey];
                    
                    //set object to 0
                    NSNumber *curObject = [NSNumber numberWithInt:0];
                    [dictSavedFilter setObject:curObject forKey:numImageIndex];
                }
            }
        }
        if (isChange)   {
            [self.dictImageSaved setObject:dictSavedFilter forKey:numFilterIndex];
        }
    }
    
    //remove from draw applied array
    [self.arrayDrawApplied removeObjectAtIndex:index];
    [self.arrayBlurApplied removeObjectAtIndex:index];
    
    //delete image
    NSString *pathFull = [self.inputService.arrFullImagePaths objectAtIndex:index];
    NSString *pathThumb = [self.inputService.arrThumbPaths objectAtIndex:index];
    [FlipframeUtils deleteFileOrFolder:pathFull];
    [FlipframeUtils deleteFileOrFolder:pathThumb];
    
    [self.inputService.arrFullImagePaths removeObjectAtIndex:index];
    [self.inputService.arrThumbPaths removeObjectAtIndex:index];
    
    self.inputService.totalImages--;
}

- (void) deleteFrames:(NSArray *)deleteIndexArray {
    NSInteger totalCount = [self totalFrames];
    for (NSInteger i = totalCount - 1; i >= 0; i--) {
        NSNumber *index = [deleteIndexArray objectAtIndex:i];
        if ([index boolValue] == YES) {
            [self removeCurrentImage:i];
        }
    }
}

- (void) actionRefreshSavedInfo {
    self.isCompletedEncode = NO;
    self.savedInfo = [[FlipframeSavedInfo alloc] init];
    self.savedInfo.folderPath = [_fileService generateRegularFolderPath];
}

#pragma mark - draw related methods
- (BOOL)isDrawAppliedAtIndex:(NSInteger)index {
    NSNumber *drawApplied = [self.arrayDrawApplied objectAtIndex:index];
    return [drawApplied boolValue];
}

- (void)applyDrawingAtIndex:(NSInteger)index drawOverlay:(UIImage*)drawOverlay {
    @autoreleasepool {
        NSString *srcPath = [self.inputService.arrFullImagePaths objectAtIndex:index];
        NSString *drawingFilePath = [_fileService generateDrawingFilePath:srcPath];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if ([fm fileExistsAtPath:drawingFilePath isDirectory:&isDirectory]) {
            UIImage *prevDrawing = [UIImage imageWithContentsOfFile:drawingFilePath];
            drawOverlay = [FlipframeUtils applyDrawingOverlay:prevDrawing overlay:drawOverlay];
            [fm removeItemAtPath:drawingFilePath error:nil];
        }
        
        NSData *imageData = UIImagePNGRepresentation(drawOverlay);
        [imageData writeToFile:drawingFilePath atomically:YES];
    }
    
    NSNumber *drawApplied = [NSNumber numberWithBool:YES];
    [self.arrayDrawApplied replaceObjectAtIndex:index withObject:drawApplied];
}

- (void)applyDrawingToAll:(UIImage*)drawOverlay competion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger totalFrames = [self totalFrames];
        for (NSInteger i = 0; i < totalFrames; i++) {
            [self applyDrawingAtIndex:i drawOverlay:drawOverlay];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)removeDrawingAtIndex:(NSInteger)index {
    if ([self isDrawAppliedAtIndex:index]) {
        NSString *srcPath = [self.inputService.arrFullImagePaths objectAtIndex:index];
        NSString *drawingFilePath = [_fileService generateDrawingFilePath:srcPath];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        if ([fm fileExistsAtPath:drawingFilePath isDirectory:&isDirectory]) {
            [fm removeItemAtPath:drawingFilePath error:nil];
        }
        
        NSNumber *drawApplied = [NSNumber numberWithBool:NO];
        [self.arrayDrawApplied replaceObjectAtIndex:index withObject:drawApplied];
    }
}

- (void)removeAllDrawing:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger totalFrames = [self totalFrames];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        for (NSInteger i = 0; i < totalFrames; i++) {
            NSString *srcPath = [self.inputService.arrFullImagePaths objectAtIndex:i];
            NSString *drawingFilePath = [_fileService generateDrawingFilePath:srcPath];
            
            BOOL isDirectory = NO;
            if ([fm fileExistsAtPath:drawingFilePath isDirectory:&isDirectory]) {
                [fm removeItemAtPath:drawingFilePath error:nil];
            }
            
            NSNumber *drawApplied = [NSNumber numberWithBool:NO];
            [self.arrayDrawApplied replaceObjectAtIndex:i withObject:drawApplied];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (UIImage*)getImageWithDrawing:(NSInteger)index srcImage:(UIImage*)srcImage {
    if ([self isDrawAppliedAtIndex:index]) {
        NSString *srcPath = [self.inputService.arrFullImagePaths objectAtIndex:index];
        NSString *drawingFilePath = [_fileService generateDrawingFilePath:srcPath];
        UIImage *drawing = [UIImage imageWithContentsOfFile:drawingFilePath];
        if (drawing) {
            srcImage = [FlipframeUtils applyDrawingOverlay:srcImage overlay:drawing];
        }
    }
    return srcImage;
}

#pragma mark - blur related methods
- (void)setBlurAppliedAtIndex:(NSInteger)index isApplied:(BOOL)isApplied {
    [self.arrayBlurApplied replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:isApplied]];
}

- (BOOL)isBlurAppliedAtIndex:(NSInteger)index {
    NSNumber *blurApplied = [self.arrayBlurApplied objectAtIndex:index];
    return [blurApplied boolValue];
}

#pragma mark - comment related methods
- (void)setCommentAtIndex:(NSInteger)index comment:(NSString*)comment frame:(CGRect)frame {
    NSNumber *key = [NSNumber numberWithInteger:index];
    if (IsNSStringValid(comment)) {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", [NSValue valueWithCGRect:frame], @"frame", nil];
        [self.dictComment setObject:data forKey:key];
    }
    else {
        [self.dictComment removeObjectForKey:key];
    }
}

- (NSString*)commentTextAtIndex:(NSInteger)index {
    NSNumber *key = [NSNumber numberWithInteger:index];
    
    NSString *comment = nil;
    if ([[self.dictComment allKeys] containsObject:key]) {
        comment = [[self.dictComment objectForKey:key] objectForKey:@"comment"];
    }
    return comment;
}

- (CGRect)commentFrameAtIndex:(NSInteger)index {
    NSNumber *key = [NSNumber numberWithInteger:index];
    
    CGRect frame = CGRectZero;
    if ([[self.dictComment allKeys] containsObject:key]) {
        NSValue *value = [[self.dictComment objectForKey:key] objectForKey:@"frame"];
        frame = [value CGRectValue];
    }
    return frame;
}

#pragma mark - compile photo methods
- (void) serviceCompileFlipframe:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger total = [self totalFrames];
        for(NSInteger i = 0; i < total; i++) {
            
            [self.processDelegate photoCompileCompleteSingleFPS:i + 1 withTotal:total];
            
            @autoreleasepool {
                if (i < self.inputService.arrFullImagePaths.count)    {
                    NSString *path = [self.inputService.arrFullImagePaths objectAtIndex:i];
                    UIImage *srcImage = [UIImage imageWithContentsOfFile:path];
                    
                    // add sun and filter effect;
                    if (self.isSun)   {
                        srcImage = [_editPhotoService brightnessAndContrast:srcImage];
                    }
                    
                    srcImage = [_editPhotoService filterImage:srcImage withIndex:self.filterIndex];
                    
                    srcImage = [self getImageWithDrawing:i srcImage:srcImage];
                    
                    // add comment
                    NSString *comment = [self commentTextAtIndex:i];
                    if (IsNSStringValid(comment)) {
                        CGRect frame = [self commentFrameAtIndex:i];
                        srcImage = [FlipframeUtils addReplyComment:srcImage comment:comment frame:frame];
                    }
                    
                    // save as final image
                    [_inputService finalizeImageWithIndex:i image:srcImage];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.processDelegate performSelector:@selector(photoCompileCompleteAllImages)];
            completion();
        });
    });
}

#pragma mark - video processing methods
- (void) serviceEncodeFlipframe {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.isCompletedEncode) {
            [self actionRefreshSavedInfo];
        }
        if (_encoderDelegate.totalImages == 1) {
            UIImage *image = [_encoderDelegate videoEncoderGetEffectImage:0];
            [self saveSingleFrameToAlbum:image];
        }
        else {
            [[FlipframeVideoEncoderService sharedInstance] createFlipframeInputDelegate:_encoderDelegate withComplete:^(NSString *videoPath) {
                UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError: contextInfo:), nil);
            }];
        }
    });
}

- (void) image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        if ([error code] == ALAssetsLibraryWriteBusyError) {
            [self saveSingleFrameToAlbum:image];
        }
    }
    else {
        NSLog(@"------ save image success ------");
    }
}

- (void) video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (!error) {
        NSLog(@"------ save video success ------");
    }
    else {
        NSLog(@"------ save video failed ------");
    }
}

- (void) serviceCancelFlipframe {
    [[FlipframeVideoEncoderService sharedInstance] cancelEncode];
}

#pragma end-public

#pragma mark - Internal-action
- (void)dealloc {
    
}

@end
