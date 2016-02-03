//
//  FlipagramTransition.h
//  Twyst
//
//  Created by Niklas Ahola on 9/3/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlipagramTransition : NSObject   {
    
}

@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, assign) int fpsCounter;
@property (nonatomic, assign) int fpsIndex;

- (void) startVideoWithSize:(CGSize) size;
- (void) loadImage:(UIImage*)image;
- (CVPixelBufferRef) pixelBuffer;

@end
