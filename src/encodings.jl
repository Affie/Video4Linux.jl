using Colors, ColorTypes, FixedPointNumbers

import Base: convert

function make_bitvector(v::Vector{UInt8})
    siz = sizeof(v)
    bv = falses(siz<<3)
    unsafe_copyto!(reinterpret(Ptr{UInt8}, pointer(bv.chunks)), pointer(v), siz)
    bv
end


"""
    convertY10BtoU16(imbuff::Vector{UInt8})
Convert a packed 10 bit grayscale buffer [`::Vector{UInt8}`] to 16 bit padded buffer [`::Vector{UInt16}`]
[x x x x x x b9 b8 b7 b6 b5 b4 b3 b2 b1 b0]
"""
function convertY10BtoU16(imbuff::Vector{UInt8} )

    L = length(imbuff)
    bv = reverse(reshape(make_bitvector(imbuff[(L):-1:1]),10,:)',dims=1)

    #convert bit array back to Array{UInt16}
    values = zeros(UInt16, size(bv,1))
    for i = 1:size(bv,1)
        val = 0x0000
        for j = 1:10
            val += bv[i,j] << (j-1)
        end
        values[i] = val
    end
    return values
end


"""
    convertUYVYtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)

Convert a UYVY 4:2:2 encoded YCbCr buffer [`::Vector{UInt8}`] to full YCbCr
"""
function convertUYVYtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)

    halfwidth = div(width,2)

    imY = reshape(imbuff[2:2:end],(width,height))'

    #recover colors
    imCbCr = imbuff[1:2:end]

    imCb = kron(reshape(imCbCr[1:2:end], (halfwidth,height))', [1 1])

    imCr = kron(reshape(imCbCr[2:2:end], (halfwidth,height))', [1 1])

    #create YCbCr array
    return YCbCr.(imY, imCb, imCr)

end

"""
    convertYUYVtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)

Convert a UYVY 4:2:2 encoded YCbCr buffer [`::Vector{UInt8}`] to full YCbCr
"""
function convertYUYVtoYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)

    halfwidth = div(width,2)

    imY = reshape(imbuff[1:2:end],(width,height))'

    #recover colors
    imCbCr = imbuff[2:2:end]

    imCb = kron(reshape(imCbCr[1:2:end], (halfwidth,height))', [1 1])

    imCr = kron(reshape(imCbCr[2:2:end], (halfwidth,height))', [1 1])

    #create YCbCr array
    return YCbCr.(imY, imCb, imCr)

end


"""
    convertUYVYtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)

Convert a 4:2:2 encoded YCbCr buffer [`::Vector{UInt8}`] to full 4:4:4 buffer [`::Matrix{UInt8}[3]`]
"""
function convertUYVYtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)

    halfwidth = div(width,2)

    imY = reshape(imbuff[2:2:end],(width,height))'

    #recover colors
    imCbCr = imbuff[1:2:end]

    imCb = kron(reshape(imCbCr[1:2:end], (halfwidth,height))', [1 1])

    imCr = kron(reshape(imCbCr[2:2:end], (halfwidth,height))', [1 1])

    #create YCbCr array
    return cat(3, imY, imCb, imCr)

end

"""
    convertYUYVtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)

Convert a 4:2:2 encoded YCbCr buffer [`::Vector{UInt8}`] to full 4:4:4 buffer [`::Matrix{UInt8}[3]`]
"""
function convertYUYVtoArray(imbuff::Vector{UInt8}, width::Int, height::Int)

    halfwidth = div(width,2)

    imY = reshape(imbuff[1:2:end],(width,height))'

    #recover colors
    imCbCr = imbuff[2:2:end]

    imCb = kron(reshape(imCbCr[1:2:end], (halfwidth,height))', [1 1])

    imCr = kron(reshape(imCbCr[2:2:end], (halfwidth,height))', [1 1])

    #create YCbCr array
    return cat(imY, imCb, imCr, dims=3)

end

"""
    UYVYextractY(imbuff::Vector{UInt8}, width::Int, height::Int)

Extract the Y component out of a 4:2:2 YCbCr buffer
"""
function UYVYextractY(imbuff::Vector{UInt8}, width::Int, height::Int)
    reshape(imbuff[2:2:end],(width,height))'
end

"""
    UYVYextractY(imbuff::Vector{UInt8}, width::Int, height::Int)

Extract the Y component out of a 4:2:2 YCbCr buffer
"""
function YUYVextractY(imbuff::Vector{UInt8}, width::Int, height::Int)
    reshape(imbuff[1:2:end],(width,height))'
end

##

abstract type AbstractEncodings end

struct UYVYonlyY <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
UYVYonlyY(width::Int, height::Int) = UYVYonlyY(width, height, 1, UInt8)

function (decoder::UYVYonlyY)(imy::Array{UInt8,2})
    imbuff = copy_buffer_bytes(decoder.width * decoder.height * 2)
    imy[:,:] = reshape(imbuff[2:2:end],(decoder.width, decoder.height))'
    return nothing
end


struct UYVY <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
UYVY(width::Int, height::Int) = UYVY(width, height, 3, UInt8)

function (decoder::UYVY)(im444::Array{UInt8,3})
    imbuff = copy_buffer_bytes(decoder.width * decoder.height * 2)
    im444[:] = convertUYVYtoArray(imbuff, decoder.width, decoder.height)
    return nothing
end

struct YUYVonlyY <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
YUYVonlyY(width::Int, height::Int) = YUYVonlyY(width, height, 1, UInt8)

function (decoder::YUYVonlyY)(imy::Array{UInt8,2})
    imbuff = copy_buffer_bytes(decoder.width * decoder.height * 2)
    imy[:,:] = reshape(imbuff[1:2:end],(decoder.width, decoder.height))'
    return nothing
end


struct YUYV <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
YUYV(width::Int, height::Int) = YUYV(width, height, 3, UInt8)

function (decoder::YUYV)(im444::Array{UInt8,3})
    imbuff = copy_buffer_bytes(decoder.width * decoder.height * 2)
    im444[:] = convertYUYVtoArray(imbuff, decoder.width, decoder.height)
    return nothing
end


struct Y10B <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
Y10B(width::Int, height::Int) = Y10B(width, height, 1, UInt16)

function (decoder::Y10B)(imy10b::Array{UInt16,2})
    imbuff = copy_buffer_bytes(div(decoder.width * decoder.height * 10,8))
    imy10b[:] = reshape(convertY10BtoU16(imbuff), (decoder.width, decoder.height))'
    return nothing
end


#Convertions
function convert(::Type{Gray}, rf::RawFrame)
    if rf.pixelformat == :UYVY
        return reinterpret(Gray{N0f8}, UYVYextractY(rf.data, rf.width, rf.height))
    elseif rf.pixelformat == :YUYV
        return reinterpret(Gray{N0f8}, YUYVextractY(rf.data, rf.width, rf.height))
    elseif rf.pixelformat == :Y10B
        buflenght = div(rf.width * rf.height * 10, 8) #10 bits per pixel / 8 bits per byte
        return reinterpret(Gray{N0f16}, reshape(  convertY10BtoU16(rf.data[1:buflenght])  ,(rf.width,rf.height))')
    else
        error("Frame format $(rf.pixelformat) possibly not implemented yet")
    end
end

function convert(::Type{YCbCr}, rf::RawFrame)
    if rf.pixelformat == :UYVY
        return convertUYVYtoYCbCr(rf.data, rf.width, rf.height)
    elseif rf.pixelformat == :YUYV
        return convertYUYVtoYCbCr(rf.data, rf.width, rf.height)
    else
        error("Frame format $(rf.pixelformat) possibly not implemented yet, or not supported.")
    end
end
