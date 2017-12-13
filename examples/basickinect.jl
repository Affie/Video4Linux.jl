using Video4Linux
using ImageView
using Colors, ColorTypes

# Warning! no memory and device protection is implemented yet, therefore doing things out of order will cause julia to crash!

## NOTE: if your device does not support read try using Video4Linux.IO_METHOD_MMAP
set_io_method(Video4Linux.IO_METHOD_READ)

## open device
fid = open_device("/dev/video0")

## init_device(fd, force_format);
init_device(fid)

## start_capturing(fd);
start_capturing(fid)

## mainloop(fd, frame_count);
mainloop( fid, 1 )

## copy_buffer_bytes, copy the image buffer bytes to uint8 vector, the lenght will depend on the pixel format
imbuff = copy_buffer_bytes(640*480*2)
## copy frame data: raw + width + height + pixelformat
frame = Video4Linux.copy_buffer_frame()
#do some convertions on frame
img = Video4Linux.convert(Gray, frame)
imc = Video4Linux.convert(YCbCr, frame)
imshow(img)

## stop_capturing(fd);
stop_capturing(fid)

## uninit_device();
uninit_device(fid)

## close device
close_device(fid)

## kinect color image; manually set the driver to 640x480 YCbCr 4:2:2 for this test (can be done with qv4l2)

imYCbCr = convertUYVYtoYCbCr(imbuff, 640, 480)
#convert to rgb and display
imshow(convert.(RGB,imYCbCr))


## kinect 1 depth image, set kernel to depth with:
    #sudo rmmod gspca_kinect
    #sudo modprobe gspca_kinect depth_mode = 1

depthvec = convertY10BtoU16(imbuff[1:384000])

depthim = reshape(depthvec,(640,480))'
imshow(depthim)
