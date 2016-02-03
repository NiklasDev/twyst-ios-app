//
//  TwystInputService.h
//  Twyst
//
//  Created by Niklas Ahola on 3/25/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlipframeInputServiceDelegate <NSObject>

- (void) flipframeInputServiceDidCompleteImage:(NSString*)image atIndex:(NSInteger) index;
- (void) flipframeInputServiceDidCompleteAll;

@end

@interface FlipframeInputService : NSObject

@property (nonatomic, weak) id <FlipframeInputServiceDelegate> delegate;

@property (nonatomic, assign) NSInteger totalImages;

//array of NSString items for thumbnail
@property (nonatomic, retain) NSMutableArray *arrThumbPaths;

//array of NSString items for full images
@property (nonatomic, retain) NSMutableArray *arrFullImagePaths;

//array of NSString items for final images
@property (nonatomic, retain) NSMutableArray *arrFinalImagePaths;

@property (nonatomic, assign) BOOL isNotify;

- (void) startNotify;
- (void) resetAll;
- (UIImage *)getSinglePhotoAtIndex:(NSInteger)index;
- (UIImage *)getFinalPhotoAtIndex:(NSInteger)index;
- (void) replaceImageAtIndex:(NSInteger)index newImage:(UIImage*)newImage;
- (void) finalizeImageWithIndex:(NSInteger)index image:(UIImage*)image;

@end
