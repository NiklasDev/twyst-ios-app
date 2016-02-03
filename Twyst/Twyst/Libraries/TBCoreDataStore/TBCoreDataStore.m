//
//  TBCoreDataStore.m
//  TBCoreDataStore
//
//  Created by Theodore Calmes on 1/3/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "TBCoreDataStore.h"
#import "NSFileManager+TBDirectories.h"
#import "NSManagedObjectID+TBString.h"

static NSString *const TBCoreDataModelFileName = @"TBExampleCoreDataModel";

@interface TBCoreDataStore ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSManagedObjectContext *defaultQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *privateQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *defaultPrivateQueueContext;

@end

@implementation TBCoreDataStore

static TBCoreDataStore *_defaultStore = nil;
+ (instancetype)defaultStore
{
    @synchronized(self) {
        if (!_defaultStore) {
            _defaultStore = [[self alloc] init];
        }
        return _defaultStore;
    }
}

#pragma mark - Singleton Access

+ (NSManagedObjectContext *)defaultQueueContext {
    return [[self defaultStore] defaultQueueContext];
}

+ (NSManagedObjectContext *)mainQueueContext
{
    return [[self defaultStore] mainQueueContext];
}

+ (NSManagedObjectContext *)privateQueueContext
{
    return [[self defaultStore] privateQueueContext];
}

+ (NSManagedObjectContext *)newMainQueueContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.parentContext = [self defaultPrivateQueueContext];
    
    return context;
}

+ (NSManagedObjectContext *)newPrivateQueueContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = [self defaultPrivateQueueContext];
    
    return context;
}

+ (NSManagedObjectContext *)defaultPrivateQueueContext
{
    return [[self defaultStore] defaultPrivateQueueContext];
}

+ (NSManagedObjectID *)managedObjectIDFromString:(NSString *)managedObjectIDString
{
    return [[[self defaultStore] persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:managedObjectIDString]];
}

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSavePrivateQueueContext:)name:NSManagedObjectContextDidSaveNotification object:[self privateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self mainQueueContext]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.mainQueueContext performBlock:^{
            [self.mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.privateQueueContext performBlock:^{
            [self.privateQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark - Getters

- (NSManagedObjectContext *)defaultQueueContext {
    if (!_defaultQueueContext) {
        _defaultQueueContext = [[NSManagedObjectContext alloc] init];
        _defaultQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _defaultQueueContext;
}

- (NSManagedObjectContext *)defaultPrivateQueueContext
{
    if (!_defaultPrivateQueueContext) {
        _defaultPrivateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _defaultPrivateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _defaultPrivateQueueContext;
}

- (NSManagedObjectContext *)mainQueueContext
{
    if (!_mainQueueContext) {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }

    return _mainQueueContext;
}

- (NSManagedObjectContext *)privateQueueContext
{
    if (!_privateQueueContext) {
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }

    return _privateQueueContext;
}

#pragma mark - Stack Setup

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error = nil;

        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self persistentStoreURL] options:[self persistentStoreOptions] error:&error]) {
            NSLog(@"Error adding persistent store. %@, %@", error, error.userInfo);
        }
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Twyst" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }

    return _managedObjectModel;
}

- (NSURL *)persistentStoreURL
{
    NSString *dbName = DEF_DATABASE_NAME;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dbName];
    return storeURL;
}

- (NSDictionary *)persistentStoreOptions
{
    return @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
