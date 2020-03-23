
"""
Enumerated type for IO method used
"""
@enum IOMethods IO_METHOD_READ = 0 IO_METHOD_MMAP = 1 IO_METHOD_USERPTR = 3

function set_io_method(method::Int32 = Int32(0))
    ccall((:set_io_method,:libv4lcapture), Nothing, (Int32,), method)
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
    ccall((:set_io_method,:libv4lcapture), Nothing, (Int32,), Int32(method))
end

"""
    open_device(deviceSting)

Open v4l2 video device [`/dev/video0`], returns device hanle [`Int32`]
"""
function open_device(devicename::String = "/dev/video0")
## open device
    fid = ccall((:open_device,:libv4lcapture), Int32, (Cstring,), devicename)
end

"""
    init_device(devicHandle)

Initialize already opened device. Returns 0 on success.
"""
function init_device(fid::Int32)
## init_device(fd, force_format);
    fid == -1 && error("Bad file descriptor")
    ccall((:init_device, :libv4lcapture),   Int32, ( Int32, Int32), fid, 0 )
end

"""
    start_capturing(devicHandle)

Start capturing on opened and initialized device. Returns 0 on success.
"""
function start_capturing(fid::Int32)
## start_capturing(fd);
    fid == -1 && error("Bad file descriptor")
    ccall((:start_capturing, :libv4lcapture),  Int32, ( Int32,), fid )
end

"""
    mainloop(devicHandle, frameCount)

Run main capute loop [frameCount] times. Returns 0 on success.
"""
function mainloop(fid::Int32, frame_count::Int32)
## mainloop(fd, frame_count);
    fid == -1 && error("Bad file descriptor")
    ccall((:mainloop, :libv4lcapture),  Int32, ( Int32, Int32), fid, frame_count)
end

mainloop(fid::Int32, frame_count::Int64) = mainloop(fid, convert(Int32,frame_count))

"""
    stop_capturing(devicHandle)

Stop capturing on opened device. Returns 0 on success.
"""
function stop_capturing(fid::Int32)
## stop_capturing(fd);
    fid == -1 && error("Bad file descriptor")
    ccall((:stop_capturing, :libv4lcapture), Int32, ( Int32,), fid )
end

"""
    uninit_device(devicHandle)

Uninitialize already opened device. Returns 0 on success.
"""
function uninit_device(fid::Int32)
## uninit_device();
    fid == -1 && error("Bad file descriptor")
    ccall((:uninit_device, :libv4lcapture),  Int32, () )
end

"""
    close_device(devicHandle)

Close already opened device. Returns 0 on success.
"""
function close_device(fid::Int32)
## close device
    ccall((:close_device,:libv4lcapture), Int32, (Int32,), fid)
end

##
struct RawFrame
    data::Vector{UInt8}
    width::Int
    height::Int
    pixelformat::Symbol
end

# struct to save the buffer data # and pixel format
struct Buffer8
    start::Ptr{UInt8}
    length::Csize_t
    width::UInt32
    height::UInt32
    pixelformat::UInt32
end

function get_global_bufferU8()
    # buffers = cglobal((:buffers, :libv4lcapture), Ptr{Buffer8})
    buffers = cglobal((:buffers, :libv4lcapture), Ptr{Buffer8})
    buf1 = unsafe_load(buffers,1)
    buf = unsafe_load(buf1,1)
end

"""
    copy_buffer_bytes(numBytes)

Copy [numBytes] from buffer to new buffer [`Array{UInt8,1}`]
"""
function copy_buffer_bytes(numbytes::Int64)

    buf = get_global_bufferU8()
    if numbytes > buf.length
        error("Trying to read more bytes than buffer size:")
    end
    im = zeros(UInt8, numbytes)
    unsafe_copyto!(pointer(im), buf.start, numbytes)
    return im
end

"""
    copy_buffer_bytes!(outbuffer, numBytes)

Copy [numBytes] from buffer to existing buffer outbuffer[`Array{UInt8,1}`]
"""
function copy_buffer_bytes!(im::Vector{UInt8}, numbytes::Int64)

    buf = get_global_bufferU8()
    if numbytes > buf.length
        error("Trying to read more bytes than buffer size:")
    end
    if length(im) != numbytes
        resize!(im, numbytes)
        warn("Output buffer size does not match number of bytes to be read, resizing.")
    end
    unsafe_copyto!(pointer(im), buf.start, numbytes)
    return nothing
end


"""
    copy_buffer_frame()


"""
function copy_buffer_frame()
    buf = get_global_bufferU8()
    newframe = RawFrame(zeros(UInt8, buf.length), Int(buf.width), Int(buf.height), Symbol(String(reinterpret(UInt8, [buf.pixelformat]))))
    unsafe_copyto!(pointer(newframe.data), buf.start, buf.length)
    return newframe
end


function get_v4l2_format(fid::Int32, pix::v4l2_pix_format)
    # get_v4l2_format(int fd, struct v4l2_pix_format *pix)
    fid == -1 && error("Bad file descriptor")
    ccall((:get_v4l2_format,:libv4lcapture), Int32, (Int32, Ref{v4l2_pix_format}), fid, pix)
end


function set_v4l2_format(fid::Int32, pix::v4l2_pix_format)
    # get_v4l2_format(int fd, struct v4l2_pix_format *pix)
    fid == -1 && error("Bad file descriptor")
    ccall((:set_v4l2_format,:libv4lcapture), Int32, (Int32, Ref{v4l2_pix_format}), fid, pix)
end


# int jlioctl(int fh, int request, void *arg)
function jlioctl(fd::Cint, request::UInt64, arg)
    ccall((:jlioctl, :libv4lcapture), Cint, (Cint, Culong, Ptr{Void}), fd, request, arg)
end
