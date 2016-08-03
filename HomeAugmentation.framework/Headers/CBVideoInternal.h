//
//  CBVideoInternal.h
//  Cambrian
//
//  Created by Joel Teply on 1/16/12.
//  Copyright (c) 2012 Digital Rising LLC. All rights reserved.
//

#import "CBVideoTypes.h"
#import "CBVideoDevice.h"

@interface CBVideoDevice (CBVideoInternal)

@property (nonatomic, strong) CBVideoCamera *videoCamera;

@property (readonly, nonatomic) CGSize workingImageSize;

@property (assign, nonatomic) __block BOOL isBusy;

@property (readonly, nonatomic) cv::Scalar stdHSV;
@property (readonly, nonatomic) cv::Scalar avgHSV;

@property (nonatomic, readonly) NSTimeInterval initializationTime;
@property (nonatomic, readonly) NSTimeInterval startTime;
@property (nonatomic, readonly) NSTimeInterval lastFrameTime;
 
- (void) initializeFilters;
- (void) frameProcessed;
- (void) steadyChanged;

@end
