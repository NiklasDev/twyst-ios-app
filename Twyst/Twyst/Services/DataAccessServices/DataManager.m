//
//  DataManager.m
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

static id _sharedObject = nil;
+ (id) sharedInstance   {
    @synchronized(self) {
        if (!_sharedObject) {
            _sharedObject = [[self alloc] init];
        }
        return _sharedObject;
    }
}

- (NSManagedObjectContext*) managedObjectContext    {
    return [TBCoreDataStore defaultQueueContext];
}

- (NSArray*) loadAll    {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Could not delete Entity Objects");
    }
    return fetchedObjects;
}

- (NSEntityDescription*) entityDescription {
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    return entity;
}

- (NSInteger) countAll {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:self.entityName inManagedObjectContext:[self managedObjectContext]]];
    
    NSUInteger count = [[self managedObjectContext] countForFetchRequest:request error:nil];
    
    if(count == NSNotFound) {
        return 0;
    }
    return count;
}

- (BOOL) saveObject:(NSManagedObject*)obj   {
    NSError *error;
    [obj.managedObjectContext save:&error];
    if (error)  {
        [FlipframeUtils logError:error];
        return NO;
    }
    else {
        return YES;
    }
}

- (void) deleteObject:(NSManagedObject*)obj {
    if (obj)    {
        [[self managedObjectContext] deleteObject:obj];
        [self saveDatabase];
    }
}

- (void) deleteObjects:(NSArray*)objs {
    for (NSManagedObject *obj in objs) {
        [self.managedObjectContext deleteObject:obj];
    }
    [self saveDatabase];
}

- (void) deleteAllObjects {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject * object in fetchedObjects) {
        [[self managedObjectContext] deleteObject:object];
    }
    [self saveDatabase];
}

- (BOOL) saveDatabase   {
    NSError *error;
    [[self managedObjectContext] save:&error];
    if (error)  {
        [FlipframeUtils logError:error];
        return NO;
    }
    else {
        return YES;
    }
}

@end
