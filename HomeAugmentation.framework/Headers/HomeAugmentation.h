//
//  HomeAugmentation.h
//  HomeAugmentation
//
//  Created by Joel Teply on 8/2/16.
//  Copyright © 2016 Joel Teply. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for HomeAugmentation.
FOUNDATION_EXPORT double HomeAugmentationVersionNumber;

//! Project version string for HomeAugmentation.
FOUNDATION_EXPORT const unsigned char HomeAugmentationVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HomeAugmentation/PublicHeader.h>


#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>

//common
#import <HomeAugmentation/CBDefines.h>
#import <HomeAugmentation/CBImageTypes.h>
#import <HomeAugmentation/CBLicensing.h>
#import <HomeAugmentation/CBThreading.h>

//imaging
#import <HomeAugmentation/CBImage.h>
#import <HomeAugmentation/CBLayer.h>
#import <HomeAugmentation/CBMask.h>

//painting
#import <HomeAugmentation/CBImagePainter.h>
#import <HomeAugmentation/CBColoring.h>
#import <HomeAugmentation/CBColorFinder.h>

//UI
#import <HomeAugmentation/CBDrawerController.h>
#import <HomeAugmentation/CGRectAdditions.h>

//data
#import <HomeAugmentation/CBCoreData.h>

#if !TARGET_OS_TV

//video painter
#import <HomeAugmentation/CBVideoDevice.h>
#import <HomeAugmentation/CBVideoPainter.h>
#import <HomeAugmentation/CBCombinedPainter.h>

#endif
