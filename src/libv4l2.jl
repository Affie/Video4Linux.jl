# wrap libv4l2
#NOTE libv4l2 must be manually installed with `sudo apt-get install libv4l-dev` TODO install with bindeps.jl

function v4l2_close(fd::Cint)
    ccall((:v4l2_close, :libv4l2), Cint, (Cint,), fd)
end

function v4l2_dup(fd::Cint)
    ccall((:v4l2_dup, :libv4l2), Cint, (Cint,), fd)
end

function v4l2_read(fd::Cint, buffer, n::Cint)
    ccall((:v4l2_read, :libv4l2), Clong, (Cint, Ptr{Void}, Cint), fd, buffer, n)
end

function v4l2_write(fd::Cint, buffer, n::Cint)
    ccall((:v4l2_write, :libv4l2), Clong, (Cint, Ptr{Void}, Cint), fd, buffer, n)
end

function v4l2_mmap(start, length::Cint, prot::Cint, flags::Cint, fd::Cint, offset::Int64)
    ccall((:v4l2_mmap, :libv4l2), Ptr{Void}, (Ptr{Void}, Cint, Cint, Cint, Cint, Int64), start, length, prot, flags, fd, offset)
end

function v4l2_munmap(_start, length::Cint)
    ccall((:v4l2_munmap, :libv4l2), Cint, (Ptr{Void}, Cint), _start, length)
end

function v4l2_set_control(fd::Cint, cid::Cint, value::Cint)
    ccall((:v4l2_set_control, :libv4l2), Cint, (Cint, Cint, Cint), fd, cid, value)
end

function v4l2_get_control(fd::Cint, cid::Cint)
    ccall((:v4l2_get_control, :libv4l2), Cint, (Cint, Cint), fd, cid)
end

function v4l2_fd_open(fd::Cint, v4l2_flags::Cint)
    ccall((:v4l2_fd_open, :libv4l2), Cint, (Cint, Cint), fd, v4l2_flags)
end

function v4l2_open(file::String = "/dev/video0", oflag = 0x0802, arg = Cint(0)) #default hard coded for O_RDWR | O_NONBLOCK
    ccall((:v4l2_open, :libv4l2), Cint, (Cstring, Cint, Cint...), file, oflag, arg)
end


# int v4l2_ioctl(int fd, unsigned long int request, ...);
function v4l2_ioctl(fd::Cint, request::Integer, arg::Integer)
    ccall((:v4l2_ioctl, :libv4l2), Cint, (Cint, Culong, Cint...), fd, request, arg)
end
function v4l2_ioctl(fd::Cint, request::Integer, arg)
    ccall((:v4l2_ioctl, :libv4l2), Cint, (Cint, Culong, Ptr{Void}...), fd, request, arg)
end
