//
//  TTwystNewsManager.m
//  Twyst
//
//  Created by Niklas Ahola on 9/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "TTwystOwnerManager.h"
#import "TTwystNewsManager.h"

@implementation TTwystNewsManager

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
        self.entityName = DEF_DB_ENTITY_NAME_TTwystNews;
    }
    return self;
}

- (NSArray*)getAllNews {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:50];
    
    OCUser *user = [Global getOCUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %ld", user.Id];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    return fetchedObjects;
}

- (TTwystNews*)twystNewsWithNewsId:(long)newsId {
    
    NSManagedObjectContext *privateMOC = [TBCoreDataStore privateQueueContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:privateMOC];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"newsId==%ld", newsId];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setFetchLimit:1];
    
    NSArray *fetchedObjects = [privateMOC executeFetchRequest:fetchRequest error:nil];
    
    TTwystNews *news = nil;
    if (fetchedObjects.count) {
        news = [fetchedObjects firstObject];
        NSManagedObjectContext *mainMOC = [self managedObjectContext];
        news = (TTwystNews*)[mainMOC objectWithID:news.objectID];
    }
    return news;
}

- (TTwystNews*)twystNewsWithTwystId:(long)twystId type:(NSString*)type {
    
    NSManagedObjectContext *privateMOC = [TBCoreDataStore privateQueueContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:privateMOC];
    [fetchRequest setEntity:entity];
    
    OCUser *user = [Global getOCUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twystId == %ld AND type == %@ AND userId == %ld", twystId, type, user.Id];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [privateMOC executeFetchRequest:fetchRequest error:nil];
    
    if (fetchedObjects == nil) {
        NSLog(@"Could not delete Entity Objects");
    }
    
    TTwystNews *news = nil;
    if (fetchedObjects.count) {
        news = [fetchedObjects firstObject];
        NSManagedObjectContext *mainMOC = [self managedObjectContext];
        news = (TTwystNews*)[mainMOC objectWithID:news.objectID];
    }
    return news;
}

- (TTwystNews*)confirmTwystNews:(NSDictionary*)newsDic {
    
    OCUser *user = [Global getOCUser];
    
    // update sender information
    NSDictionary *senderDic = [newsDic objectForKey:@"OCUser"];
    NSDictionary *twystDic = [newsDic objectForKey:@"Stringg"];
    [[TTwystOwnerManager sharedInstance] confirmTwystOwnerWithUserDict:senderDic];
    
    // update news information
    long newsId = [[newsDic objectForKey:@"Id"] longValue];
    TTwystNews *news = [self twystNewsWithNewsId:newsId];
    if (news == nil) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
        news = [[TTwystNews alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    }
    
    NSString *Created = [newsDic objectForKey:@"TimeStamp"];
    Created = [Created substringToIndex:19];
    news.created = Created;
    news.userId = [NSNumber numberWithLong:user.Id];
    news.senderId = [newsDic objectForKey:@"SenderId"];
    news.type = [newsDic objectForKey:@"NewsType"];
    news.newsId = [newsDic objectForKey:@"Id"];
    news.twystId = [newsDic objectForKey:@"StringgId"];
    news.senderName = [senderDic objectForKey:@"UserName"];
    news.twystCaption = [twystDic objectForKey:@"Caption"];
    news.twystOwnerId = [twystDic objectForKey:@"UserId"];
    news.commentCount = [twystDic objectForKey:@"CommentCount"];
    news.isUnread = [NSNumber numberWithBool:YES];
    news.hasBadge = [NSNumber numberWithBool:YES];
    
    if ([[newsDic objectForKey:@"NewsType"] isEqualToString:@"comment"]) {
        news.commentId = [newsDic objectForKey:@"NewsText"];
    }
    
    //add to database
    if ([self saveObject:news]) {
        return news;
    }
    else {
        return nil;
    }
}

- (void)confirmUnlikeTwyst:(NSDictionary*)newsDic {
    long twystDic = [[newsDic objectForKey:@"StringgId"] longValue];
    long senderId = [[newsDic objectForKey:@"SenderId"] longValue];
    
    NSManagedObjectContext *privateMOC = [TBCoreDataStore privateQueueContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:privateMOC];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twystId == %ld AND type == %@ AND senderId == %ld", twystDic, @"Like", senderId];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [privateMOC executeFetchRequest:fetchRequest error:nil];
    
    if (fetchedObjects) {
        for (NSManagedObject *object in fetchedObjects) {
            [privateMOC deleteObject:object];
        }
        [privateMOC save:nil];
    }
}

- (TTwystNews*)confirmCommentTwyst:(NSDictionary*)newsDic {
    
    //update sender information
    NSDictionary *senderDic = [newsDic objectForKey:@"OCUser"];
    NSDictionary *twystDic = [newsDic objectForKey:@"Stringg"];
    [[TTwystOwnerManager sharedInstance] confirmTwystOwnerWithUserDict:senderDic];
    
    long stringgId = [[newsDic objectForKey:@"StringgId"] longValue];
    NSInteger commentCount = [[twystDic objectForKey:@"CommentCount"] integerValue];
    
    TTwystNews *news = [self twystNewsWithTwystId:stringgId type:@"comment"];
    if (commentCount == 0) {
        if (news) {
            [self deleteObject:news];
        }
        return nil;
    }
    
    if (news == nil) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
        news = [[TTwystNews alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    }
    
    OCUser *user = [Global getOCUser];
    
    NSString *Created = [newsDic objectForKey:@"TimeStamp"];
    Created = [Created substringToIndex:19];
    news.created = Created;
    news.userId = [NSNumber numberWithLong:user.Id];
    news.senderId = [newsDic objectForKey:@"SenderId"];
    news.type = [newsDic objectForKey:@"NewsType"];
    news.newsId = [newsDic objectForKey:@"Id"];
    news.twystId = [newsDic objectForKey:@"StringgId"];
    news.senderName = [senderDic objectForKey:@"UserName"];
    news.twystCaption = [twystDic objectForKey:@"Caption"];
    news.twystOwnerId = [twystDic objectForKey:@"UserId"];
    news.commentCount = [twystDic objectForKey:@"CommentCount"];
    
    long senderId = [[newsDic objectForKey:@"SenderId"] longValue];
    BOOL isUnread = [news.isUnread boolValue] || (senderId != user.Id);
    news.isUnread = [NSNumber numberWithBool:isUnread];
    news.hasBadge = [NSNumber numberWithBool:YES];

    if ([[newsDic objectForKey:@"NewsType"] isEqualToString:@"comment"]) {
        news.commentId = [newsDic objectForKey:@"NewsText"];
    }
    
    //add to database
    if ([self saveObject:news]) {
        return news;
    }
    else {
        return nil;
    }
}

- (TTwystNews*)confirmDeleteCommentTwyst:(NSDictionary*)newsDic {
    
    NSDictionary *senderDic = [newsDic objectForKey:@"OCUser"];
    NSDictionary *twystDic = [newsDic objectForKey:@"Stringg"];
    [[TTwystOwnerManager sharedInstance] confirmTwystOwnerWithUserDict:senderDic];
    
    long twystId = [[newsDic objectForKey:@"StringgId"] longValue];
    NSInteger commentCount = [[twystDic objectForKey:@"CommentCount"] integerValue];
    
    TTwystNews *news = [self twystNewsWithTwystId:twystId type:@"comment"];
    if (commentCount == 0) {
        if (news) {
            [self deleteObject:news];
        }
        return nil;
    }
    
    if (news == nil) {
        return nil;
    }
    
    OCUser *user = [Global getOCUser];
    
    news.userId = [NSNumber numberWithLong:user.Id];
    news.senderId = [newsDic objectForKey:@"SenderId"];
    news.twystId = [newsDic objectForKey:@"StringgId"];
    news.senderName = [senderDic objectForKey:@"UserName"];
    news.twystCaption = [twystDic objectForKey:@"Caption"];
    news.twystOwnerId = [twystDic objectForKey:@"UserId"];
    news.commentCount = [twystDic objectForKey:@"CommentCount"];
    
    if ([[newsDic objectForKey:@"NewsType"] isEqualToString:@"comment"]) {
        news.commentId = [newsDic objectForKey:@"NewsText"];
    }
    
    //add to database
    if ([self saveObject:news]) {
        return news;
    }
    else {
        return nil;
    }
}

- (void)deleteNewsWithTwystId:(long)twystId {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:100];
    
    OCUser *user = [Global getOCUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twystId == %ld AND userId == %ld", twystId, user.Id];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Could not delete Entity Objects");
    }
    else {
        [self deleteObjects:fetchedObjects];
    }
}

@end
