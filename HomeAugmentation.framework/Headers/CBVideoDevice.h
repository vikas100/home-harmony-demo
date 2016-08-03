//
//  CBVideoDevice.h
//  Cambrian
//
//  Created by Joel Teply on 1/15/12.
//  Copyright (c) 2012 Digital Rising LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>
#import "CBVideoTypes.h"

@protocol CBVideoDeviceDelegate <NSObject>

@optional

- (void) imageUpdated;
- (void) lightingChanged;

@end

@interface CBVideoDevice : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, assign) id<CBVideoDeviceDelegate> delegate;

//Status and calibration
@property (weak, nonatomic) UIView *output;
@property (readonly, nonatomic) CGSize outputImageSize;
@property (readonly, nonatomic) CGSize presetImageSize;
@property (readonly, nonatomic) float aspectRatio;
@property (nonatomic, readonly) Lighting lighting;
@property (nonatomic, readonly) float brightness;
@property (nonatomic, readonly) double normalIntensity;
@property (nonatomic, readonly) BOOL isIndoor;
@property (nonatomic, readonly) int isoRating;

@property (nonatomic, readonly) int fps;
@property (nonatomic, assign) BOOL throttled;
@property (nonatomic, readonly) BOOL isSteady;
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, copy) void(^steadyChangedBlock)(void);

- (id) initWithCameraAtPosition:(AVCaptureDevicePosition)position 
                      delegate:(id<CBVideoDeviceDelegate>) delegate;

- (BOOL) startRunning;
- (BOOL) stopRunning;

- (void) playShutterSound;
- (void) flashScreen;

@end
