
function set_io_method(method::Int64 = 0)
    ccall((:set_io_method,:libv4lcapture), Void, (Int64,), method)
end

function open_device(devicename::String = "/dev/video0")
## open device
    fid = ccall((:open_device,:libv4lcapture), Int, (Cstring,), devicename)
end

function init_device(fid::Int)
## init_device(fd, force_format);
    ccall((:init_device, :libv4lcapture),   Void, ( Int, Int), fid, 0 )
end

function start_capturing(fid::Int)
## start_capturing(fd);
    ccall((:start_capturing, :libv4lcapture),  Void, ( Int,), fid )
end

function mainloop(fid::Int, frame_count::Int)
## mainloop(fd, frame_count);
    ccall((:mainloop, :libv4lcapture),  Void, ( Int, Int), fid, frame_count)
end

function stop_capturing(fid::Int)
## stop_capturing(fd);
    ccall((:stop_capturing, :libv4lcapture), Void, ( Int,), fid )
end

function uninit_device(fid::Int)
## uninit_device();
    ccall((:uninit_device, :libv4lcapture),  Void, () )
end

function close_device(fid::Int)
## close device
    ccall((:close_device,:libv4lcapture), Void, (Int,), fid)
end
