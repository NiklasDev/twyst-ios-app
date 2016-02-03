//
//  TTwyst.h
//  Twyst
//
//  Created by Niklas Ahola on 9/24/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TTwyst : NSManagedObject

@property (nonatomic, retain) NSNumber * actionSenderId;
@property (nonatomic, retain) NSDate * actionTimeStamp;
@property (nonatomic, retain) NSString * actionType;
@property (nonatomic, retain) NSString * actionUsername;
@property (nonatomic, retain) NSNumber * allowPass;
@property (nonatomic, retain) NSString * allowReplies;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSDate * dateFinalized;
@property (nonatomic, retain) NSNumber * imageCount;
@property (nonatomic, retain) NSNumber * memberCount;
@property (nonatomic, retain) NSNumber * ownerId;
@property (nonatomic, retain) NSNumber * replyCount;
@property (nonatomic, retain) NSNumber * reported;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * twystId;
@property (nonatomic, retain) NSNumber * userLike;
@property (nonatomic, retain) NSNumber * viewCount;
@property (nonatomic, retain) NSString * visibility;
@property (nonatomic, retain) NSString * passedBy;

@end
