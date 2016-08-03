//
//  CBVideoCamera.h
//  Cambrian
//
//  Created by Joel Teply on 10/19/12.
//
//

#import "GPUImage.h"

@interface CBVideoCamera : GPUImageStillCamera

@property (readonly, nonatomic) float brightness;
@property (readonly, nonatomic) int isoRating;
@property (readonly, nonatomic) CMTime currentTime;

- (void)captureStillImageWithCompletionHandler:(void (^)(UIImage *image, NSError *error))block;

@end
