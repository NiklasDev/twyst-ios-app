//
//  TSavedTwyst.h
//  Twyst
//
//  Created by Niklas Ahola on 9/24/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TStillframeRegular;

@interface TSavedTwyst : NSManagedObject

@property (nonatomic, retain) NSNumber * allowPass;
@property (nonatomic, retain) NSString * allowReplies;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * finalizedDate;
@property (nonatomic, retain) NSNumber * isAdmin;
@property (nonatomic, retain) NSNumber * isDelete;
@property (nonatomic, retain) NSNumber * isMyFeed;
@property (nonatomic, retain) NSNumber * isUnread;
@property (nonatomic, retain) NSNumber * memberCount;
@property (nonatomic, retain) NSNumber * ownerId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * totalFrames;
@property (nonatomic, retain) NSNumber * twystId;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * viewCount;
@property (nonatomic, retain) NSString * visibility;
@property (nonatomic, retain) NSString * passedBy;
@property (nonatomic, retain) NSSet *listStillframeRegular;
@end

@interface TSavedTwyst (CoreDataGeneratedAccessors)

- (void)addListStillframeRegularObject:(TStillframeRegular *)value;
- (void)removeListStillframeRegularObject:(TStillframeRegular *)value;
- (void)addListStillframeRegular:(NSSet *)values;
- (void)removeListStillframeRegular:(NSSet *)values;

@end
