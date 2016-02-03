//
//  TLibraryTwyst.h
//  Twyst
//
//  Created by Niklas Ahola on 9/30/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TStillframeRegular;

@interface TLibraryTwyst : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * isMovie;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSNumber * totalFrames;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * frameTime;
@property (nonatomic, retain) NSSet *listStillframeRegular;
@end

@interface TLibraryTwyst (CoreDataGeneratedAccessors)

- (void)addListStillframeRegularObject:(TStillframeRegular *)value;
- (void)removeListStillframeRegularObject:(TStillframeRegular *)value;
- (void)addListStillframeRegular:(NSSet *)values;
- (void)removeListStillframeRegular:(NSSet *)values;

@end
