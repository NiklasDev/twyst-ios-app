//
//  TwystModel.h
//  Twyst
//
//  Created by Niklas Ahola on 5/2/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlipframeSavedInfo.h"

@interface FlipframeModel : NSObject

@property (nonatomic, assign) FlipframeInputType inputType;

@property (nonatomic, retain) NSString *twystTheme;

@property (nonatomic, retain) FlipframeSavedInfo *savedInfo;

@property (nonatomic, assign) NSInteger frameTime;

- (NSString*) pathVideoOutput;
- (NSString*) pathImageOutput;

@end

