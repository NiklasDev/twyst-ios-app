//
//  TTwystNews.h
//  Twyst
//
//  Created by Lucas Pelizza on 8/5/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TTwystNews : NSManagedObject

@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSNumber * hasBadge;
@property (nonatomic, retain) NSNumber * isUnread;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSNumber * senderId;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSString * twystCaption;
@property (nonatomic, retain) NSNumber * twystId;
@property (nonatomic, retain) NSNumber * twystOwnerId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * userId;

@end
