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

## thes specific camera used in this test was 640x480 YCbCr 4:2:2
imY = reshape(imbuff[2:2:end],(640,480))'
imshow(imY)

#recover colors
imCbCr = imbuff[1:2:end]

imCb = kron(reshape(imCbCr[1:2:end], (320,480))', [1 1])

imCr = kron(reshape(imCbCr[2:2:end], (320,480))', [1 1])

#create YCbCr array
imcol = YCbCr.(imY, imCb, imCr)
#convert to rgb and display
imshow(convert.(RGB,imcol))
