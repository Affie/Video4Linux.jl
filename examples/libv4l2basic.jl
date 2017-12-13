using ImageView, Colors, ColorTypes
import Video4Linux

#NOTE libv4l2 must be manually installed with `sudo apt-get install libv4l-dev` TODO install with bindeps.jl
## as a basic usage it is as simple as oppining reading, and closing the video device...

## open video device with default settings
fd = Video4Linux.v4l2_open("/dev/video0")

## create a larege enought buffer for the data
width = 640
height = 480
nbytes = width*height*2 #640 x 480 x 2 (for 640*480 UYUV 4:2:2 encoding)
buffer = zeros(UInt8, nbytes)

## read data with libv4l2, will work even if the device does not support read!
status = Video4Linux.v4l2_read(fd, pointer(buffer), Cint(nbytes))
# FIXME first time -1 is returned but if ran again it works for some reason

##
imYCbCr = Video4Linux.convertYUYVtoYCbCr(buffer[1:(nbytes)], width, height)
imshow(convert.(RGB,imYCbCr))

##close device
status= Video4Linux.v4l2_close(fd)
