//
//  CBLayer.h
//  Cambrian
//
//  Created by Joel Teply on 11/19/11.
//  Copyright (c) 2011 Digital Rising LLC. All rights reserved.
//

#import "CBPrimative.h"
#import "CBMask.h"
#import "CBImageTypes.h"

@class CBImage;

@interface CBLayer : CBPrimative

@property (assign, nonatomic) CBFilter filter;

@property (readonly, nonatomic) CBMask *mask;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;

@property (assign, nonatomic) UIColor *fillColor;
@property (assign, nonatomic) double alpha;
@property (assign, nonatomic) double beta;

@property (assign, nonatomic) double opacity;

@property (assign, nonatomic) float sheenLevel;
@property (assign, nonatomic) float detexturedAmount;
@property (readonly, nonatomic) BOOL isMaskUtilized;

@property (assign, nonatomic) Sheen sheen;
@property (assign, nonatomic) Transparency transparency;
@property (assign, nonatomic) Finish finish;

@property (readonly, nonatomic) NSMutableDictionary *userData;
@property (readonly, nonatomic) BOOL hasMadeChangesInMask;

- (id) initWithCBImage:(CBImage*)cbImage;
- (id) initWithCBImage:(CBImage*)cbImage image:(UIImage *)image constrainedToSize:(CGSize)maxSize;
- (id) initWithCBImage:(CBImage*)cbImage size:(CGSize)size color:(UIColor *)color;

- (void) setSize:(CGSize)size anchorPoint:(CBAnchorPoint)anchor;

- (void) pasteImage:(UIImage *)image atPoint:(CGPoint)point;

- (void) smoothByAmount:(double)amount;

- (UIColor *) getPixelAtPoint:(CGPoint)point;
- (UIColor *) getColorAtPoint:(CGPoint)point withRadius:(int)radius;

- (void) replaceAllColorsWithColor:(UIColor *)withColor;
- (void) replaceColor:(UIColor *)colorSrc withColor:(UIColor *)withColor;

- (void) fillWithColor:(UIColor *)color;
- (void) fillMaskWithColor:(UIColor *)color;
- (void) clearMask;

- (void) rotateByDegrees:(double)angle;
- (void) rotateByDegrees:(double)angle aroundPoint:(CGPoint)rotationPoint;

- (void) stretchToSize:(CGSize)newSize interpolation:(CBInterpolation)interpolation;

- (void) syncUserData;

@end
