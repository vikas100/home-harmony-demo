//
//  CBCoreData.h
//  ColorParser
//
//  Created by Joel Teply on 1/24/12.
//  Copyright (c) 2012 Digital Rising LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CBCoreData : NSObject

@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) void(^willUpgradeBlock)(NSManagedObjectContext *oldContext, NSManagedObjectContext *newContext);

+ (id)sharedInstance;

- (id) getObjectWithID:(NSManagedObjectID *)objectID;

- (id) getObjectWithUrl:(NSURL *)url;

- (id) getFirstRecordForClass:(Class)inClass
                    predicate:(NSPredicate *)predicate;

- (id) getFirstRecordForClass:(Class)inClass
                    predicate:(NSPredicate *)predicate
                     sortedBy:(NSArray *)sortDescriptors
                      context:(NSManagedObjectContext *)context;

- (NSArray *) getRecordsForClass:(Class)inClass
                       predicate:(NSPredicate *)predicate;

- (NSArray *) getRecordsForClass:(Class)inClass
                       predicate:(NSPredicate *)predicate
                        sortedBy:(NSArray *)sortDescriptors
                         context:(NSManagedObjectContext *)context;

+ (NSString *) getErrorMeaning:(NSError *) error;
- (NSURL *) databaseUrl;

@end

