//
//  CBCombinedPainter.h
//  HomeAugmentation
//
//  Created by Joel Teply on 11/17/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBImagePainter.h"

@class CBVideoPainter;

@interface CBCombinedPainter : CBImagePainter

@property (readonly, nonatomic) BOOL isShowingAugmentedReality;

- (void) startAugmentedReality;
- (void) stopAugmentedReality;
- (void) captureToImagePainter:(void (^)(void))block;

- (void) showImagePainter;
- (void) showAugmentedReality;

@end
