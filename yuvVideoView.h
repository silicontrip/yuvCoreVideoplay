//
//  yuvVideoView.h
//  yuvCoreVideoplay
//
//  Created by Mark Heath on 15/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include <yuv4mpeg.h>
#include <mpegconsts.h>

#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <QTKit/QTKit.h>
#import <CoreFoundation/CFString.h>
#import <QuickTime/ImageCompression.h>
#import "yuvGlobals.h"
#import "y4m.h"

#define k422YpCbCr8PixelFormat '2vuy'


@interface yuvVideoView : NSOpenGLView {
	
	NSRecursiveLock         *lock;
    CVDisplayLinkRef        displayLink;
    CGDirectDisplayID		viewDisplayID;

    CVPixelBufferRef        currentFrame;
    CIFilter                *effectFilter;
    CIContext               *ciContext;
	
	void *planeByteAddress[3];
	
	size_t planeWidth[3], planeHeight[3];
	int64_t refTime;
	
    NSDictionary            *fontAttributes;
	
	//YUV stuff
	/*
	y4m_stream_info_t	in_streaminfo;
	y4m_stream_info_t	out_streaminfo;

	y4m_ratio_t			frame_rate;
	y4m_ratio_t			aspect_ratio;
	y4m_frame_info_t		in_frame ;

	uint8_t					*yuv_data[3];
	
	int						fdIn;
	int						fdOut;
	
	unsigned int frameCounter;
*/	
	y4m *yuvvideo;
	
	yuvGlobals *globalsInstance;
	
    int                     frameCount;
	int                     statFrameCount;
	int64_t statRefTime;

// Interface stuff

    int                     frameRate;
    CVTimeStamp             frameCountTimeStamp;
    double                  timebaseRatio;
    BOOL                    needsReshape;
    id                      delegate;
	float		panelHeight;
	
	IBOutlet id Frametext;
	IBOutlet id Ratetext;
	IBOutlet id Aspecttext;
	IBOutlet id Zoomtext;
	IBOutlet id NoSkip;
	IBOutlet id IgnoreRate;
}

// to make this more OO need to break this into it's objects
// interface, yuvvideo, corevideo

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)frAdvance:(id)sender;
- (IBAction)frSave:(id)sender;
- (IBAction)actionNoSkip:(id)sender;
- (IBAction)actionIgnoreRate:(id)sender;
- (IBAction)actionSetRate:(id)sender;
- (IBAction)actionSetAspect:(id)sender;
- (IBAction)actionSetZoom:(id)sender;
- (IBAction)resize:(id)sender;

- (void)reshape;
- (void)setRate:(NSString *)rateString;
- (void)setAspect:(NSString *)aspectString; 
- (void)renderCurrentFrame;
- (BOOL)getFrameForTime:(const CVTimeStamp*)syncTimeStamp;
- (CVReturn)displayFrame:(const CVTimeStamp *)timeStamp;
- (void)windowChangedScreen:(NSNotification*)inNotification;
- (void)windowAspect;
- (void)windowAspectWithZoom:(float)zoom;
- (void)awakeFromNib;
- (void)updateCurrentFrame;
- (void)drawRect:(NSRect)theRect;
- (void)dealloc;
- (id)initWithFrame:(NSRect)theRect;

@end
