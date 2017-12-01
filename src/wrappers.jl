
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

##
# struct to save the buffer data
struct Buffer8
    start::Ptr{UInt8}
    length::Csize_t
end

function get_global_bufferU8()
    buffers = cglobal((:buffers, :libv4lcapture), Ptr{Buffer8})
    buffers = cglobal((:buffers, :libv4lcapture), Ptr{Buffer8})
    buf1 = unsafe_load(buffers,1)
    buf = unsafe_load(buf1,1)
end

function copy_buffer_bytes(numbytes::Int)

    buf = get_global_bufferU8()
    if numbytes > Int(buf.length)
        error("Trying to read more bytes than buffer size:")
    end
    im = zeros(UInt8, numbytes)
    unsafe_copy!(pointer(im), buf.start, numbytes)
    return im
end
