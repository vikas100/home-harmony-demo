//
//  Brand_Brandkk.h
//  PaintHarmonyTV
//
//  Created by Joel Teply on 10/30/15.
//  Copyright © 2015 com.cambriantech. All rights reserved.
//

#import "Brand+Extended.h"

#import <HomeAugmentation/CBCoreData.h>

@implementation Brand (Extended)

- (UIImage *) iconImage {
    return [UIImage imageNamed:self.icon];
}

+ (NSArray *) allBrands;
{
    NSArray *brands = [[CBCoreData sharedInstance] getRecordsForClass:[Brand class] predicate:nil sortedBy:nil context:nil];
    
    NSMutableArray *filteredBrands = [NSMutableArray array];
    for (Brand *brand in brands) {
        if ([brand.categories count]) {
            [filteredBrands addObject:brand];
        }
    }
    
    return filteredBrands;
}

@end
