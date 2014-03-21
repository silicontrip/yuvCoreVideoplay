//
//  y4m.h
//  yuvCoreVideoplay
//
//  Created by Mark Heath on 14/11/11.
//  Copyright 2011 Telstra. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSString.h>
#import <QuickTime/ImageCompression.h>

#import <CoreVideo/CVPixelBuffer.h>
#import <QTKit/QTKit.h>

#include <yuv4mpeg.h>
#include <mpegconsts.h>

#define k422YpCbCr8PixelFormat '2vuy'

@interface y4m : NSObject {
	
	y4m_stream_info_t	in_streaminfo;
	y4m_stream_info_t	out_streaminfo;
	
	int frameCounter;
	
	y4m_ratio_t			frame_rate;
	y4m_ratio_t			aspect_ratio;
	y4m_ratio_t			chroma_subsample;
	y4m_frame_info_t		in_frame ;
	int interlace;
	
	uint8_t					*yuv_data[3];
	
	int						fdIn;
	int						fdOut;
	
	int width;
	int height;
}

- (bool)initWithFdin:(int)fin fdout:(int)fout extensions:(int)extensions;
- (bool)initOut;
- (int) getScaledWidth;
- (int) getScaledHeight;
- (int) getWidth;
- (int) getHeight;
- (int) getFrameRateN;
- (int) getFrameRateD;
- (y4m_ratio_t) getFrameRate;
- (NSString *) getFrameRateAsString;
- (void) setFrameRateNum:(int)n den:(int)d;
- (int) getDisplayAspectN;
- (int) getDisplayAspectD;
- (y4m_ratio_t) getSampleAspect;
- (NSString *) getSampleAspectAsString;
- (int) getSampleAspectN;
- (int) getSampleAspectD;
- (bool) getSampleAspectWide;
- (void) setSampleAspectNum:(int)n den:(int)d;
- (y4m_ratio_t) getChromaSubsample;
- (int) getFrameCounter;
- (double) getTime;
- (int) getInterlace;
- (int) readFrame;
- (void) writeFrame;
- (uint8_t **) getYuvData;
- (void) copyToCVPixelBuffer:(CVPixelBufferRef)cf;
																		
@end
