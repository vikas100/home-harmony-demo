//
//  CBColoring.h
//  Cambrian
//
//  Created by Joel Teply on 11/4/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>

@interface CBColoring : NSObject

+ (NSArray *)complementsForColor:(UIColor *)color count:(int)count angle:(double)angleSpan;

+ (NSArray *)adjacentColors:(UIColor *)color count:(int)count angle:(double)angleSpan;

+ (NSArray *)shadesOfColor:(UIColor *)color count:(int)count;

+ (double)distance:(UIColor *)colorA
         fromColor:(UIColor *)colorB;

+ (double)distance:(UIColor *)colorA
         fromColor:(UIColor *)colorB
             asHSV:(BOOL)asHSV
       coefficient:(CGFloat[3])coefficient;

+ (void) convertRGB:(UIColor *)rgbColor toHSV:(CGFloat[3])hsv;
+ (void) convertRGB:(UIColor *)rgbColor toHSL:(CGFloat[3])hsl;

@end
