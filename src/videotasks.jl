"""
    vidproducer(c::Channel, reader::T, devicename::String = "/dev/video0",  N::Int = 100) where T <: AbstractEncodings

"""
function videoproducer(c::Channel, decoder::T; devicename::String = "/dev/video0",  N::Int = 100) where T <: AbstractEncodings

    ##
    set_io_method(Video4Linux.IO_METHOD_READ)

    ## open device
    fid = open_device(devicename)

    ## init_device(fd, force_format);
    init_device(fid)

    ## start_capturing(fd);
    start_capturing(fid)
    @show decoder

    imy = (decoder.depth > 1)? zeros(decoder.datatype, decoder.height, decoder.width, decoder.depth) :
                               zeros(decoder.datatype, decoder.height, decoder.width)

    for i = 1:N
        mainloop( fid, 1 )
        ## copy_buffer_bytes, copy the image buffer bytes to uint8 vector, the lenght will depend on the pixel format
        decoder(imy)
        put!(c, imy)
    end

    ## stop_capturing(fd);
    stop_capturing(fid)

    ## uninit_device();
    uninit_device(fid)

    ## close device
    close_device(fid)
end

##
#vidchan = Channel((c::Channel) -> videoproducer(c, yonly))
