//
//  ColorCategory.h
//  VirtualPainter
//
//  Created by Joel Teply on 11/23/12.
//  Copyright (c) 2012 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Brand, Color;

@interface ColorCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * category_id;
@property (nonatomic, retain) NSNumber * group_size;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pro_only;
@property (nonatomic, retain) Brand *brand;
@property (nonatomic, retain) NSSet *colors;
@end

@interface ColorCategory (CoreDataGeneratedAccessors)

- (void)addColorsObject:(Color *)value;
- (void)removeColorsObject:(Color *)value;
- (void)addColors:(NSSet *)values;
- (void)removeColors:(NSSet *)values;
@end
