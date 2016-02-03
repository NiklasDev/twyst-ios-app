//
//  ALAssetsLibraryService.h
//  Twyst
//
//  Created by Niklas Ahola on 2/3/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibraryService : ALAssetsLibrary

+ (ALAssetsLibrary*)defaultAssetsLibrary;

@end
