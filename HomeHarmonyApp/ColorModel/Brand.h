//
//  Brand.h
//  AugmentedRoom
//
//  Created by Joel Teply on 10/23/12.
//  Copyright (c) 2012 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ColorCategory;

@interface Brand : NSManagedObject

@property (nonatomic, retain) NSNumber * brand_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSSet *categories;
@end

@interface Brand (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(ColorCategory *)value;
- (void)removeCategoriesObject:(ColorCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
