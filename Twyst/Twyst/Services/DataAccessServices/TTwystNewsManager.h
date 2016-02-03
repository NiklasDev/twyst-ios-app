//
//  TTwystNewsManager.h
//  Twyst
//
//  Created by Niklas Ahola on 9/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TTwystNews.h"
#import "DataManager.h"
#import "TTwystNewsManager.h"

@interface TTwystNewsManager : DataManager

- (NSArray*)getAllNews;
- (TTwystNews*)confirmTwystNews:(NSDictionary*)newsDic;
- (TTwystNews*)twystNewsWithNewsId:(long)newsId;

- (void)confirmUnlikeTwyst:(NSDictionary*)newsDic;
- (TTwystNews*)confirmCommentTwyst:(NSDictionary*)newsDic;
- (TTwystNews*)confirmDeleteCommentTwyst:(NSDictionary*)newsDic;

- (void)deleteNewsWithTwystId:(long)twystId;

@end
