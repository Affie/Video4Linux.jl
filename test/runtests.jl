using Video4Linux
using Colors, ColorTypes
using Base.Test


@testset "Video4Linux" begin


    #conversions
    testu8 = zeros(UInt8,5)
    for i = 1:5
        testu8[i] = 0x01 << (i-1)
    end
    @test convertY10BtoU16(testu8) == [0x0004, 0x0020, 0x0102, 0x0010]

    # Reference
    A = [0.0  0.0 32.0;
       128.0 64.0 96.0;
        64.0  0.0 32.0;
       192.0 64.0 96.0]

    testu8 = zeros(UInt8,8)
    y = 0x00
    for i = 2:2:8
        testu8[i] = UInt8(y)
        y += 0x40
    end
    y = 0x00
    for i = 1:2:8
        testu8[i] = UInt8(y)
        y += 0x20
    end

    im = convertUYVYtoYCbCr(testu8, 2, 2)

    @test im == reshape(YCbCr.(A[:,1], A[:,2], A[:,3]),(2,2))



    testu8 = zeros(UInt8,8)
    y = 0x00
    for i = 1:2:8
        testu8[i] = UInt8(y)
        y += 0x40
    end
    y = 0x00
    for i = 2:2:8
        testu8[i] = UInt8(y)
        y += 0x20
    end
    im = convertYUYVtoYCbCr(testu8, 2, 2)
    @test im == reshape(YCbCr.(A[:,1], A[:,2], A[:,3]),(2,2))

    im = Video4Linux.convertYUYVtoArray(testu8, 2, 2)
    @test im == reshape(A,(2,2,3))

    #wrapper
    @test set_io_method() == nothing
    @test set_io_method(Int32(0)) == nothing
    @test set_io_method(Video4Linux.IO_METHOD_MMAP) == nothing

    #for now these should just not break julia
    fid = open_device("/dev/video0")
    init_device(Int32(0))
    start_capturing(Int32(0))
    stop_capturing(Int32(0))
    uninit_device(Int32(0))
    close_device(Int32(0))
    temptestvalue = 0
    try
        # this should through error to protect julia from crashing
        mainloop( Int32(-1), 1 )
    catch
        temptestvalue = 1
    end
    @test 1 == temptestvalue

    # some more api
    d1 = Video4Linux.UYVY(640,480)
    d2 = Video4Linux.UYVYonlyY(640,480)
    d3 = Video4Linux.YUYV(640,480)
    d4 = Video4Linux.YUYVonlyY(640,480)
    d5 = Video4Linux.Y10B(640,480)

    #also just test not te break julia
    vidchan = Channel((c::Channel) -> videoproducer(c, d1))
    vidchan = Channel((c::Channel) -> videoproducer(c, d2, devicename = "/dev/video0"))
    vidchan = Channel((c::Channel) -> videoproducer(c, d3, devicename = "/dev/video0", iomethod = Video4Linux.IO_METHOD_READ))


end
