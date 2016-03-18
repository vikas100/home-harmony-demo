//
//  Color+Extended.m
//  ColorParser
//
//  Created by Joel Teply on 1/25/12.
//  Copyright (c) 2012 Digital Rising LLC. All rights reserved.
//

#import "Color+Extended.h"
#import <UIKit/UIKit.h>
#import <HomeAugmentation/HomeAugmentation.h>
#import "Brand.h"
#import "ColorCategory.h"

@implementation Color (Extended)

@dynamic uiColor;
@dynamic colorType;

+ (NSString *) colorTypeToString:(enum ColorType)colorType {
    
    switch (colorType) {
        case ColorTypeRed:
            return @"ColorTypeRed";
        case ColorTypeOrange:
            return @"ColorTypeOrange";
        case ColorTypeYellow:
            return @"ColorTypeYellow";
        case ColorTypeGreen:
            return @"ColorTypeGreen";
        case ColorTypeBlue:
            return @"ColorTypeBlue";
        case ColorTypePurple:
            return @"ColorTypePurple";
        case ColorTypeBrown:
            return @"ColorTypeBrown";
        case ColorTypeGrey:
            return @"ColorTypeGrey";
        case ColorTypeBlack:
            return @"ColorTypeBlack";
        case ColorTypeWhite:
            return @"ColorTypeWhite";
            
        default:
            return @"Undefined";
            break;
    }
}

- (UIColor *)uiColor;
{
    return [UIColor colorWithRed:[self.red doubleValue]/255.0f
                           green:[self.green doubleValue]/255.0f
                            blue:[self.blue doubleValue]/255.0f
                           alpha:1.0];
}

- (void) setUiColor:(UIColor *)uiColor;
{
    const CGFloat *components = uiColor ? CGColorGetComponents(uiColor.CGColor)
        : CGColorGetComponents([UIColor clearColor].CGColor);
    
    self.red = [NSNumber numberWithFloat:components[0] * 255.0f];
    self.green = [NSNumber numberWithFloat:components[1] * 255.0f];
    self.blue = [NSNumber numberWithFloat:components[2] * 255.0f];
}

- (void) scaleCVValue:(CGFloat[3])hsl hsl:(CGFloat[3])hslScaled {
    hslScaled[0] = hsl[0] * 360.0f;
    hslScaled[1] = hsl[1] * 100.0f;
    hslScaled[2] = hsl[2] * 100.0f;
}

- (void) getHSLScaled:(CGFloat[3])hslScaled {
    CGFloat hsl[3];
    
    [CBColoring convertRGB:self.uiColor toHSL:hsl];
    //[self.uiColor getHue:&hsv[0] saturation:&hsv[1] brightness:&hsv[2] alpha:nil];

    [self scaleCVValue:hsl hsl:hslScaled];
}

- (void) getHSVScaled:(CGFloat[3])hsvScaled {
    CGFloat hsv[3];
    
    [CBColoring convertRGB:self.uiColor toHSV:hsv];
    //[self.uiColor getHue:&hsv[0] saturation:&hsv[1] brightness:&hsv[2] alpha:nil];
    
    [self scaleCVValue:hsv hsl:hsvScaled];
}

- (enum ColorType) colorTypeExisting {
    CGFloat hsv[3];
    [self getHSLScaled:hsv];
    
    //monochrome
    
    if (hsv[2] <= 5) {
        //Blacks			L ≤ 5
        return ColorTypeBlack;
    } else if (hsv[2] > 89) {
        //Whites			L ≥ 89
        return ColorTypeWhite;
    } else if (hsv[1] <= 15) {
        //Grays		S ≤ 15	L = 6 – 88
        return ColorTypeGrey;
    }
    
    //lightness and saturations covered above
    
    //Purple H = 250 – 309	S > 15	L = 6 – 88
    else if (hsv[0] >= 250 && hsv[0] <= 309) {
        return ColorTypePurple;
    }
    //Reds	H  = 310 – 360 and 0 – 09	S > 15	L = 6 – 88
    else if ((hsv[0] >= 310 && hsv[0] <= 360) || (hsv[0] >= 0 && hsv[0] < 9)) {
        return ColorTypeRed;
    }
    //Oranges	H = 10 – 49	S > 15	L = 6 – 88
    else if (hsv[0] >= 10 && hsv[0] <= 49) {
        return ColorTypeOrange;
    }
    //Yellows	H = 50 – 64	S > 15	L = 6 – 88
    else if (hsv[0] >= 50 && hsv[0] <= 64) {
        return ColorTypeYellow;
    }
    //Greens	H = 65 – 169	S > 15	L = 6 – 88
    else if (hsv[0] >= 65 && hsv[0] <= 169) {
        return ColorTypeGreen;
    }
    //Blues	H = 170 – 249	S > 15	L = 6 – 88
    else if (hsv[0] >= 170 && hsv[0] <= 249) {
        return ColorTypeBlue;
    }
    
    return ColorTypeUndefined;
}

- (UIColor *) makeUIColor:(CGFloat [3])color;
{
    CGFloat scaled[3];
    scaled[0] = color[0] / 255.0f;
    scaled[1] = color[1] / 255.0f;
    scaled[2] = color[2] / 255.0f;
    
    return [UIColor colorWithRed:scaled[0] green:scaled[1] blue:scaled[2] alpha:1];
}

- (void) testColor:(NSString *)colorName rgb:(CGFloat [3])testRGB {
    UIColor *testColor = [self makeUIColor:testRGB];
    CGFloat testHSV[3], testHSL[3];
    [CBColoring convertRGB:testColor toHSV:testHSV];
    [self scaleCVValue:testHSV hsl:testHSV];
    [CBColoring convertRGB:testColor toHSL:testHSL];
    [self scaleCVValue:testHSL hsl:testHSL];
    enum ColorType testType = [self _colorTypeProposed:testHSV hsl:testHSL];
    
    NSLog(@"Test color %@ is type %@ with hsv:(%f,%f,%f)", colorName, [[self class] colorTypeToString:testType],
          testHSV[0], testHSV[1], testHSV[2]);
}

#define RED_END 10
#define ORANGE_END 40
#define YELLOW_END 65
#define GREEN_END 165
#define BLUE_END 225
#define PURPLE_END 335

#define BROWN_START 15
#define BROWN_END 38


- (enum ColorType) colorTypeProposed {
    CGFloat hsv[3];
    [self getHSVScaled:hsv];
    CGFloat hsl[3];
    [self getHSLScaled:hsl];
    
    enum ColorType initialType = [self _colorTypeProposed:hsv hsl:hsl];
    
    static BOOL ranTests = false;
    
    if (!ranTests) {
        CGFloat passionfruitRGB[3] = {241,136,113}; //484 Juicy Passionfruit
        [self testColor:@"404 Juicy Passionfruit" rgb:passionfruitRGB];
        CGFloat bajaWhiteRGB[3] = {231,218,200}; //Baja White
        [self testColor:@"bajaWhite" rgb:bajaWhiteRGB];
        CGFloat mimosaSatinRGB[3] = {244, 162, 142};
        [self testColor:@"mimosaSatin" rgb:mimosaSatinRGB];
        
        CGFloat pinkishYellow[3] = {254, 225, 198};
        [self testColor:@"pinkishYellow" rgb:pinkishYellow];
        
        ranTests = YES;
    }
    
    //return initialType;
    
    double delta = 0;
    
    switch (initialType) {
//        case ColorTypePurple:
//            delta = (PURPLE_END - BLUE_END);
//            break;
//        case ColorTypeBlue:
//            delta = BLUE_END - GREEN_END;
//            break;
//        case ColorTypeGreen:
//            delta = GREEN_END - YELLOW_END;
//            break;
//        case ColorTypeYellow:
//            delta = (YELLOW_END - ORANGE_END);
//            break;
//        case ColorTypeOrange:
//            delta = ORANGE_END - RED_END;
//            break;
        case ColorTypeRed:
            delta = -1 * ((RED_END + 360) - PURPLE_END);
            break;
        default:
            return initialType;
    }
    
    double multiplier = (100.0f - hsv[1]) / 100.0f;
    double offset = powf(fabs(multiplier), 2.2) * delta;
    
    hsv[0] += offset;
    if (hsv[0] < 0) hsv[0] += 360.0f;
    
    hsl[0] = hsv[0];
    
    return [self _colorTypeProposed:hsv hsl:hsl];
}

- (enum ColorType) _colorTypeProposed:(CGFloat [3])hsv hsl:(CGFloat [3])hsl {
    
    //double x = hsv[1];
    //double y = hsv[2];
    double H = hsv[0];
    double S = hsv[1]; //x
    double V = hsv[2]; //y
    
//    double whiteThresholdYOffset = 75.0f;
//    double whiteThresholdSlope = 25.0f / 50.0f;
//    double whiteTestY = whiteThresholdSlope * S + whiteThresholdYOffset;
    //double whiteTestY = (25.0f / 50.0f) * S + 75;
    
//    double brownThresholdYOffset = 100.0f;
//    double brownThresholdSlope = -50.0f / 100.0f;
//    double brownTestY = brownThresholdSlope * S + brownThresholdYOffset;
    //double brownTestY = ((-50.0f / 100.0f) * S + 100.0f);
    
//    double greyThresholdYOffset = 100.0f;
//    double greyThresholdSlope = -100.0f / 35.0f;
//    double greyTestY = greyThresholdSlope * S + greyThresholdYOffset;
    //double greyTestY = ((-100.0f / 35.0f) * S + 100.0f);
    
    /*
SELECT
    PAINT_COLOR_ID,
    PAINT_COLOR_NM,
    R, G, B,
    H, S, L,
    
SWITCH(
     L <= 10, "BLACK",
     L <= 0.5 * S + 75, "WHITE",
     
     L <= -2.8571428571 * S + 100.0 AND L >= 30, "GREY",
     L <= -2.8571428571 * S + 100.0 AND L < 30, "BLACK",
     
     H > 3 AND H <= 45 AND L < -0.5 * S + 100, "BROWN",
     
     H > 225 AND H <= 340, "PURPLE",
     
     H > 340 OR H <= 10, "RED",
     
     H > 10 AND H <= 40, "ORANGE",
     
     H > 40 AND H <= 65 AND L > 80, "YELLOW",
     H > 40 AND H <= 65 AND L <= 80, "GREEN",
     
     H > 65 AND H <= 169, "GREEN",
     H > 169 AND H <= 225, "BLUE"
     
     ) AS COLOR_TYPE
     
FROM SHEET1
     */
    
    
    if (V <= 10) {
        //Blacks
        return ColorTypeBlack;
    }
    else if (hsl[1] < 95 && (hsl[1] < 30 || hsl[2] > 93) && (hsl[2] > 89 || V >= ((25.0 / 50.0) * S + 90))) {
        //Whites
        return ColorTypeWhite;
    }
    else if (V > 30 && (hsl[1] < 5 || V <= ((-100.0 / 10.0) * S + 100.0))) {
        return ColorTypeGrey;
    }
    else if (V <= ((-100.0 / 20) * S + 120.0)) {
        //Grays
        if (V > 30) {
            return ColorTypeGrey;
        } else {
            return ColorTypeBlack;
        }
    }
    
    //lightness and saturations covered above
    
    //test for brown
    else if (H > BROWN_START && H <= BROWN_END && V < (-0.33 * S + 80)) {
        return ColorTypeBrown;
    }
    
    //Purple
    else if (H > BLUE_END && H <= PURPLE_END) {
        return ColorTypePurple;
    }
    //Reds
    else if (H > PURPLE_END || H <= RED_END) {
        //incorrect HSV: 0.000000,26.506024,32.549020
        return ColorTypeRed;
    }
    //Oranges
    else if (H > RED_END && H <= ORANGE_END) {
//        if (S <= 70) {
//            return ColorTypeBrown;
//        }
        return ColorTypeOrange;
    }
    //Yellows
    else if (H > ORANGE_END && H <= YELLOW_END) {
        if (hsl[1] < 30) {
            if (hsl[2] > 89) {
                return ColorTypeWhite;
            } else if (H <= BROWN_END) {
                return ColorTypeBrown;
            } else {
                return ColorTypeGreen;
            }
        }
        else if (V > 82) {
            return ColorTypeYellow;
        } else {
            return ColorTypeGreen;
        }
    }
    //Greens
    else if (H > YELLOW_END && H <= GREEN_END) {
        return ColorTypeGreen;
    }
    //Blues
    else if (H > GREEN_END && H <= BLUE_END) {
        if (H - GREEN_END < 10 && S < 50) {
            return ColorTypeGreen;
        }
        return ColorTypeBlue;
    }
    
    return ColorTypeUndefined;
}

-(enum ColorType) colorType {
    //return self.colorTypeExisting;
    return self.colorTypeProposed;
}

- (double) distanceFromUIColor:(UIColor *)color;
{
    return [CBColoring distance:color fromColor:self.uiColor];
}

+ (Color *) colorForLayer:(CBLayer *)layer {
    NSString *objectID = [layer.userData objectForKey:@"object_id"];
    if (objectID) {
        NSURL *objectURL = [NSURL URLWithString:objectID];
        Color *color = [[CBCoreData sharedInstance] getObjectWithUrl:objectURL];
        return color;
    }
    return nil;
}

- (void)setLayerColorInfo:(CBLayer *)layer {
    NSURL *url = self.objectID.URIRepresentation;
    NSString *value = [url absoluteString];
    //NSLog(@"setLayerColorInfo:%@, %@", self.name, value);
    [layer.userData setObject:value forKey:@"object_id"];
    layer.fillColor = self.uiColor;
}

+ (Color *)closestMatchForUIColor:(UIColor *)uiColor;
{
    NSArray *lotsOfColors = [NSArray array];
    int delta = 8;
    while ([lotsOfColors count] == 0 && delta < 100) {
        lotsOfColors = [self colorsMatchingUIColor:uiColor withinDelta:delta];
        delta = delta * 2;
    }
    return [self closestMatchForUIColor:uiColor withinColors:lotsOfColors excludingColors:NULL];
}

+ (Color *)closestMatchForUIColor:(UIColor *)uiColor brand:(Brand*)brand category:(ColorCategory*)category excludingColors:(NSArray *)colorsToExclude;
{
    if (!brand) {
        return [self closestMatchForUIColor:uiColor];
    }
    else if (category) {
        return [self closestMatchForUIColor:uiColor withinColors:category.colors excludingColors:colorsToExclude];
    }
    else {
        NSMutableArray * colors  = [NSMutableArray array];
        
        for (ColorCategory *category in brand.categories) {
            [colors addObjectsFromArray:category.colors.allObjects];
        }
        
        return [self closestMatchForUIColor:uiColor withinColors:colors excludingColors:colorsToExclude];
    }
}

+ (NSArray *)colorsMatchingUIColor:(UIColor *)uiColor withinDelta:(int)delta
{
    CGFloat r, g, b;
    [uiColor getRed:&r green:&g blue:&b alpha:nil];
    
    int red = 255.0 * r;
    if (red - delta < 0) red = delta;
    else if (red + delta > 255) red = 255 - delta;
    
    int green = 255.0 * g;
    if (green - delta < 0) green = delta;
    else if (green + delta > 255) green = 255 - delta;
    
    int blue = 255.0 * b;
    if (blue - delta < 0) blue = delta;
    else if (blue + delta > 255) blue = 255 - delta;
    
    
    NSMutableString *query = [NSMutableString stringWithString:@"(red > %i && red < %i\
                              && green > %i && green < %i\
                              && blue > %i && blue < %i)"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query,
                              red - delta, red + delta,
                              green - delta, green + delta,
                              blue - delta, blue + delta];
    
    return [[CBCoreData sharedInstance] getRecordsForClass:[Color class] predicate:predicate sortedBy:nil context:nil];
}

+ (Color *)closestMatchForUIColor:(UIColor *)uiColor
                     withinColors:(id<NSFastEnumeration>)colors
                  excludingColors:(NSArray *)colorsToExclude;
{
    double bestDistance = DBL_MAX;
    Color *bestColor;
    for (Color *color in colors) {
        if (colorsToExclude && [colorsToExclude containsObject:color]) {
            continue;
        }
        double distance = [color distanceFromUIColor:uiColor];
        if (distance < bestDistance) {
            bestDistance = distance;
            bestColor = color;
        }
    }
    
    return bestColor;
}

@end
