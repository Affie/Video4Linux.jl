module Video4Linux

@show depfile = joinpath(dirname(@__FILE__),"../deps/loadpath.jl")
isfile(depfile) ? include(depfile) : error("Video4Linux not properly installed. Please run: Pkg.build(\"Video4Linux\")")

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


#encodings
y10bpacked2u16,
convert422toYCbCr,
extract422Yonly,
#decoders
Y422,
YCrCb422,
Y10bit,


#videotasks
videoproducer

include("wrappers.jl")
include("encodings.jl")
include("videotasks.jl")

end # module
