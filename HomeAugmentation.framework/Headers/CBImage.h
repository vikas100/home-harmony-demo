//
//  CBImage.h
//  HomeAugmentation
//
//  Created by Joel Teply on 6/9/14.
//  Copyright (c) 2014 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "CBImageTypes.h"

@class CBLayer;

@interface CBImage : NSObject

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGSize canvasSize;
@property (nonatomic, readonly) CBLayer *topLayer;
@property (nonatomic, readonly) CBLayer *bottomLayer;
@property (readonly, nonatomic) NSMutableArray *layers;
@property (readonly, nonatomic) NSMutableDictionary *userData;
@property (readonly) double apiVersion;

- (id) initWithUIImage:(UIImage *)image;

+ (UIImage *)getPreview:(NSString *)path;
+ (UIImage *)getThumbnail:(NSString *)path;
+ (NSDictionary *) getUserData:(NSString *)path;
+ (BOOL) setUserData:(NSDictionary *)userData path:(NSString *)path;
+ (BOOL) removeProjectDirectory:(NSString *)path;

+ (UIImage*)image:(UIImage *)sourceImage constrainedToSize:(CGSize)maxSize;
+ (UIImage*)image:(UIImage *)sourceImage rotatedByDegrees:(double)degrees;

+ (CBImage *) imageNamed:(NSString *)name;

- (CBLayer *) newLayer;
- (CBLayer *) appendNewLayer;
- (void) appendLayer:(CBLayer *)layer;
- (void) removeLayerAtIndex:(int)index;

- (CBLayer *) layerAtIndex:(int)index;
- (CBLayer *) topLayer;
- (void) flattenImage;

- (void) syncData;
- (void) invalidateLayers;

- (void) setCanvasSize:(CGSize)size anchorPoint:(CBAnchorPoint)anchor;

- (NSArray *) getMostCommonColors:(int)count type:(CBColorType)type;

#pragma mark Deprecated

- (void) saveToDirectory:(NSString *)url __attribute((deprecated(("Use CBImagePainter.saveProject instead."))));

- (id) initWithPath:(NSString *)path  __attribute((deprecated(("Use CBImagePainter.loadProject instead."))));

@property (readonly, nonatomic) UIImage *thumbnail __attribute((deprecated(("Use [CBImagePainter thumbnail] and [CBImagePainter thumbnailForProjectID:] instead."))));

@end
