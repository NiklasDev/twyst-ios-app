//
//  DataManager.h
//  Twyst
//
//  Created by Niklas Ahola on 5/23/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBCoreDataStore.h"

@interface DataManager : NSObject

@property (nonatomic, retain) NSString* entityName;

+ (id) sharedInstance;

- (NSManagedObjectContext*) managedObjectContext;
- (NSEntityDescription*) entityDescription;

- (NSArray*) loadAll;
- (NSInteger) countAll;

- (BOOL) saveObject:(NSManagedObject*)obj;
- (void) deleteObject:(NSManagedObject*)obj;
- (void) deleteObjects:(NSArray*)objs;
- (void) deleteAllObjects;
- (BOOL) saveDatabase;

@end
