//
//  CBPrimative.h
//  Cambrian
//
//  Created by Joel Teply on 11/21/11.
//  Copyright (c) 2011 Digital Rising LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>

@interface CBPrimative : NSObject

- (void) clear;
- (void) drawPixelAtPoint:(CGPoint)point
                    color:(UIColor *)color;

- (void) drawRectangle:(CGRect)rect color:(UIColor *)color;
- (void) drawCircleAtPoint:(CGPoint)point radius:(int)radius color:(UIColor *)color;

@end
