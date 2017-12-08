using Colors, ColorTypes

function make_bitvector(v::Vector{UInt8})
    siz = sizeof(v)
    bv = falses(siz<<3)
    unsafe_copy!(reinterpret(Ptr{UInt8}, pointer(bv.chunks)), pointer(v), siz)
    bv
end


"""
    y10bpacked2u16(imbuff::Vector{UInt8})
Convert a packed 10 bit grayscale buffer [`::Vector{UInt8}`] to 16 bit padded buffer [`::Vector{UInt16}`]
[x x x x x x b9 b8 b7 b6 b5 b4 b3 b2 b1 b0]
"""
function y10bpacked2u16(imbuff::Vector{UInt8} )

    L = length(imbuff)
    bv = flipdim(reshape(make_bitvector(imbuff[(L):-1:1]),10,:)',1)

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
    convert422toYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)

Convert a 4:2:2 encoded YCbCr buffer [`::Vector{UInt8}`] to full YCbCr
"""
function convert422toYCbCr(imbuff::Vector{UInt8}, width::Int, height::Int)

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
    convert422to444(imbuff::Vector{UInt8}, width::Int, height::Int)

Convert a 4:2:2 encoded YCbCr buffer [`::Vector{UInt8}`] to full 4:4:4 buffer [`::Matrix{UInt8}[3]`]
"""
function convert422to444(imbuff::Vector{UInt8}, width::Int, height::Int)

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
    extract422Yonly(imbuff::Vector{UInt8}, width::Int, height::Int)

Extract the Y component out of a 4:2:2 YCbCr buffer
"""
function extract422Yonly(imbuff::Vector{UInt8}, width::Int, height::Int)
    reshape(imbuff[2:2:end],(width,height))'
end

##

abstract type AbstractEncodings end

struct Y422 <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
Y422(width::Int, height::Int) = Y422(width, height, 1, UInt8)

function (decoder::Y422)(imy::Array{UInt8,2})
    imbuff = copy_buffer_bytes(decoder.width * decoder.height * 2)
    imy[:,:] = reshape(imbuff[2:2:end],(decoder.width, decoder.height))'
    return nothing
end


struct YCbCr422 <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
YCbCr422(width::Int, height::Int) = YCbCr422(width, height, 3, UInt8)

function (decoder::YCbCr422)(im444::Array{UInt8,3})
    imbuff = copy_buffer_bytes(decoder.width * decoder.height * 2)
    im444[:] = convert422to444(imbuff, decoder.width, decoder.height)
    return nothing
end


struct Y10bit <: AbstractEncodings
    width::Int
    height::Int
    depth::Int
    datatype::DataType
end
Y10bit(width::Int, height::Int) = Y10bit(width, height, 1, UInt16)

function (decoder::Y10bit)(imy10b::Array{UInt16,2})
    imbuff = copy_buffer_bytes(div(decoder.width * decoder.height * 10,8))
    # imy10b[:] = y10bpacked2u16(imbuff)
    imy10b[:] = reshape(y10bpacked2u16(imbuff), (decoder.width, decoder.height))'
    return nothing
end
