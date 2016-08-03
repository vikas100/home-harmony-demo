//
//  CBImageInternal.h
//  Cambrian
//
//  Created by Joel Teply on 11/21/11.
//  Copyright (c) 2011 Digital Rising LLC. All rights reserved.
//

#import "CBMask.h"
#import "CBLayer.h"
#import "CBImage.h"
#import "CBLicensing.h"
#import "CBImagePainter.h"
#import "CBDefines.h"

#ifdef __cplusplus

#include <cbimage/CB_Image.h>
#include <cbimage/CB_Layer.h>
#include <cbimage/CB_Mask.h>
#include <cbpainter/CB_ImagePainter.hpp>

#define IMAGE_LOGGING_INIT() \
if (!Diagnostics::isInitialized) { \
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);\
    NSString *imageLogDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image_logging"];\
    [[NSFileManager defaultManager] createDirectoryAtPath:imageLogDir withIntermediateDirectories:YES attributes:nil error:nil];\
    Diagnostics::Initialize([imageLogDir UTF8String]);\
}\

@interface CBMask (CBPrimative)

@end


@interface CBMask (CBImageInternal)

@property (readonly, atomic) cbi::CB_Mask *cb_mask;

@end

@interface CBLayer (CBImageInternal) 

@property (assign, atomic) cbi::CB_Layer *cb_layer;

- (id) initWithCBImage:(CBImage*)cbImage cvMat:(cv::Mat)cvMat constrainedToSize:(CGSize)maxSize;
- (id) initWithCB_Layer:(cbi::CB_Layer *)layer;

@end

@interface CBImage (CBImageInternal)

@property (assign, atomic) cbi::CB_Image *cb_image;

- (id) initWithCVMat:(cv::Mat)cvMat backgroundColor:(UIColor *)color constrainedToSize:(CGSize)maxSize;
- (id) initWithCB_Image:(cbi::CB_Image *)cb_image;
- (cbi::CB_Image *)newImage;

@end

@interface CBLicensing (CBImageInternal)

+ (void) errorMessageUser;

@end


@interface CBImagePainterImage (CBImageInternal)

@property (assign, atomic) cbp::CB_ImagePainterImage *cb_image;

- (id) initWithCB_ImagePainterImage:(cbp::CB_ImagePainterImage *)cb_image;

@end


#endif