global breakFromLoop = false

"""
    stopVideoProducer()
Stop the running video producer and close the device and channel.
"""
function stopVideoProducer()
    global breakFromLoop = true
end

"""
    vidproducer(c::Channel, reader::T, devicename::String = "/dev/video0",  N::Int = 100) where T <: AbstractEncodings

"""
function videoproducer(c::Channel, decoder::T; devicename::String = "/dev/video0",  N::Int = 100, iomethod::IOMethods = Video4Linux.IO_METHOD_READ) where T <: AbstractEncodings
    global breakFromLoop = false
    ##
    set_io_method(iomethod)

    ## open device
    fid = open_device(devicename)

    ## init_device(fd, force_format);
    init_device(fid) != 0 && error("Erro in device init")

    ## start_capturing(fd);
    start_capturing(fid) != 0 && error("Erro in start_capturing")

    imy = (decoder.depth > 1)? zeros(decoder.datatype, decoder.height, decoder.width, decoder.depth) :
                               zeros(decoder.datatype, decoder.height, decoder.width)

    NN = N > 0 ? N : Inf
    i = 0
    while i < NN
        i += 1
        mainloop( fid, 1 ) != 0 && error("Erro in mainloop")
        ## copy_buffer_bytes, copy the image buffer bytes to uint8 vector, the lenght will depend on the pixel format
        decoder(imy)
        put!(c, imy)
        if breakFromLoop
            break
        end
    end

    ## stop_capturing(fd);
    stop_capturing(fid) != 0 && error("Erro in stop_capturing")

    ## uninit_device();
    uninit_device(fid) != 0 && error("Erro in uninit_device")

    ## close device
    close_device(fid) != 0 && error("Erro in close_device")
end

##
#vidchan = Channel((c::Channel) -> videoproducer(c, yonly))
