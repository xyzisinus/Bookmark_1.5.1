//
//  CoreDataUtility.m
//  Bookmark
//
//  Created by Barry Ezell on 4/15/11.
//  Copyright 2011 Dockmarket LLC. All rights reserved.
//

#import "CoreDataUtility.h"

#define DOCS_DIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@implementation CoreDataUtility

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;

static CoreDataUtility *_instance;

//Matt Galloway Singleton impl. http://iphone.galloway.me.uk/iphone-sdktutorials/singleton-classes/

+ (CoreDataUtility *)sharedUtility {
    @synchronized(self) {
		if (_instance == NULL) {
			_instance = [[self alloc] init];
		}
	}    
	return _instance;
}

+ (BOOL)save {
    NSError *error = nil;
    NSManagedObjectContext *context = [_instance managedObjectContext];
    [context save:&error];
    if (error) {
        DLog(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				DLog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		} else {
			DLog(@"  %@", [error userInfo]);
		}
        return NO;
    } else {
        return YES;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (void)release {
    // never release
}
- (id)autorelease {
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Bookmark" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [DOCS_DIR stringByAppendingPathComponent: @"BookmarkCore.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil 
                                                            URL:storeUrl 
                                                        options:options
                                                          error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		DLog(@"PersistentStoreCoordinator error %@, %@", error, [error userInfo]);
    }    
	
    return persistentStoreCoordinator;
}

#pragma mark - Utility methods

- (void)deleteDb {
    NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
    NSPersistentStore *store = [[persistentStoreCoordinator persistentStores] objectAtIndex:0];
    NSError *error;
    NSURL *storeURL = store.URL;
    
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    NSLog(@"--------Deleted DB-----------");
}

@end
