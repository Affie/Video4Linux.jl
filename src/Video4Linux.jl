__precompile__()
module Video4Linux

function __init__()
    @show depfile = joinpath(dirname(@__FILE__),"../deps/loadpath.jl")
    isfile(depfile) ? include(depfile) : error("Video4Linux not properly installed. Please run: Pkg.build(\"Video4Linux\")")
end

export
#wrappers
set_io_method,
open_device,
init_device,
start_capturing,
mainloop,
stop_capturing,
uninit_device,
close_device,
copy_buffer_bytes,

#convertions TODO: extend convert
convertY10BtoU16,
convertUYVYtoYCbCr,
convertYUYVtoYCbCr,
#decoders


#videotasks
videoproducer,
stopVideoProducer

include("v4l2header.jl")

include("v4l2header.jl")

include("wrappers.jl")
include("encodings.jl")
include("videotasks.jl")

include("libv4l2.jl")

end # module
