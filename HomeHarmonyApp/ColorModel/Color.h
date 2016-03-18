//
//  Color.h
//  VirtualPainter
//
//  Created by Joel Teply on 11/16/12.
//  Copyright (c) 2012 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ColorCategory;

@interface Color : NSManagedObject

@property (nonatomic, retain) NSNumber * blue;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * color_id;
@property (nonatomic, retain) NSNumber * green;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * red;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) ColorCategory *category;

@end
