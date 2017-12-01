using Video4Linux

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

## stop_capturing(fd);
stop_capturing(fid)

## uninit_device();
uninit_device(fid)

## close device
close_device(fid)
