var documenterSearchIndex = {"docs":
[{"location":"#Video4Linux.jl-1","page":"Home","title":"Video4Linux.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"The aim of this package is to provide lower level access to the v4l2 driver for raw data manipulation. As much as possible should be implemented in Julia. This is work in progress and any suggestions and contributions are very welcome.  ","category":"page"},{"location":"#","page":"Home","title":"Home","text":"(Image: Build Status)","category":"page"},{"location":"#","page":"Home","title":"Home","text":"(Image: codecov.io)","category":"page"},{"location":"#Installation-1","page":"Home","title":"Installation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"The package is currently unregistered and can be installed and build with: (replace YOURREPONAME with your github fork name)","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Pkg.clone(\"https://github.com/YOURREPONAME/Video4Linux.jl.git\")\nPkg.build(\"Video4Linux\")","category":"page"},{"location":"#Device-Setup-1","page":"Home","title":"Device Setup","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"No automatic setup is currently performed but there are utilities to make this easy: qv4l2 (install with: sudo apt-get install qv4l2) qv4l2 provides a gui of the ioctl of the device. Settings such as frame size and capture format can easily be changed.","category":"page"},{"location":"#Kinect-Example-1","page":"Home","title":"Kinect Example","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Currently the only camera tested is the Kenect using the v4l2 kernel driver.   This example was run on an raspberry pi 3 with Rasbian and julia 0.6.    The kenect driver can be set to depth mode with:   sudo rmmod gspca_kinect   sudo modprobe gspca_kinect depth_mode = 1  ","category":"page"},{"location":"#","page":"Home","title":"Home","text":"using Video4Linux\nusing ImageView\nusing Colors, ColorTypes\n\n# Warning! no memory and device protection is implemented yet, therefore doing things out of order will cause julia to crash!\n## set io method to read() for the Kenect depth image. NOTE: if your device does not support read try using Video4Linux.IO_METHOD_MMAP\nset_io_method(Video4Linux.IO_METHOD_READ)\n## open device\nfid = open_device(\"/dev/video0\")\n## init_device(fd, force_format);\ninit_device(fid)\n## start_capturing(fd);\nstart_capturing(fid)\n## mainloop(fd, frame_count);\nmainloop( fid, 1 )\n## copy_buffer_bytes, copy the image buffer bytes to uint8 vector, the lenght will depend on the pixel format\nimbuff = copy_buffer_bytes(640*480*2)\n## stop_capturing(fd);\nstop_capturing(fid)\n## uninit_device();\nuninit_device(fid)\n## close device\nclose_device(fid)\n## kenect 1 depth image, set kernel to depth with:\ndepthvec = convertY10BtoU16(imbuff[1:384000])\ndepthim = reshape(depthvec,(640,480))'\nimshow(depthim)","category":"page"},{"location":"#","page":"Home","title":"Home","text":"(Image: kenect depth image)","category":"page"},{"location":"#Manual-Outline-1","page":"Home","title":"Manual Outline","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Pages = [\n    \"index.md\"\n    \"func_ref.md\"\n]","category":"page"},{"location":"func_ref/#Function-Reference-1","page":"Functions","title":"Function Reference","text":"","category":"section"},{"location":"func_ref/#","page":"Functions","title":"Functions","text":"Pages = [\n    \"func_ref.md\"\n]\nDepth = 3","category":"page"},{"location":"func_ref/#Wrappers-1","page":"Functions","title":"Wrappers","text":"","category":"section"},{"location":"func_ref/#","page":"Functions","title":"Functions","text":"Video4Linux.IOMethods\nVideo4Linux.set_io_method\nVideo4Linux.open_device\nVideo4Linux.init_device\nVideo4Linux.start_capturing\nVideo4Linux.mainloop\nVideo4Linux.stop_capturing\nVideo4Linux.uninit_device\nVideo4Linux.close_device\n\nVideo4Linux.copy_buffer_bytes\nVideo4Linux.copy_buffer_bytes!\n","category":"page"},{"location":"func_ref/#Video4Linux.IOMethods","page":"Functions","title":"Video4Linux.IOMethods","text":"Enumerated type for IO method used\n\n\n\n\n\n","category":"type"},{"location":"func_ref/#Video4Linux.set_io_method","page":"Functions","title":"Video4Linux.set_io_method","text":"function set_io_method(method::IOMethods)\n\nSet the IO method to one of the following enumerated types:\n\n    Video4Linux.IO_METHOD_READ\n    Video4Linux.IO_METHOD_MMAP\n    Video4Linux.IO_METHOD_USERPTR\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.open_device","page":"Functions","title":"Video4Linux.open_device","text":"open_device(deviceSting)\n\nOpen v4l2 video device [/dev/video0], returns device hanle [Int32]\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.init_device","page":"Functions","title":"Video4Linux.init_device","text":"init_device(devicHandle)\n\nInitialize already opened device. Returns 0 on success.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.start_capturing","page":"Functions","title":"Video4Linux.start_capturing","text":"start_capturing(devicHandle)\n\nStart capturing on opened and initialized device. Returns 0 on success.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.mainloop","page":"Functions","title":"Video4Linux.mainloop","text":"mainloop(devicHandle, frameCount)\n\nRun main capute loop [frameCount] times. Returns 0 on success.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.stop_capturing","page":"Functions","title":"Video4Linux.stop_capturing","text":"stop_capturing(devicHandle)\n\nStop capturing on opened device. Returns 0 on success.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.uninit_device","page":"Functions","title":"Video4Linux.uninit_device","text":"uninit_device(devicHandle)\n\nUninitialize already opened device. Returns 0 on success.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.close_device","page":"Functions","title":"Video4Linux.close_device","text":"close_device(devicHandle)\n\nClose already opened device. Returns 0 on success.\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.copy_buffer_bytes","page":"Functions","title":"Video4Linux.copy_buffer_bytes","text":"copy_buffer_bytes(numBytes)\n\nCopy [numBytes] from buffer to new buffer [Array{UInt8,1}]\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.copy_buffer_bytes!","page":"Functions","title":"Video4Linux.copy_buffer_bytes!","text":"copy_buffer_bytes!(outbuffer, numBytes)\n\nCopy [numBytes] from buffer to existing buffer outbuffer[Array{UInt8,1}]\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Tasks-1","page":"Functions","title":"Tasks","text":"","category":"section"},{"location":"func_ref/#","page":"Functions","title":"Functions","text":"Video4Linux.videoproducer","category":"page"},{"location":"func_ref/#Video4Linux.videoproducer","page":"Functions","title":"Video4Linux.videoproducer","text":"vidproducer(c::Channel, reader::T, devicename::String = \"/dev/video0\",  N::Int = 100) where T <: AbstractEncodings\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Encodind/decoding-1","page":"Functions","title":"Encodind/decoding","text":"","category":"section"},{"location":"func_ref/#","page":"Functions","title":"Functions","text":"Video4Linux.UYVYextractY\nVideo4Linux.convertYUYVtoArray\nVideo4Linux.convertY10BtoU16\nVideo4Linux.convertUYVYtoYCbCr\nVideo4Linux.convertYUYVtoYCbCr\nVideo4Linux.convertUYVYtoArray\nVideo4Linux.YUYVextractY","category":"page"},{"location":"func_ref/#Video4Linux.UYVYextractY","page":"Functions","title":"Video4Linux.UYVYextractY","text":"UYVYextractY(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nExtract the Y component out of a 4:2:2 YCbCr buffer\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.convertYUYVtoArray","page":"Functions","title":"Video4Linux.convertYUYVtoArray","text":"convertYUYVtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full 4:4:4 buffer [::Matrix{UInt8}[3]]\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.convertY10BtoU16","page":"Functions","title":"Video4Linux.convertY10BtoU16","text":"convertY10BtoU16(imbuff::Vector{UInt8})\n\nConvert a packed 10 bit grayscale buffer [::Vector{UInt8}] to 16 bit padded buffer [::Vector{UInt16}] [x x x x x x b9 b8 b7 b6 b5 b4 b3 b2 b1 b0]\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.convertUYVYtoYCbCr","page":"Functions","title":"Video4Linux.convertUYVYtoYCbCr","text":"convertUYVYtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a UYVY 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full YCbCr\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.convertYUYVtoYCbCr","page":"Functions","title":"Video4Linux.convertYUYVtoYCbCr","text":"convertYUYVtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a UYVY 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full YCbCr\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.convertUYVYtoArray","page":"Functions","title":"Video4Linux.convertUYVYtoArray","text":"convertUYVYtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full 4:4:4 buffer [::Matrix{UInt8}[3]]\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Video4Linux.YUYVextractY","page":"Functions","title":"Video4Linux.YUYVextractY","text":"UYVYextractY(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nExtract the Y component out of a 4:2:2 YCbCr buffer\n\n\n\n\n\n","category":"function"},{"location":"func_ref/#Index-1","page":"Functions","title":"Index","text":"","category":"section"},{"location":"func_ref/#","page":"Functions","title":"Functions","text":"","category":"page"}]
}