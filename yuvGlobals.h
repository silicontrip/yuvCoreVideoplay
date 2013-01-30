//
//  yuvGlobals.h
//  yuvCoreVideoplay
//
//  Created by Mark Heath on 12/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface yuvGlobals : NSObject {

bool passThrough;
bool paused;
bool ignoreRate;
bool noSkip;
bool oneShot;
int verbose;
NSString *rate;
NSString *aspect;

}

+ (yuvGlobals *) getInstance;

- (bool) getPassThrough;
- (void) setPassThrough:(bool)b;
- (bool) getPaused;
- (void) setPaused:(bool)b;
- (bool) getIgnoreRate;
- (void) setIgnoreRate:(bool)b;
- (bool) getNoSkip;
- (void) setNoSkip:(bool)b;
- (int) getVerbose;
- (void) setVerbose:(int)i;
- (NSString *) getRate;
- (void) setRateWithString:(NSString *)s;
- (void) setRateWithChar:(char *)c;
- (NSString *) getAspect;
- (void) setAspectWithString:(NSString *)s;
- (void) setAspectWithChar:(char *)c;

@end
