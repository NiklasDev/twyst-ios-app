//
//  TTwystManager.m
//  Twyst
//
//  Created by Niklas Ahola on 3/14/15.
//  Copyright (c) 2015 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TTwystManager.h"
#import "TTwystOwnerManager.h"

@implementation TTwystManager

static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

- (id) init {
    self = [super init];
    if (self)   {
        self.entityName = DEF_DB_ENTITY_NAME_TTwyst;
    }
    return self;
}

- (TTwyst*)tTwystWithTwystId:(long)twystId {
    
    NSManagedObjectContext *privateMOC = [TBCoreDataStore privateQueueContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:privateMOC];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twystId==%ld", twystId];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setFetchLimit:1];
    
    NSArray *fetchedObjects = [privateMOC executeFetchRequest:fetchRequest error:nil];
    
    TTwyst *tTwyst = nil;
    if (fetchedObjects.count) {
        tTwyst = [fetchedObjects firstObject];
        NSManagedObjectContext *mainMOC = [self managedObjectContext];
        tTwyst = (TTwyst*)[mainMOC objectWithID:tTwyst.objectID];
    }
    return tTwyst;
}

- (TTwyst*)confirmTTwyst:(Twyst*)twyst {
    TTwyst *object = [self tTwystWithTwystId:twyst.Id];
    if (!object) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
        object = [[TTwyst alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    }
    
    object.twystId = [NSNumber numberWithLong:twyst.Id];
    object.caption = twyst.Caption;
    object.memberCount = [NSNumber numberWithInteger:twyst.MemberCount];
    object.status = [NSNumber numberWithInteger:twyst.Status];
    object.ownerId = [NSNumber numberWithLong:twyst.ownerId];
    object.dateFinalized = twyst.DateFinalized;
    object.allowReplies = twyst.AllowReplies;
    object.allowPass = [NSNumber numberWithBool:twyst.AllowPass];
    object.visibility = twyst.Visibility;
    object.replyCount = [NSNumber numberWithInteger:twyst.ReplyCount];
    object.imageCount = [NSNumber numberWithInteger:twyst.ImageCount];
    object.viewCount = [NSNumber numberWithInteger:twyst.ViewCount];
    object.passedBy = twyst.PassedBy;
    object.actionType = twyst.ActionType;
    object.actionUsername = twyst.ActionUserName;
    object.actionSenderId = [NSNumber numberWithLong:twyst.ActionSenderId];
    object.actionTimeStamp = twyst.ActionTimeStamp;
    
    //add to database
    if(![self saveObject:object]) {
        return nil;
    }
    
    // save stringg owner information
    [[TTwystOwnerManager sharedInstance] confirmTwystOwnerWithOCUser:twyst.owner];
    
    return object;
}

@end
