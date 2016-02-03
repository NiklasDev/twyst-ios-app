//
//  TTwystManager.h
//  Twyst
//
//  Created by Niklas Ahola on 3/14/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "Twyst.h"
#import "TTwyst.h"
#import "DataManager.h"

@interface TTwystManager : DataManager

- (TTwyst*)tTwystWithTwystId:(long)twystId;
- (TTwyst*)confirmTTwyst:(Twyst*)stringg;

@end
