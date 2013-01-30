//
//  main.m
//  yuvCoreVideoplay
//
//  Created by Mark Heath on 15/03/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <unistd.h>
#import "yuvGlobals.h"

static void print_usage() 
{
	fprintf (stderr,
			 "usage: yuvCoreVideoplay [-v] [-c] [-p] [-r|-R <d:n>] [-a <d:n>] [-n]\n"
			 "yuvCoreVideoplay  plays video from a yuvstream\n"
			 "\n"
			 "\t -c passthrough mode. will write the stream to stdout.\n"
			 "\t -p paused. display the first frame and pause.\n"
			"\t -r ignore frame rate. Play each frame as it becomes available\n"
			"\t -R override frame rate to this\n"
			"\t -a override aspect ratio to this\n"
			"\t -n do not skip frames.  Needed for slow video filters.\n"
			 "\t -v Verbosity degree : 0=quiet, 1=normal, 2=verbose/debug\n"
			 "\t -h print this help\n"
			 );
}


int main(int argc, char *argv[])
{

	int c ;
	const static char *legal_flags = "v:cprR:a:nh?";
	yuvGlobals *globalsInstance;

	globalsInstance = [yuvGlobals getInstance];

		while ((c = getopt (argc, argv, legal_flags)) != -1) {
		switch (c) {
			case 'v':
				[globalsInstance setVerbose:atoi(optarg)];
				break;				
			case 'h':
			case '?':
				print_usage (argv);
				return 0 ;
				break;
			case 'c':
				[globalsInstance setPassThrough:YES];
				break;
			case 'p':
				[globalsInstance setPaused:TRUE];
				break;
			case 'r':
				[globalsInstance setIgnoreRate:true];
				break;
			case 'R':
				[globalsInstance setRateWithChar:optarg];
				break;
			case 'a':
				[globalsInstance setAspectWithChar:optarg];
				break;
			case 'n':
				[globalsInstance setNoSkip:true];
				break;
		}
	}


    return NSApplicationMain(argc,  (const char **) argv);
}
