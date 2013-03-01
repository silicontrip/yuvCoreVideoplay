yuvCoreVideoplay
================

a command line video player which reads y4mstreams from stdin and optionally writes them to stdout.

    usage: yuvCoreVideoplay [-v] [-c] [-p] [-r|-R <d:n>] [-a <d:n>] [-n]
    yuvCoreVideoplay  plays video from a yuvstream

    -c  Passthrough mode. will write the stream to stdout.
    -p	Paused. display the first frame and pause.
    -r	ignore frame rate. Play each frame as it becomes available
    -R	override frame rate to this
    -a	override aspect ratio to this
    -n	do not skip frames.  Needed for slow video filters.
    -v	Verbosity degree : 0=quiet, 1=normal, 2=verbose/debug
    -h	print this help
