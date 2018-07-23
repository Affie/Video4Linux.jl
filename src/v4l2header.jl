#from videodev2.h
# mutable struct v4l2_pix_format
#     buf::Vector{UInt8}
# end
mutable struct v4l2_pix_format
    width::UInt32
    height::UInt32
    pixelformat::UInt32
    field::UInt32
    bytesperline::UInt32
    sizeimage::UInt32
    colorspace::UInt32
    priv::UInt32
    flags::UInt32
    ycbcr_enc::UInt32
    quantization::UInt32
    xfer_func::UInt32
    pad1::UInt128
    pad2::UInt128
    pad3::UInt128
    pad4::UInt128
    pad5::UInt128
    pad6::UInt128
    pad7::UInt128
    pad8::UInt128
    pad9::UInt128
    pad10::UInt64
end


@enum(v4l2_buf_type::UInt32,
    V4L2_BUF_TYPE_VIDEO_CAPTURE = (UInt32)(1),
    V4L2_BUF_TYPE_VIDEO_OUTPUT = (UInt32)(2),
    V4L2_BUF_TYPE_VIDEO_OVERLAY = (UInt32)(3),
    V4L2_BUF_TYPE_VBI_CAPTURE = (UInt32)(4),
    V4L2_BUF_TYPE_VBI_OUTPUT = (UInt32)(5),
    V4L2_BUF_TYPE_SLICED_VBI_CAPTURE = (UInt32)(6),
    V4L2_BUF_TYPE_SLICED_VBI_OUTPUT = (UInt32)(7),
    V4L2_BUF_TYPE_VIDEO_OUTPUT_OVERLAY = (UInt32)(8),
    V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE = (UInt32)(9),
    V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE = (UInt32)(10),
    V4L2_BUF_TYPE_SDR_CAPTURE = (UInt32)(11),
    V4L2_BUF_TYPE_SDR_OUTPUT = (UInt32)(12),
    V4L2_BUF_TYPE_PRIVATE = (UInt32)(128))

#= <<<<<<< HEAD
mutable struct fmt_union
    pix::v4l2_pix_format
end

mutable struct v4l2_format
    _type::v4l2_buf_type
    fmt::fmt_union #TODO die moet 'n union wees, maar word nie gesteun nie, dalk werk dit met padding? neem aan grootste is __u8	raw_data[200] so pad fmt
end

# v4l2_pix_format() = v4l2_pix_format(zeros(UInt8,800))
v4l2_pix_format() = v4l2_pix_format(zeros(UInt32,12)..., zeros(UInt128,9)..., UInt64(0))
v4l2_format() = v4l2_format(V4L2_BUF_TYPE_VIDEO_CAPTURE, fmt_union(v4l2_pix_format()))

# const VIDIOC_S_FMT = 0xc0d05605
# fmt = Video4Linux.v4l2_format()
# iocontrol = Video4Linux.v4l2_ioctl(fd, VIDIOC_S_FMT, Ref(fmt))

# TODO the structs are wrong and breaks julia, this works:
# const VIDIOC_G_FMT = 0xc0d05604
# fmt = Video4Linux.v4l2_format()
# blokmem = zeros(UInt32,204)
# iocontrol = Video4Linux.v4l2_ioctl(fd, VIDIOC_G_FMT, Ref(blokmem))
=## =======

mutable struct v4l2_format
    _type::v4l2_buf_type
    fmt::v4l2_pix_format #TODO die moet 'n union wees, maar word nie gesteun nie, dalk werk dit met padding? neem aan grootste is __u8	raw_data[200] so pad fmt
end

v4l2_pix_format() = v4l2_pix_format(zeros(UInt32,12)..., zeros(UInt128,9)..., UInt64(0))
v4l2_format() = v4l2_format(V4L2_BUF_TYPE_VIDEO_CAPTURE, v4l2_pix_format())

# const VIDIOC_S_FMT = 0xc0d05605
# fmt = Video4Linux.v4l2_format()
# iocontrol = Video4Linux.v4l2_ioctl(fd, VIDIOC_S_FMT, fmt)
# >>>>>>> master
