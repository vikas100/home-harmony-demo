//
//  CBColorFinder.h
//  HomeAugmentation
//
//  Created by Joel Teply on 4/23/15.
//  Copyright (c) 2015 Joel Teply. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBImage.h"

@interface CBColorFinder : UIImageView

@property (nonatomic, copy) void(^colorTouchedAtPoint)(TouchStep touchType, CGPoint point, UIColor *color);

- (NSArray *) getMostCommonColors:(int)count type:(CBColorType)type;

@end
