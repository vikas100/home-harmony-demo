//
//  CBVideoPainter.h
//  Cambrian
//
//  Created by Joel Teply on 1/17/12.
//  Copyright (c) 2012 Digital Rising LLC. All rights reserved.
//

#import "CBVideoDevice.h"
#import "CBImagePainter.h"

@interface CBVideoPainter : CBVideoDevice //<GPUImageTextureOutputDelegate>


@property (nonatomic, assign) BOOL showOutlines;
@property (nonatomic, assign) CGPoint paintPoint;
@property (nonatomic, strong) UIColor *paintColor;

- (BOOL)captureCurrentState:(CBImagePainter*)imagePainter completed:(void (^)(void))block;
- (BOOL)captureCurrentState:(void (^)(CBImagePainterImage *))block;

- (void) startRecording;
- (void) finishRecordingWithBlock:(void (^)(NSURL *file))block;
- (void) clearAll;

@end
