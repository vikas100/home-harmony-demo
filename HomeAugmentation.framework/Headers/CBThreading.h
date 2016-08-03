//
//  CBThreading.h
//  Cambrian
//
//  Created by Joel Teply on 4/20/13.
//
//

#import <Foundation/Foundation.h>

@interface CBThreading : NSObject

+ (BOOL) isMultiCore;

+ (void) performBlock:(void (^)(void))block
              onQueue:(dispatch_queue_t)queue
       withIdentifier:(NSString *) identifier;

+ (void) performBlock:(void (^)(void))block
              onQueue:(dispatch_queue_t)queue
       withIdentifier:(NSString *) identifier
             interval:(NSTimeInterval)interval;

@end
