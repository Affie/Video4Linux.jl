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
    @test set_io_method(Int64(0)) == nothing
    @test set_io_method(Video4Linux.IO_METHOD_READ) == nothing

end
