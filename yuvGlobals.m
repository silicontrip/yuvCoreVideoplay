//
//  yuvGlobals.m
//  yuvCoreVideoplay
//
//  Created by Mark Heath on 12/06/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "yuvGlobals.h"


@implementation yuvGlobals

+ (yuvGlobals *)getInstance {

  static yuvGlobals *instance;

	@synchronized(self)
	{
		if (instance == nil) {
			instance = [[yuvGlobals alloc] init];
		}
	}
	return instance;
	
}

- (bool)getPassThrough
{
	return passThrough;
}

- (void)setPassThrough:(bool)b
{
	passThrough = b;
}

- (bool)getPaused
{
	return paused;
}

- (void)setPaused:(bool)b
{
	paused = b;
}

- (bool)getIgnoreRate
{
	return ignoreRate;
}

- (void)setIgnoreRate:(bool)b
{
	ignoreRate = b;
}
- (bool)getNoSkip
{
	return noSkip;
}

- (void)setNoSkip:(bool)b
{
	noSkip = b;
}
- (int)getVerbose
{
	return verbose;
}

- (void)setVerbose:(int)i
{
	verbose = i;
}

- (NSString *) getRate {
	return rate;
}

- (void) setRateWithString:(NSString *)s
{
	rate = [NSString stringWithString:s];
}
- (void) setRateWithChar:(char *)c
{
	rate = [NSString stringWithUTF8String:c];
}

- (NSString *) getAspect {
	return aspect;
}

- (void) setAspectWithString:(NSString *)s
{
	aspect = [NSString stringWithString:s];
}
- (void) setAspectWithChar:(char *)c
{
	aspect = [NSString stringWithUTF8String:c];
}


@end
