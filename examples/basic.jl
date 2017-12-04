using Video4Linux
using ImageView
using Colors, ColorTypes

# Warning! no memory and device protection is implemented yet, therefore doing things out of order will cause julia to crash!
##
set_io_method(0)

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

## stop_capturing(fd);
stop_capturing(fid)

## uninit_device();
uninit_device(fid)

## close device
close_device(fid)

## Kenect color image; manually set the driver to 640x480 YCbCr 4:2:2 for this test (can be done with qv4l2)

imYCbCr = convert422toYCbCr(imbuff, 640, 480)
#convert to rgb and display
imshow(convert.(RGB,imYCbCr))


## kenect 1 depth image, set kernel to depth with:
    #sudo rmmod gspca_kinect
    #sudo modprobe gspca_kinect depth_mode = 1

depthvec = y10bpacked2u16(imbuff[1:384000])

depthim = reshape(depthvec,(640,480))'
imshow(depthim)
