//
//  HomeAugmentation.h
//  HomeAugmentation
//
//  Created by Joel Teply on 9/5/14.
//  Copyright (c) 2014 Joel Teply. All rights reserved.
//

#ifndef HOMEAUGMENTATION

#define HOMEAUGMENTATION 1

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

#endif