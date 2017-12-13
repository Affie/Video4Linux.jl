
function v4l2_close(fd::Cint)
    ccall((:v4l2_close, libv4l2), Cint, (Cint,), fd)
end

function v4l2_dup(fd::Cint)
    ccall((:v4l2_dup, libv4l2), Cint, (Cint,), fd)
end

function v4l2_read(fd::Cint, buffer, n::Cint)
    ccall((:v4l2_read, libv4l2), ssize_t, (Cint, Ptr{Void}, Cint), fd, buffer, n)
end

function v4l2_write(fd::Cint, buffer, n::Cint)
    ccall((:v4l2_write, libv4l2), ssize_t, (Cint, Ptr{Void}, Cint), fd, buffer, n)
end

function v4l2_mmap(start, length::Cint, prot::Cint, flags::Cint, fd::Cint, offset::Int64)
    ccall((:v4l2_mmap, libv4l2), Ptr{Void}, (Ptr{Void}, Cint, Cint, Cint, Cint, Int64), start, length, prot, flags, fd, offset)
end

function v4l2_munmap(_start, length::Cint)
    ccall((:v4l2_munmap, libv4l2), Cint, (Ptr{Void}, Cint), _start, length)
end

function v4l2_set_control(fd::Cint, cid::Cint, value::Cint)
    ccall((:v4l2_set_control, libv4l2), Cint, (Cint, Cint, Cint), fd, cid, value)
end

function v4l2_get_control(fd::Cint, cid::Cint)
    ccall((:v4l2_get_control, libv4l2), Cint, (Cint, Cint), fd, cid)
end

function v4l2_fd_open(fd::Cint, v4l2_flags::Cint)
    ccall((:v4l2_fd_open, libv4l2), Cint, (Cint, Cint), fd, v4l2_flags)
end
