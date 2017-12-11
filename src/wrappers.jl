
"""
Enumerated type for IO method used
"""
@enum IOMethods IO_METHOD_READ = 0 IO_METHOD_MMAP = 1 IO_METHOD_USERPTR = 3

function set_io_method(method::Int32 = Int32(0))
    ccall((:set_io_method,:libv4lcapture), Void, (Int32,), method)
end

"""
    function set_io_method(method::IOMethods)
Set the IO method to one of the following enumerated types:
```
    Video4Linux.IO_METHOD_READ
    Video4Linux.IO_METHOD_MMAP
    Video4Linux.IO_METHOD_USERPTR
```
"""
function set_io_method(method::IOMethods)
    ccall((:set_io_method,:libv4lcapture), Void, (Int32,), Int32(method))
end


function open_device(devicename::String = "/dev/video0")
## open device
    fid = ccall((:open_device,:libv4lcapture), Int32, (Cstring,), devicename)
end

function init_device(fid::Int32)
## init_device(fd, force_format);
    fid == -1 && error("Bad file descriptor")
    ccall((:init_device, :libv4lcapture),   Int32, ( Int32, Int32), fid, 0 )
end

function start_capturing(fid::Int32)
## start_capturing(fd);
    fid == -1 && error("Bad file descriptor")
    ccall((:start_capturing, :libv4lcapture),  Int32, ( Int32,), fid )
end

function mainloop(fid::Int32, frame_count::Int32)
## mainloop(fd, frame_count);
    fid == -1 && error("Bad file descriptor")
    ccall((:mainloop, :libv4lcapture),  Int32, ( Int32, Int32), fid, frame_count)
end

mainloop(fid::Int32, frame_count::Int64) = mainloop(fid, convert(Int32,frame_count))


function stop_capturing(fid::Int32)
## stop_capturing(fd);
    fid == -1 && error("Bad file descriptor")
    ccall((:stop_capturing, :libv4lcapture), Int32, ( Int32,), fid )
end

function uninit_device(fid::Int32)
## uninit_device();
    fid == -1 && error("Bad file descriptor")
    ccall((:uninit_device, :libv4lcapture),  Int32, () )
end

function close_device(fid::Int32)
## close device
    ccall((:close_device,:libv4lcapture), Int32, (Int32,), fid)
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

function copy_buffer_bytes(numbytes::Int64)

    buf = get_global_bufferU8()
    if numbytes > buf.length
        error("Trying to read more bytes than buffer size:")
    end
    im = zeros(UInt8, numbytes)
    unsafe_copy!(pointer(im), buf.start, numbytes)
    return im
end
