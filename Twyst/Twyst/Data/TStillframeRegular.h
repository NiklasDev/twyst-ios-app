//
//  TStillframeRegular.h
//  Twyst
//
//  Created by Niklas Ahola on 9/30/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TLibraryTwyst, TSavedTwyst;

@interface TStillframeRegular : NSManagedObject

@property (nonatomic, retain) NSNumber * isMovie;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * replyIndex;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * frameTime;
@property (nonatomic, retain) TLibraryTwyst *libraryTwyst;
@property (nonatomic, retain) TSavedTwyst *savedTwyst;

@end
