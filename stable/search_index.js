var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Video4Linux.jl-1",
    "page": "Home",
    "title": "Video4Linux.jl",
    "category": "section",
    "text": "The aim of this package is to provide lower level access to the v4l2 driver for raw data manipulation. As much as possible should be implemented in Julia. This is work in progress and any suggestions and contributions are very welcome.  (Image: Build Status)(Image: codecov.io)"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The package is currently unregistered and can be installed and build with: (replace YOURREPONAME with your github fork name)Pkg.clone(\"https://github.com/YOURREPONAME/Video4Linux.jl.git\")\nPkg.build(\"Video4Linux\")"
},

{
    "location": "index.html#Device-Setup-1",
    "page": "Home",
    "title": "Device Setup",
    "category": "section",
    "text": "No automatic setup is currently performed but there are utilities to make this easy: qv4l2 (install with: sudo apt-get install qv4l2) qv4l2 provides a gui of the ioctl of the device. Settings such as frame size and capture format can easily be changed."
},

{
    "location": "index.html#Kinect-Example-1",
    "page": "Home",
    "title": "Kinect Example",
    "category": "section",
    "text": "Currently the only camera tested is the Kenect using the v4l2 kernel driver.   This example was run on an raspberry pi 3 with Rasbian and julia 0.6.    The kenect driver can be set to depth mode with:   sudo rmmod gspca_kinect   sudo modprobe gspca_kinect depth_mode = 1  using Video4Linux\nusing ImageView\nusing Colors, ColorTypes\n\n# Warning! no memory and device protection is implemented yet, therefore doing things out of order will cause julia to crash!\n## set io method to read() for the Kenect depth image. NOTE: if your device does not support read try using Video4Linux.IO_METHOD_MMAP\nset_io_method(Video4Linux.IO_METHOD_READ)\n## open device\nfid = open_device(\"/dev/video0\")\n## init_device(fd, force_format);\ninit_device(fid)\n## start_capturing(fd);\nstart_capturing(fid)\n## mainloop(fd, frame_count);\nmainloop( fid, 1 )\n## copy_buffer_bytes, copy the image buffer bytes to uint8 vector, the lenght will depend on the pixel format\nimbuff = copy_buffer_bytes(640*480*2)\n## stop_capturing(fd);\nstop_capturing(fid)\n## uninit_device();\nuninit_device(fid)\n## close device\nclose_device(fid)\n## kenect 1 depth image, set kernel to depth with:\ndepthvec = convertY10BtoU16(imbuff[1:384000])\ndepthim = reshape(depthvec,(640,480))\'\nimshow(depthim)(Image: kenect depth image)"
},

{
    "location": "index.html#Manual-Outline-1",
    "page": "Home",
    "title": "Manual Outline",
    "category": "section",
    "text": "Pages = [\n    \"index.md\"\n    \"func_ref.md\"\n]"
},

{
    "location": "func_ref.html#",
    "page": "Functions",
    "title": "Functions",
    "category": "page",
    "text": ""
},

{
    "location": "func_ref.html#Function-Reference-1",
    "page": "Functions",
    "title": "Function Reference",
    "category": "section",
    "text": "Pages = [\n    \"func_ref.md\"\n]\nDepth = 3"
},

{
    "location": "func_ref.html#Wrappers-1",
    "page": "Functions",
    "title": "Wrappers",
    "category": "section",
    "text": "Video4Linux.IOMethods\nVideo4Linux.set_io_method\nVideo4Linux.open_device\nVideo4Linux.init_device\nVideo4Linux.start_capturing\nVideo4Linux.mainloop\nVideo4Linux.stop_capturing\nVideo4Linux.uninit_device\nVideo4Linux.close_device\n\nVideo4Linux.copy_buffer_bytes\nVideo4Linux.copy_buffer_bytes!\n"
},

{
    "location": "func_ref.html#Video4Linux.videoproducer",
    "page": "Functions",
    "title": "Video4Linux.videoproducer",
    "category": "function",
    "text": "vidproducer(c::Channel, reader::T, devicename::String = \"/dev/video0\",  N::Int = 100) where T <: AbstractEncodings\n\n\n\n"
},

{
    "location": "func_ref.html#Tasks-1",
    "page": "Functions",
    "title": "Tasks",
    "category": "section",
    "text": "Video4Linux.videoproducer"
},

{
    "location": "func_ref.html#Video4Linux.UYVYextractY",
    "page": "Functions",
    "title": "Video4Linux.UYVYextractY",
    "category": "function",
    "text": "UYVYextractY(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nExtract the Y component out of a 4:2:2 YCbCr buffer\n\n\n\n"
},

{
    "location": "func_ref.html#Video4Linux.convertYUYVtoArray",
    "page": "Functions",
    "title": "Video4Linux.convertYUYVtoArray",
    "category": "function",
    "text": "convertYUYVtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full 4:4:4 buffer [::Matrix{UInt8}[3]]\n\n\n\n"
},

{
    "location": "func_ref.html#Video4Linux.convertY10BtoU16",
    "page": "Functions",
    "title": "Video4Linux.convertY10BtoU16",
    "category": "function",
    "text": "convertY10BtoU16(imbuff::Vector{UInt8})\n\nConvert a packed 10 bit grayscale buffer [::Vector{UInt8}] to 16 bit padded buffer [::Vector{UInt16}] [x x x x x x b9 b8 b7 b6 b5 b4 b3 b2 b1 b0]\n\n\n\n"
},

{
    "location": "func_ref.html#Video4Linux.convertUYVYtoYCbCr",
    "page": "Functions",
    "title": "Video4Linux.convertUYVYtoYCbCr",
    "category": "function",
    "text": "convertUYVYtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a UYVY 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full YCbCr\n\n\n\n"
},

{
    "location": "func_ref.html#Video4Linux.convertYUYVtoYCbCr",
    "page": "Functions",
    "title": "Video4Linux.convertYUYVtoYCbCr",
    "category": "function",
    "text": "convertYUYVtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a UYVY 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full YCbCr\n\n\n\n"
},

{
    "location": "func_ref.html#Video4Linux.convertUYVYtoArray",
    "page": "Functions",
    "title": "Video4Linux.convertUYVYtoArray",
    "category": "function",
    "text": "convertUYVYtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nConvert a 4:2:2 encoded YCbCr buffer [::Vector{UInt8}] to full 4:4:4 buffer [::Matrix{UInt8}[3]]\n\n\n\n"
},

{
    "location": "func_ref.html#Video4Linux.YUYVextractY",
    "page": "Functions",
    "title": "Video4Linux.YUYVextractY",
    "category": "function",
    "text": "UYVYextractY(imbuff::Vector{UInt8}, width::Int, height::Int)\n\nExtract the Y component out of a 4:2:2 YCbCr buffer\n\n\n\n"
},

{
    "location": "func_ref.html#Encodind/decoding-1",
    "page": "Functions",
    "title": "Encodind/decoding",
    "category": "section",
    "text": "Video4Linux.UYVYextractY\nVideo4Linux.convertYUYVtoArray\nVideo4Linux.convertY10BtoU16\nVideo4Linux.convertUYVYtoYCbCr\nVideo4Linux.convertYUYVtoYCbCr\nVideo4Linux.convertUYVYtoArray\nVideo4Linux.YUYVextractY"
},

{
    "location": "func_ref.html#Index-1",
    "page": "Functions",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
