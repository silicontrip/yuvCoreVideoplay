//
//  y4m.m
//  yuvCoreVideoplay
//
//  Created by Mark Heath on 14/11/11.
//  Copyright 2011 Telstra. All rights reserved.
//

#import "y4m.h"


@implementation y4m

- (bool)initWithFdin:(int)fin fdout:(int)fout extensions:(int)extensions
{
	
	int read_error_code = Y4M_OK;
	int i;
	
	fdIn = fin;
	fdOut = fout;
	
	frameCounter = 0;
	
	y4m_init_stream_info (&in_streaminfo);
	y4m_accept_extensions(extensions); 
	read_error_code = y4m_read_stream_header (fdIn, &in_streaminfo);
	
	if ( read_error_code != Y4M_OK) {
		switch (read_error_code) {
			case Y4M_ERR_FEATURE:
				NSLog(@"Unsupported YUV4MPEG Features");
				break;
			default:
				NSLog(@"Could'nt read YUV4MPEG header! (%d)", read_error_code );
		}
		
		return read_error_code;
	} 
	
	frame_rate = y4m_si_get_framerate (&in_streaminfo);
	aspect_ratio = y4m_si_get_sampleaspect(&in_streaminfo);
	
	width = y4m_si_get_plane_width(&in_streaminfo,0);
	height = y4m_si_get_plane_height(&in_streaminfo,0);
	
	// NSLog (@"y4m: width: %d height: %d",width,height);
	
	interlace = y4m_si_get_interlace(&in_streaminfo);
	
	chroma_subsample.n = y4m_si_get_plane_width(&in_streaminfo,0) / y4m_si_get_plane_width(&in_streaminfo,1);
	chroma_subsample.d = y4m_si_get_plane_height(&in_streaminfo,0) / y4m_si_get_plane_height(&in_streaminfo,1);
	
	for (i=0; i < 3; i++) {
		yuv_data[i] = (uint8_t *) malloc (y4m_si_get_plane_length(&in_streaminfo,i));
	}
	
	memset (yuv_data[0],16,y4m_si_get_plane_length(&in_streaminfo,0));
	memset (yuv_data[1],128,y4m_si_get_plane_length(&in_streaminfo,1));
	memset (yuv_data[2],128,y4m_si_get_plane_length(&in_streaminfo,2));
	
	
	return Y4M_OK;
	
}		

- (bool)initOut
{
	
	y4m_init_stream_info (&out_streaminfo);
	y4m_copy_stream_info( &out_streaminfo, &in_streaminfo );
	y4m_write_stream_header(fdOut,&out_streaminfo);
	
	return false;
}

- (int) getScaledWidth {
    if (aspect_ratio.d ==0 ||aspect_ratio.n == 0)
        return width;

	return width * aspect_ratio.n / aspect_ratio.d;
}

- (int) getScaledHeight {
    if (aspect_ratio.d ==0 ||aspect_ratio.n == 0)
        return height;
    
	return height * aspect_ratio.d / aspect_ratio.n;
}

- (int) getWidth {
	return width;
}

- (int) getHeight {
	return height;
}

- (int) getFrameRateN {
	return frame_rate.n;
}

- (int) getFrameRateD {
	return frame_rate.d;
}

- (y4m_ratio_t) getFrameRate {
	return frame_rate;
}

- (NSString *) getFrameRateAsString {
	return [NSString stringWithFormat:@"%d:%d",frame_rate.n , frame_rate.d];
}

-(void) setFrameRateNum:(int)n den:(int)d {
	frame_rate.n = n;
	frame_rate.d = d;
}

- (int) getDisplayAspectN {
	return aspect_ratio.n * width;
}

- (int) getDisplayAspectD {
	return aspect_ratio.d * height;
}

- (y4m_ratio_t) getSampleAspect {
	return aspect_ratio;
}

- (NSString *) getSampleAspectAsString {
	return [NSString stringWithFormat:@"%d:%d",aspect_ratio.n , aspect_ratio.d];
}

- (bool) getSampleAspectWide {
	return aspect_ratio.n > aspect_ratio.d;
}

- (int) getSampleAspectN{
	return aspect_ratio.n;
}
- (int) getSampleAspectD{
	return aspect_ratio.d;
}


-(void) setSampleAspectNum:(int)n den:(int)d {
	aspect_ratio.n = n;
	aspect_ratio.d = d;
}

- (y4m_ratio_t) getChromaSubsample {
	return chroma_subsample;
}

- (int) getChromaSubsampleN {
	return chroma_subsample.n;
}
- (int) getChromaSubsampleD {
	return chroma_subsample.d;
}

- (int) getFrameCounter {
	return frameCounter;
}

- (double) getTime {
	return  1.0 * frameCounter /  ( frame_rate.n / frame_rate.d);
}

- (int) getInterlace {
	return interlace;
}

- (int) readFrame {
	
	int read_error_code;
	
	y4m_init_frame_info( &in_frame );
	read_error_code = y4m_read_frame(fdIn, &in_streaminfo,&in_frame,yuv_data );
	if (read_error_code == Y4M_OK) 
		frameCounter++;
	
	y4m_fini_frame_info( &in_frame );
	
	return read_error_code;
}

- (void) writeFrame {
	y4m_write_frame( fdOut, &out_streaminfo, &in_frame, yuv_data );
}

- (uint8_t **) getYuvData {
	return yuv_data;
}

- (void)copyToCVPixelBuffer:(CVPixelBufferRef)cf
{
	
	size_t y,x,w,h,b;
	uint8_t cy0,cy1,cu,cv;
	OSType pixelFormat;
	uint8_t *buffer;
	
	//	NSLog(@"yuvCVcopy");	
	
	pixelFormat=CVPixelBufferGetPixelFormatType(cf);
	switch (pixelFormat) {
			
		case '444v':   // this appears to be RGB
			
			h = CVPixelBufferGetHeight(cf);
			w = CVPixelBufferGetWidth(cf);
			b = CVPixelBufferGetBytesPerRow(cf);
			buffer = (uint8_t *) CVPixelBufferGetBaseAddress(cf);
			
			for(y=0; y< h; y++ ) {
				for(x=0; x< w; x++ ) {
					
					// not handling 440 chroma right now
					// Actually I don't think mjpeg supports it either
					cy0 = yuv_data[0][x + y * w];
					cu = yuv_data[1][x + y * w];					
					cv = yuv_data[2][x + y * w];
					
					buffer[y * b + (x<<2)    ] = cu;
					buffer[y * b + (x<<2) + 1] = cy0;
					buffer[y * b + (x<<2) + 2] = cv;
					buffer[y * b + (x<<2) + 3] = 255;
					
				}
			}
			
			/*
			 */
			break;
		case k422YpCbCr8PixelFormat:
			
			h = CVPixelBufferGetHeight(cf);
			w = CVPixelBufferGetWidth(cf);
			b = CVPixelBufferGetBytesPerRow(cf);
			buffer = (uint8_t *) CVPixelBufferGetBaseAddress(cf);
			
			int yoff =0 , ycoff=0, yqoff=0,yb=0;
			int wc = w >> 1;
			int x4 = 0,x2=0;
			int yh,yp;
			
			bool chromasw,chromash,chromadw,chromadh,chromaqw,progressive;
			
			chromasw = [self getChromaSubsampleN] ==1;
			chromash = [self getChromaSubsampleD] ==1;
			chromadw = [self getChromaSubsampleN] ==2;
			chromadh = [self getChromaSubsampleD] ==2;
			chromaqw = [self getChromaSubsampleN] ==4;
			
			
			progressive = [self getInterlace] == Y4M_ILACE_NONE;
			
			//	int sz = CVPixelBufferGetDataSize(cf);
			
			// NSLog(@"yuvCVcopy: BytesPerRow: %d %dx%d size: %d",b,w,h,sz);
			
			//optimise this, do want.
			for(y=0; y< h; y++ ) {
				x4 = 0;
				x2 = 0;
				
				if (chromadh) {
					yh = y>>1;
					yp = (((y>>2)<<1) + (y % 2)); // not sure how much of a penalty it is to put this here
				}
				for(x=0; x< wc; x++ ) {
					
					// planar vs packed, it's such a religious argument.
					// I prefer planar.
                    
                    cu = 128;
                    cv = 128;

                    
					cy0 = yuv_data[0][x2 + yoff];
					cy1 = yuv_data[0][x2 + 1 + yoff];
					
					if (chromash) {
						if (chromasw) { // hack for 444, drops every 2nd chroma pixel
							// I would rather write to an internal 444 buffer but none seem to work.
							// if you know of a 444 buffer that works (and is not RGB) 
							// contact mjpeg0 at silicontrip dot org
							cu = yuv_data[1][x2 + yoff];					
							cv = yuv_data[2][x2 + yoff];
						} else if (chromadw) { 					// handle 422 chroma
							cu = yuv_data[1][x + ycoff];					
							cv = yuv_data[2][x + ycoff];
						} else if (chromaqw) { // hacky 411 chroma display 
							cu = yuv_data[1][(x>>1) + yqoff];
							cv = yuv_data[2][(x>>1) + yqoff];
						} else {
							NSLog(@"Unhandled chroma subsampling");
						}
						//  handle 420 chroma with correct interlaced chroma.
					} else if (chromadh) {
						if (chromadw) {
							if (progressive) {
								// Progressive, 1,1,2,2,3,3,4,4
								cu = yuv_data[1][x + yh * wc];					
								cv = yuv_data[2][x + yh * wc];
							} else {
								// Interlaced, 1,2,1,2,3,4,3,4
								// 0,1,2,3,4,5,6,7  y
								// 0,0,0,0,1,1,1,1  >>2
								// 0,0,0,0,2,2,2,2  >>2 <<1
								// 0,1,0,1,2,3,2,3  >>2 <<1 + %2
								
								// 0,0,1,1,2,2,3,3 >>1
								// 0,1,1,2,2,3,3,4 >>1 + %2
								
								// I think this interlacing algorithm is correct.
								cu = yuv_data[1][x + yp * wc];					
								cv = yuv_data[2][x + yp * wc];
							}
						} else {
							NSLog(@"Unhandled chroma subsampling");
						}
						
					}
					
					// lets see if this is correct
					//		NSLog(@"yuvCVcopy: %d %dx%d",b,y,x);
					buffer[yb + x4    ] = cu;
					buffer[yb + x4 + 1] = cy0;
					buffer[yb + x4 + 2] = cv;
					buffer[yb + x4 + 3] = cy1;
					
					x4 += 4;
					x2 += 2;
				}
				yoff += w;
				ycoff += wc;
				yb += b;
			}
			break;
		case 'y420':  // this appears to be RGB and not YUV
		//	h = CVPixelBufferGetHeight(cf);
		//	w = CVPixelBufferGetWidth(cf);
			
			for(y=0; y< CVPixelBufferGetHeightOfPlane(cf,0); y++ ) {
				
				//	memcpy(CVPixelBufferGetBaseAddressOfPlane(cf,0) + y * 640, 
				memcpy(CVPixelBufferGetBaseAddressOfPlane(cf,0) + y * CVPixelBufferGetBytesPerRowOfPlane(cf,0), 
					   yuv_data[0] + y * CVPixelBufferGetWidthOfPlane(cf,0),
					   CVPixelBufferGetWidthOfPlane(cf,0));
				
				// I assume that the U and V planes are sub sampled at the same rate
				/*
				 if (y < CVPixelBufferGetHeightOfPlane(cf,1)) {
				 memcpy(CVPixelBufferGetBaseAddressOfPlane(cf,1) + y * CVPixelBufferGetBytesPerRowOfPlane(cf,1),
				 m[1] + y * CVPixelBufferGetWidthOfPlane(cf,1),
				 CVPixelBufferGetWidthOfPlane(cf,1));
				 memcpy(CVPixelBufferGetBaseAddressOfPlane(cf,2) + y * CVPixelBufferGetBytesPerRowOfPlane(cf,2),
				 m[2] + y * CVPixelBufferGetWidthOfPlane(cf,2),
				 CVPixelBufferGetWidthOfPlane(cf,2));
				 }
				 */
				
			}
			break;
		default:
			// I'm guessing this bit of code is not Endian independent??
			NSLog(@"No code to handle Pixelbuffer type: %c%c%c%c",pixelFormat>>24,pixelFormat>>16,pixelFormat>>8,pixelFormat);
			break;
	} 	
}



@end
