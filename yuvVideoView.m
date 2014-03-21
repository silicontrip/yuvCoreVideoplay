//
//  yuvVideoView.m
//  yuvCoreVideoplay
//
//  Created by Mark Heath on 15/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

/*
 
 gcc -L/sw/lib -lmjpegutils -I/sw/include/mjpegtools -framework OpenGL -framework QuartzCore -framework Cocoa -framework CoreFoundation main.m yuvVideoView.m -o yuvVideo
 
 MyDisplayLinkCallback
 {
 displayFrame
 {
 getFrameForTime
 {
 yuvCVcopy
 }
 drawRect
 {
 updateCurrentFrame
 {
 getFrameForTime
 }
 renderCurrentFrame
 {
 *
 }
 }
 }
 }
 
 */


#import "yuvVideoView.h"
#import <OpenGL/gl.h>

@implementation yuvVideoView

// sets up the memory pointer globals

#pragma mark #### Responders ####
- (void)play:sender 
{
	if (!CVDisplayLinkIsRunning(displayLink)) {
		//	NSLog(@"play");
		CVDisplayLinkStart(displayLink);
		refTime = -1;
		[globalsInstance setPaused:NO];
	}
}

- (void)pause:sender
{
	if (CVDisplayLinkIsRunning(displayLink)) {
		//	NSLog(@"pause");
		[globalsInstance setPaused:YES];
		CVDisplayLinkStop(displayLink);
	}
	
}

- (void)frAdvance:sender
{
	if (!CVDisplayLinkIsRunning(displayLink)) {
		//	NSLog(@"advance");
		[globalsInstance setPaused:YES];
		CVDisplayLinkStart(displayLink);
		refTime = -1;
	}
	
}

- (void)frSave:sender
{
	
	CIImage     *inputImage;
	//NSRect      frame = [self frame];
	inputImage = nil;
	char filename[100];
	
	//	NSLog(@"renderCurrentFrame: inputImage");
	
	// incorrect pixel data at this point causes drawImage to crash
	inputImage = [CIImage imageWithCVImageBuffer:currentFrame]; // 1
	
	if (inputImage == nil ) {
		NSLog(@"renderCurrentFrame: inputImage is nil");
	} else {
		
		// convert CIImage to NSImage
		
		NSCIImageRep* rep = [NSCIImageRep imageRepWithCIImage:inputImage];
		NSImage* image = [[[NSImage alloc] 
						   initWithSize:NSMakeSize ([yuvvideo getWidth], [yuvvideo getHeight])] autorelease];
		[image addRepresentation:rep];
		
		// synthesize name
		
		sprintf (filename,"frame%04d.tif",[yuvvideo getFrameCounter]);
		
		// write out frame
		
		[[image TIFFRepresentation] writeToFile:[NSString stringWithUTF8String:filename] atomically:YES];
		
	}
	
	
}


- (void)actionNoSkip:sender
{
	[NoSkip setState:![NoSkip state]];
	[globalsInstance setNoSkip:![NoSkip state]];
}

- (void)actionIgnoreRate:sender
{
	[IgnoreRate setState:![IgnoreRate state]];
	[globalsInstance setIgnoreRate:![IgnoreRate state]];	
}

- (void)actionSetRate:sender
{	
	[self setRate:[Ratetext stringValue]];
}

- (void)actionSetAspect:sender
{	
	
	[self setAspect:[Aspecttext stringValue]];
	needsReshape=YES;
	[self windowAspect];
	
}

- (void)actionSetZoom:sender
{	
	needsReshape=YES;
	//	NSLog (@"actionSetZoom: %f" , [Zoomtext floatValue]);
	if ([Zoomtext floatValue] > 0) {
		[self windowAspectWithZoom:[Zoomtext floatValue]];
	}
}


- (void)resize:sender
{
	[self reshape];
}

- (void)reshape
{
	needsReshape = YES;
}

#pragma mark #### Setters ####

- (void) setRate:(NSString *)rateString {
	float framed=0,framen=0;
	NSArray *rate = nil;
	
	rate = [rateString componentsSeparatedByString:@":"];
	
	if (rate == nil) {
		NSLog(@"actionSetRate: NSArray rate is nil");
	} else if ([rate count] == 2) {
		
		NSString *tvalue;
		
		tvalue = [rate objectAtIndex:0];
		framen = [tvalue floatValue];
		
		tvalue = [rate objectAtIndex:1];
		framed = [tvalue floatValue];
	} 
	
	if ((framed ==0) || (framen == 0)) {
		NSLog(@"Invalid frame rate");
		[Ratetext setStringValue:[yuvvideo getFrameRateAsString]];
	} else {
		//	NSLog(@"setting frame rate");
		
		[globalsInstance setIgnoreRate:NO];	
		[IgnoreRate setState:NSOffState];
		
		refTime = -1;
		
		[yuvvideo setFrameRateNum:framen den:framed];
	}
}

- (void) setAspect:(NSString *)aspectString 
{
	float aspectd=0,aspectn=0;
	NSArray *asarray = nil;
	
	
	asarray = [aspectString componentsSeparatedByString:@":"];
	
	if (asarray == nil) {
		NSLog(@"actionSetRate: NSArray asarray is nil");
	} else if ([asarray count] == 2) {
		
		NSString *tvalue;
		
		tvalue = [asarray objectAtIndex:0];
		aspectn = [tvalue floatValue];
		
		tvalue = [asarray objectAtIndex:1];
		aspectd = [tvalue floatValue];
	} 
	
	if ((aspectd ==0) || (aspectn == 0)) {
	//	char text[100];
		NSLog(@"Invalid aspect ratio");
	//	sprintf (text,"%d:%d",aspect_ratio.n , aspect_ratio.d);
		[Aspecttext setStringValue:[yuvvideo getSampleAspectAsString]];
	} else {
		//	NSLog(@"setting frame rate");
		
		[yuvvideo setSampleAspectNum:aspectn den:aspectd];
	}
}


- (void)renderCurrentFrame
{
	
	//	NSLog(@"renderCurrentFrame");
	
	// currentFrame should always be defined
    if(currentFrame != nil)
    {
        CGRect      imageRect;
        CIImage     *inputImage;
		inputImage = nil;
		//	NSLog(@"renderCurrentFrame: inputImage");
		
		// incorrect pixel data at this point causes drawImage to crash
		inputImage = [CIImage imageWithCVImageBuffer:currentFrame]; // 1
		
		if (inputImage == nil ) {
			NSLog(@"renderCurrentFrame: inputImage is nil");
		} else {
		
		//		NSLog(@"renderCurrentFrame: imageRect");
		
		// err?  how do I scale the image to fill the window?
			imageRect = [inputImage extent]; // 2
			
		
			
		// NSLog(@"renderCurrentFrame: %f,%f -> %f,%f",imageRect.size.width,imageRect.size.height,frame.size.width,frame.size.height);
		
		//		NSLog(@"renderCurrentFrame: drawImage");
		
		//	[effectFilter setValue:inputImage forKey:@"inputImage"];
		
		
		// this will bus error if the inputImage is supplied corrupt image data
		// even though the inputImage is created, it can still be corrupt
		
		@synchronized(self)
		{
			
			// this crashes/hangs/screws up quite a lot. I wish I knew why
			// it appears to be a lack of synchronisation.
			
			//	NSLog(@"renderCurrentFrame: frame.size %f %f",frame.size.width,frame.size.height);
			//	NSLog(@"renderCurrentFrame: imageRect.size %f %f",imageRect.size.width,imageRect.size.height);
			
			
			[ciContext 
			 //	 drawImage:[effectFilter valueForKey:@"outputImage"] 
			 drawImage:inputImage
			 atPoint:CGPointMake(0,0)
			 fromRect:imageRect];
		}
		
		//		NSLog(@"renderCurrentFrame: drawImage done");
		}
    } else {
		NSLog(@"renderCurrentFrame: currentFrame is nil");
	}
	//	NSLog(@"renderCurrentFrame: exit");
	
}


- (BOOL)getFrameForTime:(const CVTimeStamp*)syncTimeStamp
{	
	
	// NSLog(@"getFrameForTime");
	
	int	read_error_code;
	CVReturn				cvError;
	double					yuvTS, syncTS;
	//float currentFPS;
	
	cvError = kCVReturnSuccess;
	// read_error_code = Y4M_OK;
	
	if (refTime == -1 ) {
        if (syncTimeStamp)
            refTime = syncTimeStamp->videoTime  -  syncTimeStamp->videoTimeScale * [yuvvideo getTime];
        else
            refTime = 0;
		// put some playing frame rate statistics here.
		//	statFrameCount = frameCount;
		//	statRefTime = syncTimeStamp->videoTime;
	}
	
	//	NSLog(@"getFrameForTime: Time Stamp : %d", frameCounter);
	
	yuvTS = [yuvvideo getTime];
    if (syncTimeStamp)
        syncTS = 1.0 * (syncTimeStamp->videoTime - refTime) / syncTimeStamp->videoTimeScale;
	else
        syncTS = 0;
	
	if ( ![globalsInstance getIgnoreRate] && yuvTS > syncTS)
		return NO;
	
	// read frames until we have the one with the correct timestamp.
	// yuv timestamp is synthesized, there are no timestamp markers in the file.
	do {
	 	read_error_code = [yuvvideo readFrame];
		if ([globalsInstance getPassThrough] && read_error_code == Y4M_OK) {
			// write the frame here
			[yuvvideo writeFrame];			
		}
		
	//	frameCounter++;
		yuvTS = [yuvvideo getTime];
        if (syncTimeStamp)
            syncTS = 1.0 * (syncTimeStamp->videoTime - refTime) / syncTimeStamp->videoTimeScale;
        else
            syncTS = 0;

		
	} while ( yuvTS < syncTS && ![globalsInstance getNoSkip]);
	
	// this might slow down the frame renderer
	[Frametext setIntValue:[yuvvideo getFrameCounter]];
	//	[Frametext setFloatValue:currentFPS];
	
	
	//		if ([globalsInstance getPaused]) 
	//			NSLog(@"getFrameForTime: frame read");
	
	// do want to optimize this call
	[yuvvideo copyToCVPixelBuffer:currentFrame];
	
	
	if ((read_error_code == Y4M_OK) && (cvError == kCVReturnSuccess)) {
		//	NSLog(@"return YES getFrameForTime");
		return YES;
	} 
	
	if (read_error_code != Y4M_OK) {
		if (read_error_code == Y4M_ERR_EOF) {
			NSLog(@"getFrameForTime: Y4m End of File");
		} else {
			NSLog(@"getFrameForTime: Y4m error: %d",read_error_code);
		}
		if (CVDisplayLinkIsRunning(displayLink)) {
			//	NSLog(@"pause");
			[globalsInstance setPaused:YES];
			CVDisplayLinkStop(displayLink);
		}
		//	[self dealloc];
	}
	
	if (cvError != kCVReturnSuccess) 
		NSLog(@"getFrameForTime: CV error: %d",cvError);
	
	return NO;
	
}


- (CVReturn)displayFrame:(const CVTimeStamp *)timeStamp
{
	
	// NSLog(@"displayFrame");
	
	CVReturn rv = kCVReturnError;
	NSAutoreleasePool *pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	if([self getFrameForTime:timeStamp])
	{
		[self drawRect:NSZeroRect];
		rv = kCVReturnSuccess;
	}
	else
	{
		rv = kCVReturnError;
	}
	[pool release];
	return rv;
}


CVReturn MyDisplayLinkCallback (
								CVDisplayLinkRef displayLink,
								const CVTimeStamp *inNow,
								const CVTimeStamp *inOutputTime,
								CVOptionFlags flagsIn,
								CVOptionFlags *flagsOut,
								void *displayLinkContext)
{
	
	CVReturn error =
	[(yuvVideoView*)displayLinkContext displayFrame:inOutputTime];
	return error;
}

- (void)windowChangedScreen:(NSNotification*)inNotification
{
	
	// NSLog(@"windowChangedScreen");
	
	NSWindow *window = [inNotification object]; 
	CGDirectDisplayID displayID = (CGDirectDisplayID)[[[[window screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
	
	if( (displayID != 0) && 
	   (viewDisplayID != displayID))
	{
		CVDisplayLinkSetCurrentCGDisplay(displayLink, displayID);
		viewDisplayID = displayID;
	}
}

// this resizes the display so run only once
- (void)initPanelHeight 
{
	NSRect frame;
	float y1, y2;
	
	// must take the control panel into consideration...
	// don't know how but.
	frame = [self frame];
	y1 = frame.size.height;
	[[self window] setContentSize: frame.size];
	frame = [self frame];
	y2 = frame.size.height;
	
	panelHeight = y1 - y2;
}

- (float) getPanelHeight 
{
	return panelHeight;
}

- (void)windowAspect 
{
	
	NSRect frame;
	NSSize aspect;
	
	if ([yuvvideo getSampleAspectN] > [yuvvideo getSampleAspectD]) {
		frame = NSMakeRect(0,0, [yuvvideo getScaledWidth] , [yuvvideo getHeight] + [self getPanelHeight]);
	} else {
		frame = NSMakeRect(0,0, [yuvvideo getWidth], [yuvvideo getScaledHeight] + [self getPanelHeight]);
	}
	
	aspect = NSMakeSize([yuvvideo getDisplayAspectN], [yuvvideo getDisplayAspectD]+[self getPanelHeight]);
	[[self window] setAspectRatio:aspect];
	
	/* set the window size */	
	[[self window] setContentSize: frame.size];
	
	needsReshape=YES;
	
}

- (void)windowAspectWithZoom:(float)zoom
{
	
	NSRect frame;
	NSSize aspect;
	
	if ([yuvvideo getSampleAspectWide]) {
		frame = NSMakeRect(0,0, zoom * [yuvvideo getScaledWidth] / 100, 
						   zoom * [yuvvideo getHeight] / 100 + [self getPanelHeight]);
	} else {
		frame = NSMakeRect(0,0, zoom * [yuvvideo getWidth] / 100, 
						   zoom * [yuvvideo getScaledHeight] / 100 + [self getPanelHeight]);
	}
	
//	NSLog(@"windowAspectWithZoom: %f, %d %d %d %d",zoom,y4m_si_get_width(&in_streaminfo),y4m_si_get_height(&in_streaminfo) ,aspect_ratio.d , aspect_ratio.n);
	
	aspect = NSMakeSize([yuvvideo getDisplayAspectN], [yuvvideo getDisplayAspectD]+[self getPanelHeight]);
	[[self window] setAspectRatio:aspect];
	
//	NSLog(@"windowAspectWithZoom %f %f",frame.size.width, frame.size.height);
	
	/* set the window size */	
	// probably want to protect this from errant values...
	[[self window] setContentSize: frame.size];
	
	needsReshape=YES;
	
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication { return YES; }

- (void)awakeFromNib
{
	CVReturn            error = kCVReturnSuccess;
	CGDirectDisplayID   displayID = CGMainDisplayID();
	char text[100];
	
	// NSLog(@"awakeFromNib entry");
	
	globalsInstance = [yuvGlobals getInstance];
	
	error = CVDisplayLinkCreateWithCGDisplay(displayID, &displayLink);
	if(error)
	{
		NSLog(@"DisplayLink created with error:%d", error);
		displayLink = NULL;
		return;
	}
	error = CVDisplayLinkSetOutputCallback(displayLink, MyDisplayLinkCallback, self);
	
	if(error)
	{
		NSLog(@"Setting Output Callback error:%d", error);
		displayLink = NULL;
		return;
	}
	
	
	error = CVDisplayLinkStart(displayLink);
	
	if(error)
	{
		NSLog(@"Starting display link thread error: %d", error);
		return;
	}
	
	/* set the GUI checkboxes */
	[IgnoreRate setState:NSOffState];
	[NoSkip setState:NSOffState];
	
	if ([globalsInstance getIgnoreRate]) 
		[IgnoreRate setState:NSOnState];
	
	if ([globalsInstance getNoSkip])  
		[NoSkip setState:NSOnState];
	
	sprintf (text,"%d:%d",[yuvvideo getFrameRateN] , [yuvvideo getFrameRateD]);
	[Ratetext setStringValue:[NSString stringWithUTF8String:text]];
	
	sprintf (text,"%d:%d",[yuvvideo getSampleAspectN] , [yuvvideo getSampleAspectD]);
	[Aspecttext setStringValue:[NSString stringWithUTF8String:text]];
	
	[Zoomtext setStringValue:@"100"];

	[NSApp setDelegate:self];
	
	[self initPanelHeight];
	[self windowAspect];
	
	//NSLog(@"awakeFromNib exit");

}

- (void)updateCurrentFrame
{	
	NSLog(@"updateCurrentFrame: this should not be called");
	[self getFrameForTime:nil];    
}

- (void)drawRect:(NSRect)theRect
{
	
	// NSLog(@"drawRect");
	
	[lock lock];    // 1
	
	[[self openGLContext] makeCurrentContext]; // 2
	
	if(needsReshape) // 3
	{
		
		NSRect      frame; // = [self frame];
		NSRect      bounds; // = [self bounds];
		
		//	NSLog(@"drawRect: NSView frame %f %f",frame.size.width, frame.size.height);
		
		frame = NSMakeRect(0, 0, [yuvvideo getWidth], [yuvvideo getHeight]);
		bounds = [self bounds];
		
		//	NSLog(@"drawRect: needs Reshape %fx%f",bounds.size.width ,bounds.size.height);
		GLfloat     minX, minY, maxX, maxY;
		
		minX = NSMinX(frame);
		minY = NSMinY(frame);
		maxX = NSMaxX(frame);
		maxY = NSMaxY(frame);
		
	//	NSLog(@"drawRect: self update");
		[self update];
		
		//NSRect visible = [self visibleRect];

	//	NSLog(@"drawRect: self visibleRect %g %g %g %g", visible.origin.x,visible.origin.y,visible.size.width, visible.size.height );

		
		if(NSIsEmptyRect([self visibleRect]) ) // 4
		{
			//NSLog(@"drawRect: glViewport 0 0 1 1");

			glViewport(0, 0, 1, 1);
		} else {
		//	NSLog(@"drawRect: glViewport");

			glViewport(0, 0,  bounds.size.width ,bounds.size.height);
		}
		//NSLog(@"drawRect: glMatrixMode");

		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(minX, maxX, minY, maxY, -1.0, 1.0);
		
		needsReshape = NO;
	}
	
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	//NSLog(@"drawRect: self updateCurrentFrame");

	// is currentFrame ever not set
	if(!currentFrame)// 5
		[self updateCurrentFrame];
	// NSLog(@"drawRect: self rendercurrentframe");

	
	[self renderCurrentFrame];      // 6
	glFlush();// 7
	[lock unlock];// 8
	
	if ([[yuvGlobals getInstance] getPaused]) {
		if (CVDisplayLinkIsRunning(displayLink)) {
			CVDisplayLinkStop(displayLink);
		}
	}
	
	//NSLog(@"drawRect exit");

	
}

-(void)dealloc
{
	
	CVReturn error;
	
//	 NSLog(@"dealloc"); 
	
	error = CVDisplayLinkStop(displayLink);
	if(error)
	{
		NSLog(@"Stopping display link thread error: %d", error);
	}
	
	CVDisplayLinkRelease(displayLink);
	
	CVPixelBufferUnlockBaseAddress(currentFrame,0);
	CVPixelBufferRelease(currentFrame);
	
	[ciContext release];
	[yuvvideo dealloc];
	/*
	free(yuv_data[0]);
	free(yuv_data[1]);
	free(yuv_data[2]);
	
	y4m_fini_frame_info( &in_frame );
	y4m_fini_stream_info (&in_streaminfo);
	if ([globalsInstance getPassThrough]) {
		y4m_fini_stream_info (&out_streaminfo);
	}
	*/
	[[self window] close];
	
	[super dealloc];
	
	exit(0);
}


- (id)initWithFrame:(NSRect)theRect // 1
{
	
	CVReturn	cvError;
	OSType pixelFormat;

	// NSRect frame;
	
//	 NSLog(@"initWithFrame");
	self = [super initWithFrame: theRect];
	
	currentFrame = nil;
	
	/*****
	 ** Set up YUV Library routines
	 *****/
	
	yuvvideo = [y4m alloc];
	
	if ( [yuvvideo initWithFdin:0 fdout:1 extensions:1] != Y4M_OK) {
		NSLog(@"Could'nt create yuvvideo" );
		exit(-1);
	} 
	
	if ([[yuvGlobals getInstance] getPassThrough]) {		
		[yuvvideo initOut];
	}
	
	
//	NSLog(@"YUVVIDEO: width: %d height: %d",[yuvvideo getWidth],[yuvvideo getHeight]);
	
	// allocate memory for the CV Pixel Buffer 
	
	pixelFormat = k422YpCbCr8PixelFormat;
	
	cvError = CVPixelBufferCreate(NULL,
								  [yuvvideo getWidth],
								  [yuvvideo getHeight],
								  pixelFormat,
								  NULL,
								  &currentFrame);
	
	if (cvError != kCVReturnSuccess) {
		NSLog(@"YCbCrPlanaralloc: Planar pixel buffer CV error: %d",cvError);
		exit(-1);

	} else {
		CVPixelBufferLockBaseAddress(currentFrame,0);
		
		[yuvvideo copyToCVPixelBuffer:currentFrame];
		
	}
	
	// frameCounter = 0;
	refTime = -1;
	needsReshape = YES;
	
	/* Core Image effects */
	
	/*
	 effectFilter = [[CIFilter filterWithName:@"CIDotScreen"] retain];
	 [effectFilter setDefaults];
	 */
	
	ciContext = nil;
	/* Create CGColorSpaceRef */
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    /* Create CIContext */
    /* 10.6 - code */
    ciContext = [[CIContext contextWithCGLContext:(CGLContextObj)[[self openGLContext] CGLContextObj]
									  pixelFormat:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]
                                       colorSpace:colorSpace
										  options:nil] retain];
	
        /* 10.4 and 10.5 code
    ciContext = [[CIContext contextWithCGLContext:(CGLContextObj)[[self openGLContext] CGLContextObj]
									  pixelFormat:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]
										  options:[NSDictionary dictionaryWithObjectsAndKeys:
												   (id)colorSpace,kCIContextOutputColorSpace,
												   (id)colorSpace,kCIContextWorkingColorSpace,nil]] retain];
	*/
	if (ciContext == nil) {
		NSLog(@"Error creating CIContext!");
	}
	
	CGColorSpaceRelease(colorSpace);
	
	//NSLog(@"initWithFrame exit");

	
	return self;
}

@end
