//
//  TSavedTwystManager.m
//  Twyst
//
//  Created by Niklas Ahola on 9/1/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "UIImage+Device.h"

#import "UserWebService.h"
#import "FlipframeFileService.h"

#import "PhotoHelper.h"
#import "TTwystOwnerManager.h"
#import "TStillframeRegular.h"
#import "TSavedTwystManager.h"

@interface TSavedTwystManager() {
    FlipframeFileService *_fileService;
}

@end

@implementation TSavedTwystManager

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
        self.entityName = DEF_DB_ENTITY_NAME_TSavedTwyst;
        _fileService = [FlipframeFileService sharedInstance];
    }
    return self;
}

#warning ---- clear old twysts

- (TSavedTwyst*) savedTwystWithTwystId:(long)twystId {
    
    NSManagedObjectContext *privateMOC = [TBCoreDataStore privateQueueContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:privateMOC];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twystId==%ld", twystId];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"finalizedDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchLimit:1];
    
    NSArray *fetchedObjects = [privateMOC executeFetchRequest:fetchRequest error:nil];
    
    TSavedTwyst *savedTwyst = nil;
    if (fetchedObjects.count) {
        savedTwyst = [fetchedObjects firstObject];
        NSManagedObjectContext *mainMOC = [self managedObjectContext];
        savedTwyst = (TSavedTwyst*)[mainMOC objectWithID:savedTwyst.objectID];
    }
    return savedTwyst;
}

- (BOOL) isSavedTwystWithTwystId:(long)twystId {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twystId==%ld", twystId];
    [fetchRequest setPredicate:predicate];
    
    NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
    if (count == NSNotFound) {
        //handle error
        return NO;
    }
    else {
        return count;
    }
}

- (TSavedTwyst*) confirmSavedTwyst:(Twyst*)twyst arrFrames:(NSArray *)arrFrames {
    if ([self savedTwystWithTwystId:twyst.Id]) {
        return nil;
    }
    
    // save twyst information
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    TSavedTwyst *savedTwyst = [[TSavedTwyst alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    
    savedTwyst.caption = twyst.Caption;
    savedTwyst.twystId = [NSNumber numberWithLong:twyst.Id];
    savedTwyst.memberCount = [NSNumber numberWithInteger:twyst.MemberCount];
    savedTwyst.ownerId = [NSNumber numberWithLong:twyst.ownerId];
    savedTwyst.userId = [NSNumber numberWithLong:twyst.userId];
    savedTwyst.isDelete = [NSNumber numberWithBool:twyst.Deleted];
    savedTwyst.status = [NSNumber numberWithInteger:twyst.Status];
    savedTwyst.finalizedDate = twyst.DateFinalized;
    savedTwyst.isMyFeed = [NSNumber numberWithBool:twyst.isMyFeed];
    savedTwyst.isAdmin = [NSNumber numberWithBool:twyst.isAdmin];
    savedTwyst.isUnread = [NSNumber numberWithBool:YES];
    savedTwyst.allowReplies = twyst.AllowReplies;
    savedTwyst.allowPass = [NSNumber numberWithBool:twyst.AllowPass];
    savedTwyst.passedBy = twyst.PassedBy;
    savedTwyst.visibility = twyst.Visibility;
    savedTwyst.viewCount = [NSNumber numberWithInteger:twyst.ViewCount];
    
    //set list child images
    NSMutableSet *setFramePaths = [[NSMutableSet alloc] init];
    NSString *entityNameMStillframeRegular = DEF_DB_ENTITY_NAME_TStillframeRegular;
    NSEntityDescription *entityMStillframeRegular = [NSEntityDescription entityForName:entityNameMStillframeRegular inManagedObjectContext:self.managedObjectContext];
    long i = 0;
    for (i = 0; i < arrFrames.count; i++) {
        NSDictionary *frame = [arrFrames objectAtIndex:i];
        NSString *newChildPath = [frame objectForKey:@"path"];
        TStillframeRegular *stillframeRegular = [[TStillframeRegular alloc] initWithEntity:entityMStillframeRegular insertIntoManagedObjectContext:self.managedObjectContext];
        stillframeRegular.path = newChildPath;
        stillframeRegular.order = [NSNumber numberWithLong:i];
        stillframeRegular.userId = [frame objectForKey:@"userId"];
        stillframeRegular.isMovie = [frame objectForKey:@"isMovie"];
        stillframeRegular.replyIndex = [frame objectForKey:@"replyIndex"];
        stillframeRegular.frameTime = [frame objectForKey:@"frameTime"];
        [setFramePaths addObject:stillframeRegular];
    }
    
    [savedTwyst addListStillframeRegular:setFramePaths];
    savedTwyst.totalFrames = [NSNumber numberWithLong:i];
    
    //add to database
    if(![self saveObject:savedTwyst]) {
        return nil;
    }
    
    // save twyst owner information
    [[TTwystOwnerManager sharedInstance] confirmTwystOwnerWithOCUser:twyst.owner];
    
    return savedTwyst;
}

- (TSavedTwyst*) confirmDownloadedTwyst:(Twyst*)twyst arrFrames:(NSArray *)arrFrames {

    TSavedTwyst *savedTwyst = [self savedTwystWithTwystId:twyst.Id];
    
    // check if the twyst already exists in core data
    if (savedTwyst) {
        //remove all child image list
        [savedTwyst removeListStillframeRegular:savedTwyst.listStillframeRegular];
        
        //set list child images
        NSString *entityNameMStillframeRegular = DEF_DB_ENTITY_NAME_TStillframeRegular;
        NSEntityDescription *entityMStillframeRegular = [NSEntityDescription entityForName:entityNameMStillframeRegular inManagedObjectContext:self.managedObjectContext];

        long i = 0;
        NSMutableSet *setFramePaths = [[NSMutableSet alloc] init];
        for (NSDictionary *frame in arrFrames) {
            TStillframeRegular *stillframeRegular = [[TStillframeRegular alloc] initWithEntity:entityMStillframeRegular insertIntoManagedObjectContext:self.managedObjectContext];
            stillframeRegular.path = [frame objectForKey:@"path"];
            stillframeRegular.order = [NSNumber numberWithLong:i];
            stillframeRegular.userId = [frame objectForKey:@"userId"];
            stillframeRegular.isMovie = [frame objectForKey:@"isMovie"];
            stillframeRegular.replyIndex = [frame objectForKey:@"replyIndex"];
            stillframeRegular.frameTime = [frame objectForKey:@"frameTime"];
            [setFramePaths addObject:stillframeRegular];
            i++;
        }
        
        [savedTwyst addListStillframeRegular:setFramePaths];
        savedTwyst.isUnread = [NSNumber numberWithBool:YES];
        savedTwyst.totalFrames = [NSNumber numberWithInteger:i];
        
        //add to database
        if([self saveObject:savedTwyst]) {
            return savedTwyst;
        }
        else {
            return savedTwyst;
        }
    }
    else {
        return [self confirmSavedTwyst:twyst arrFrames:arrFrames];
    }
}

- (Twyst*)getTwystFromTSavedTwyst:(TSavedTwyst*)savedTwyst {
    Twyst *twyst = [Twyst createNewTwyst];
    twyst.Caption = savedTwyst.caption;
    twyst.Id = [savedTwyst.twystId longValue];
    twyst.MemberCount = [savedTwyst.memberCount integerValue];
    twyst.ownerId = [savedTwyst.ownerId longValue];
    twyst.userId = [savedTwyst.userId longValue];
    twyst.Deleted = [savedTwyst.isDelete boolValue];
    twyst.DateFinalized = savedTwyst.finalizedDate;
    twyst.Status = [savedTwyst.status integerValue];
    twyst.isMyFeed = [savedTwyst.isMyFeed boolValue];
    twyst.isAdmin = [savedTwyst.isAdmin boolValue];
    twyst.AllowReplies = savedTwyst.allowReplies;
    twyst.AllowPass = [savedTwyst.allowPass boolValue];
    twyst.PassedBy = savedTwyst.passedBy;
    twyst.Visibility = savedTwyst.visibility;
    twyst.ViewCount = [savedTwyst.viewCount integerValue];
    
    long ownerId = [savedTwyst.ownerId longValue];
    TTwystOwner *tOwner = [[TTwystOwnerManager sharedInstance] getOwnerWithUserId:ownerId];
    twyst.owner = [[TTwystOwnerManager sharedInstance] getOCUserFromTwystOwner:tOwner];
    return twyst;
}

- (void) deleteSavedTwyst:(TSavedTwyst*)savedTwyst {
    //remove image folder in document directory
    NSString *folderPath = nil;
    if (savedTwyst.listStillframeRegular.count > 0) {
        TStillframeRegular *stillRegular = [savedTwyst.listStillframeRegular anyObject];
        NSString *filePath = stillRegular.path;
        if (IsNSStringValid(filePath)) {
            NSString *fullPath = [_fileService generateFullDocPath:filePath];
            folderPath = [fullPath stringByDeletingLastPathComponent];
        }
    }
    
    NSError *error = nil;
    [[self managedObjectContext] deleteObject:savedTwyst];
    [[self managedObjectContext] save:&error];

    if (error)  {
        [FlipframeUtils logError:error];
    }
    else {
        if (IsNSStringValid(folderPath)) {
            [FlipframeUtils deleteFolder:folderPath];
        }
    }
}

- (TSavedTwyst*)addReplyToSavedTwyst:(long)twystId arrPaths:(NSArray*)arrPaths isMovie:(BOOL)isMovie frameTime:(NSInteger)frameTime {
    
    TSavedTwyst *savedTwyst = [self savedTwystWithTwystId:twystId];
    NSSet *setStillframes = savedTwyst.listStillframeRegular;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *frames = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    TStillframeRegular *lastFrame = [frames lastObject];
    NSInteger replyIndex = [lastFrame.replyIndex integerValue] + 1;
    
    long totalFrames = [savedTwyst.totalFrames longValue];
    NSString *entityNameMStillframeRegular = DEF_DB_ENTITY_NAME_TStillframeRegular;
    NSEntityDescription *entityMStillframeRegular = [NSEntityDescription entityForName:entityNameMStillframeRegular inManagedObjectContext:self.managedObjectContext];
    
    long order = totalFrames;
    for (NSString *filePath in arrPaths) {
        TStillframeRegular *stillframeRegular = [[TStillframeRegular alloc] initWithEntity:entityMStillframeRegular insertIntoManagedObjectContext:self.managedObjectContext];
        stillframeRegular.path = filePath;
        stillframeRegular.isMovie = [NSNumber numberWithBool:isMovie];
        stillframeRegular.order = [NSNumber numberWithLong:order];
        stillframeRegular.replyIndex = [NSNumber numberWithInteger:replyIndex];
        stillframeRegular.frameTime = [NSNumber numberWithInteger:frameTime];
        order++;
        
        OCUser *user = [Global getOCUser];
        stillframeRegular.userId = [NSNumber numberWithLong:user.Id];
        
        [[TTwystOwnerManager sharedInstance] confirmTwystOwnerWithOCUser:user];
        
        [savedTwyst addListStillframeRegularObject:stillframeRegular];
    }
    
    savedTwyst.totalFrames = [NSNumber numberWithLong:order];
    
    //add to database
    if ([self saveObject:savedTwyst]) {
        return savedTwyst;
    }
    else {
        return nil;
    }
}

- (NSInteger)getTwystReplyCount:(TSavedTwyst*)savedTwyst {
    NSSet *setStillframes = savedTwyst.listStillframeRegular;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *frames = [setStillframes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    TStillframeRegular *stillframeRegular = [frames lastObject];
    NSInteger savedZipCount = [stillframeRegular.replyIndex integerValue] + 1;
    return savedZipCount;
}

- (void)checkReplyAndDownload:(TSavedTwyst*)savedTwyst completion:(void(^)(BOOL isDownloaded, NSArray *replies))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        long twystId = [savedTwyst.twystId longValue];
        [[UserWebService sharedInstance] getTwystReplies:twystId completion:^(NSArray *replies) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger replyCount = [replies count];
                NSInteger savedReplyCount = [[TSavedTwystManager sharedInstance] getTwystReplyCount:savedTwyst];
                if (savedReplyCount >= replyCount) {
                    completion(YES, replies);
                }
                else {
                    completion(NO, replies);
                }
            });
        }];
    });
}

- (NSMutableArray*)filterReportedReplies:(NSArray*)replies {
    NSMutableArray *array = [NSMutableArray new];
    for (NSDictionary *reply in replies) {
        if ([[reply objectForKey:@"Reported"] boolValue]) {
            NSString *imageName = [reply objectForKey:@"ImageName"];
            imageName = [imageName stringByDeletingPathExtension];
            [array addObject:imageName];
        }
    }
    return array;
}

@end
