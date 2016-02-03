//
//  TwystRecoredEncoderDelegate.h
//  Twyst
//
//  Created by Niklas Ahola on 5/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FlipframePhotoModel.h"

@interface FlipframeRecoredEncoderDelegate : NSObject

- (id)initWithPhotoModel:(FlipframePhotoModel*) flipframeModel;

- (NSInteger) totalImages;
- (CGSize) videoSize;
- (NSString*) pathVideoOutput;
- (UIImage*) videoEncoderGetEffectImage:(NSInteger) index;

@end
