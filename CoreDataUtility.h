//
//  CoreDataUtility.h
//  Bookmark
//
//  Created by Barry Ezell on 4/15/11.
//  Copyright 2011 Dockmarket LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataUtility : NSObject {
    
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataUtility *)sharedUtility;
+ (BOOL)save;

- (void)deleteDb;

@end
