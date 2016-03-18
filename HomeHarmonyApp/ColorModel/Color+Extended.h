//
//  Color+Extended.h
//  ColorParser
//
//  Created by Joel Teply on 1/25/12.
//  Copyright (c) 2012 Digital Rising LLC. All rights reserved.
//

#import "Color.h"
#import <UIKit/UIKit.h>

@class Brand;
@class ColorCategory;

@interface Color (Extended)

enum ColorType : NSUInteger {
    ColorTypeUndefined,
    ColorTypeRed,
    ColorTypeOrange,
    ColorTypeYellow,
    ColorTypeGreen,
    ColorTypeBlue,
    ColorTypePurple,
    ColorTypeBrown,
    ColorTypeGrey,
    ColorTypeBlack,
    ColorTypeWhite
};


@property (nonatomic, retain) UIColor *uiColor;
@property (nonatomic, readonly) enum ColorType colorType;

#ifdef HOMEAUGMENTATION
- (double) distanceFromUIColor:(UIColor *)color;
- (void)setLayerColorInfo:(CBLayer *)layer;
+ (Color *) colorForLayer:(CBLayer *)layer;
#endif

+ (NSString *) colorTypeToString:(enum ColorType)colorType;

+ (Color *)closestMatchForUIColor:(UIColor *)uiColor brand:(Brand*)brand category:(ColorCategory*)category excludingColors:(NSArray *)colorsToExclude;

@end
